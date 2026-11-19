defmodule EctoPhone.Parser do
  @moduledoc false
  alias EctoPhone.Error

  @spec parse(integer() | binary(), keyword()) ::
          {:ok, EctoPhone.t()} | {:error, nil} | {:error, EctoPhone.Error.t()}

  def parse(number, opts) when is_integer(number),
    do: Kernel.to_string(number) |> parse(opts)

  def parse(string, opts) when is_binary(string) do
    digits = String.replace(string, ~r/[\+-\.()\s]/, "")

    cond do
      # An explicit `+` means the number already carries its country code.
      String.starts_with?(String.trim_leading(string), "+") ->
        parse_phone("+" <> digits, nil, opts)

      # A leading `0` is a trunk prefix (`0664…`) or an international
      # call prefix (`0043…`); both depend on the default country.
      String.starts_with?(digits, "0") ->
        parse_phone(digits, default_region(opts), opts)

      true ->
        parse_phone("+" <> ensure_prefix(digits, opts), nil, opts)
    end
  end

  # # #

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

  defp ensure_prefix("450" <> <<_::binary-size(7)>> = phone, _opts), do: "1#{phone}"
  defp ensure_prefix("45" <> <<_::binary-size(8)>> = phone, _opts), do: phone

  defp ensure_prefix(phone_number, opts) when byte_size(phone_number) in 9..10 do
    default_prefix = to_string(opts[:default_prefix])

    if default_prefix != "" && String.starts_with?(phone_number, default_prefix) do
      phone_number
    else
      default_prefix <> phone_number
    end
  end

  defp ensure_prefix(phone_number, _opts), do: phone_number

  defp default_region(opts) do
    case Integer.parse(to_string(opts[:default_prefix])) do
      {country_code, ""} -> ExPhoneNumber.Metadata.get_region_code_for_country_code(country_code)
      _other -> nil
    end
  end
end
