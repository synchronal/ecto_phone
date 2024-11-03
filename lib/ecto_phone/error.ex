defmodule EctoPhone.Error do
  # @related [tests](test/ecto_phone/error_test.exs)
  @moduledoc """
  An error providing information when a phone number may not be parsed.

  ``` elixir
  iex> Exception.message(EctoPhone.Error.exception(type: :format))
  "expected to be in the format +1 ###-###-####"

  iex> Exception.message(EctoPhone.Error.exception(type: :validation))
  "is not a valid phone number"

  iex> Exception.message(EctoPhone.Error.exception(type: :unknown))
  "is not valid"

  iex> Exception.message(EctoPhone.Error.exception(message: "is the wrong shape"))
  "is the wrong shape"
  ```
  """
  defexception ~w[type passthrough]a

  @impl Exception
  def exception(type: atom) when atom in ~w[format parser unknown validation]a do
    %__MODULE__{type: atom}
  end

  def exception(message: message) do
    %__MODULE__{type: :parser, passthrough: message}
  end

  @impl Exception
  def message(error) do
    to_string(error)
  end

  defimpl String.Chars do
    def to_string(error) do
      case error do
        %{type: :format} -> "expected to be in the format +1 ###-###-####"
        %{type: :parser, passthrough: m} -> m
        %{type: :unknown} -> "is not valid"
        %{type: :validation} -> "is not a valid phone number"
      end
    end
  end
end
