defmodule EctoPhone.Parser do
  @moduledoc false
  alias EctoPhone.Error

  @spec parse(integer() | binary(), keyword()) ::
          {:ok, EctoPhone.t()} | {:error, nil} | {:error, EctoPhone.Error.t()}

  def parse(number, opts) when is_integer(number),
    do: Kernel.to_string(number) |> parse(opts)

  def parse(string, opts) when is_binary(string) do
    string
    |> String.replace(~r/[\+-\.()\s]/, "")
    |> ensure_prefix(opts)
    |> parse_phone(opts)
  end

  # # #

  @spec parse_phone(binary(), keyword()) ::
          {:ok, EctoPhone.t()} | {:error, nil} | {:error, EctoPhone.Error.t()}
  defp parse_phone(phone, opts) do
    with :ok <- validate_numeric(phone),
         {:ok, ex_phone_number} <- ExPhoneNumber.parse("+" <> phone, nil),
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
    do: if(Regex.match?(~r/^\d+$/, string), do: :ok, else: {:error, :non_numeric})

  defp validate_phone(phone),
    do: if(ExPhoneNumber.is_valid_number?(phone), do: :ok, else: {:error, :invalid})

  defp ensure_prefix(phone_number, opts) when byte_size(phone_number) == 10,
    do: "#{opts[:default_prefix]}#{phone_number}"

  defp ensure_prefix(phone_number, _opts), do: phone_number
end
