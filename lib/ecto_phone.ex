defmodule EctoPhone do
  # @related [tests](test/ecto_phone_test.exs)

  @moduledoc """
  A custom Ecto type for phone numbers, with configuration for default country
  prefix and formatting style.

  ## Usage

  The `EctoPhone` type may be used in place of `:string` fields.

  ``` elixir
  defmodule MySchema do
    use Ecto.Schema

    schema "table_name" do
      field :phone, EctoPhone
      field :phone, EctoPhone, default_prefix: 1
      field :phone, EctoPhone, format: :national
    end
  end
  ```

  ## Configuration

  ``` elixir
  config :ecto_phone, default_prefix: 1, default_format: :national
  ```

  `EctoPhone` may be configured at the application level with the following
  options.

  - `:default_prefix`: A country prefix to use when none is provided by users.
    Set to `1` if not configured by the application or by the field.
  - `:default_format`: The `ex_phone_number` format to use when printing
    phone numbers as strings. Defaults to `:international`. Valid options:
    `:e164`, `:international`, `:national`, `:rfc3966`
  """

  @default_prefix Application.compile_env(:ecto_phone, :default_prefix, 1)
  @default_format Application.compile_env(:ecto_phone, :default_format, :international)

  @behaviour Ecto.ParameterizedType
  @type t :: %__MODULE__{}

  @enforce_keys ~w[e164 format]a
  defstruct ~w[e164 format]a

  defimpl Inspect do
    def inspect(%{e164: e164}, _opts) do
      ~s(#EctoPhoneNumber<#{e164}>)
    end
  end

  defimpl String.Chars do
    def to_string(%{e164: e164, format: format}) do
      with e164_integer when is_integer(e164_integer) <- e164,
           {:ok, ex_phone_number} <- ExPhoneNumber.parse("+" <> Integer.to_string(e164_integer), nil) do
        ExPhoneNumber.format(ex_phone_number, format)
      else
        _ -> Kernel.to_string(e164)
      end
    end
  end

  @doc """
  Handles the sigil `~PHONE` for an `EctoPhone` struct.

  ## Modifers

  - `e`: Format as `:e164`
  - `i`: Format as `:international`
  - `n`: Format as `:national`
  """
  def sigil_PHONE(number, modifiers) do
    format =
      case modifiers do
        [] -> @default_format
        ~c"e" -> :e164
        ~c"i" -> :international
        ~c"n" -> :national
        ~c"rfc" -> :rfc3966
      end

    opts = [default_prefix: @default_prefix, format: format]

    case EctoPhone.Parser.parse(number, opts) do
      {:ok, phone} -> phone
      {:error, error} -> raise error
    end
  end

  @doc """
  Configures a specific field.

  ``` elixir
  schema "table_name" do
    field :phone, EctoPhone
    field :phone, EctoPhone, default_prefix: 1
    field :phone, EctoPhone, format: :national
  end
  ```
  """
  @impl Ecto.ParameterizedType
  def init(opts), do: validate_opts(opts)

  @impl Ecto.ParameterizedType
  def type(_opts), do: :string

  @impl Ecto.ParameterizedType
  def cast(nil, _opts), do: {:ok, nil}
  def cast(%__MODULE__{} = phone_number, _opts), do: {:ok, phone_number}
  def cast(integer, opts) when is_integer(integer), do: Kernel.to_string(integer) |> cast(opts)

  def cast(string, opts) when is_binary(string) do
    case EctoPhone.Parser.parse(string, opts) do
      {:ok, number} ->
        {:ok, number}

      {:error, e} ->
        {:error, message: to_string(e)}
    end
  end

  def cast(_, _opts), do: :error

  @impl Ecto.ParameterizedType
  def load(e164_phone, _loader, opts) when is_binary(e164_phone) do
    case Integer.parse(e164_phone) do
      {number, ""} -> {:ok, %__MODULE__{e164: number, format: opts[:format]}}
      _ -> :error
    end
  end

  def load(nil, _loader, _opts), do: {:ok, nil}

  @impl Ecto.ParameterizedType
  def dump(%__MODULE__{e164: e164}, _dumper, _opts) when is_integer(e164), do: {:ok, Integer.to_string(e164)}
  def dump(nil, _dumper, _opts), do: {:ok, nil}
  def dump(_, _dumper, _opts), do: :error

  @impl Ecto.ParameterizedType
  def embed_as(_format, _params), do: :self

  @impl Ecto.ParameterizedType
  def equal?(left, right, opts), do: cast(left, opts) == cast(right, opts)

  # # #

  defp validate_opts(opts) do
    {default_prefix, opts} = Keyword.pop(opts, :default_prefix, @default_prefix)
    {format, opts} = Keyword.pop(opts, :format, :international)
    opts = Keyword.drop(opts, ~w[field schema]a)

    if opts != [],
      do:
        raise(ArgumentError, """
        Unknown options provided for Extra.Ecto.PhoneNumber!

          Valid options: :default_prefix, :format
          Found: #{inspect(opts)}
        """)

    [default_prefix: default_prefix, format: format]
  end
end
