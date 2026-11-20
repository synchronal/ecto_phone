defmodule EctoPhone.Parser do
  @moduledoc false
  alias EctoPhone.Error

  @spec parse(integer() | binary(), keyword()) ::
          {:ok, EctoPhone.t()} | {:error, nil} | {:error, EctoPhone.Error.t()}

  def parse(number, opts) when is_integer(number),
    do: Kernel.to_string(number) |> parse(opts)

  def parse(string, opts) when is_binary(string) do
    digits = String.replace(string, ~r/[\+-\.()\s]/, "")

    # An explicit `+` means the number already carries its country code.
    if String.starts_with?(String.trim_leading(string), "+"),
      do: parse_phone("+" <> digits, nil, opts),
      else: parse_national(digits, default_region(opts), opts)
  end

  # # #

  # Parsing for the default country handles its trunk prefix (`0664…`),
  # its international call prefix (`0043…`, `011…`), national numbers
  # dialled without a trunk prefix, and numbers that repeat the country
  # code. If that is invalid, the digits are tried as an international
  # number missing its `+`.
  @spec parse_national(binary(), binary() | nil, keyword()) ::
          {:ok, EctoPhone.t()} | {:error, nil} | {:error, EctoPhone.Error.t()}
  defp parse_national(digits, nil, opts), do: parse_phone("+" <> digits, nil, opts)

  defp parse_national(digits, region, opts) do
    with {:error, _} = error <- parse_phone(digits, region, opts) do
      case parse_phone("+" <> digits, nil, opts) do
        {:ok, phone} -> {:ok, phone}
        _other -> error
      end
    end
  end

  @spec parse_phone(binary(), binary() | nil, keyword()) ::
          {:ok, EctoPhone.t()} | {:error, nil} | {:error, EctoPhone.Error.t()}
  defp parse_phone(phone, region, opts) do
    with :ok <- validate_numeric(phone),
         {:ok, ex_phone_number} <- ExPhoneNumber.parse(phone, region),
         :ok <- validate_phone(ex_phone_number),
         "+" <> e164_string <- ExPhoneNumber.format(ex_phone_number, :e164),
         {e164_integer, ""} <- Integer.parse(e164_string) do
      {:ok, %EctoPhone{e164: e164_integer, format: opts[:format]}}
    else
      {:error, :non_numeric} ->
        {:error, Error.exception(type: :format)}

      {:error, :invalid} ->
        {:error, Error.exception(type: :validation)}

      {:error, message} when is_binary(message) ->
        {:error, Error.exception(message: String.downcase(message))}

      _other ->
        {:error, Error.exception(type: :unknown)}
    end
  end

  defp validate_numeric(string),
    do: if(Regex.match?(~r/^\+?\d+$/, string), do: :ok, else: {:error, :non_numeric})

  defp validate_phone(phone),
    do: if(ExPhoneNumber.is_valid_number?(phone), do: :ok, else: {:error, :invalid})

  @doc false
  @spec region_for_calling_code(term()) :: binary() | nil
  def region_for_calling_code(calling_code) do
    with {code, ""} <- Integer.parse(to_string(calling_code)),
         region when region not in ["ZZ", "001"] <-
           ExPhoneNumber.Metadata.get_region_code_for_country_code(code) do
      region
    else
      _other -> nil
    end
  end

  defp default_region(opts), do: region_for_calling_code(opts[:default_prefix])
end
