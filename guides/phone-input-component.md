# Phone inputs with country code

When used with Phoenix, `EctoPhone` can separate out the country code
from the local number via its ability to cast maps to phone numbers.

``` elixir
%{"phone" => %{"country_code" => "39", "number" => "06 1234 5678"}}
```

The calling code replaces the field's `:default_prefix` for that value,
so the number is read as a national number of that country.

## Example schema

``` elixir
defmodule MyApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :phone, EctoPhone
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:phone])
    |> validate_required([:phone])
  end
end
```

When casting the map, `EctoPhone`:

- casts to `nil` when `number` is blank, so `validate_required/2` works;
- uses the field's `:default_prefix` when `country_code` is blank;
- returns the error `"invalid country calling code"` when `country_code`
  is not a known calling code.

## The calling codes

The component needs a list of calling codes to show. Which countries to
offer, in what order, and how to name them is up to the application, so
`EctoPhone` does not provide one.

``` elixir
@calling_codes [
  {"United States / Canada (+1)", 1},
  {"United Kingdom (+44)", 44},
  {"Germany (+49)", 49},
  {"Italy (+39)", 39},
  {"Sweden (+46)", 46}
]
```

The select must use the calling code, not the country, for the value.

To offer every calling code, build the list from `ex_phone_number`. It
gives region codes, not country names, so pair them with your own names
or translations:

``` elixir
ExPhoneNumber.Metadata.get_supported_regions()
|> Enum.map(&ExPhoneNumber.Metadata.get_country_code_for_region_code/1)
|> Enum.uniq()
|> Enum.sort()
|> Enum.map(&{"+#{&1}", &1})
```

## The component

The field's value takes three shapes, and the component turns each into
a calling code and a number to show:

- `nil` for a new record: show the default calling code and an empty
  number.
- `%EctoPhone{}` for a stored or successfully cast number: split it into
  its calling code and the number in national format.
- The submitted map, when casting failed: show what the user sent, so
  they can correct it.

``` elixir
defmodule MyAppWeb.PhoneComponents do
  use Phoenix.Component

  @calling_codes [
    {"United States / Canada (+1)", 1},
    {"United Kingdom (+44)", 44},
    {"Germany (+49)", 49},
    {"Italy (+39)", 39},
    {"Sweden (+46)", 46}
  ]

  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, default: nil
  attr :calling_codes, :list, default: @calling_codes
  attr :default_calling_code, :integer, default: 1
  attr :rest, :global, include: ~w(placeholder required disabled)

  def phone_input(assigns) do
    {country_code, number} = split(assigns.field.value, assigns.default_calling_code)
    errors = if used_input?(assigns.field), do: assigns.field.errors, else: []

    assigns =
      assign(assigns,
        country_code: country_code,
        number: number,
        errors: Enum.map(errors, fn {message, _opts} -> message end)
      )

    ~H"""
    <fieldset>
      <legend :if={@label}>{@label}</legend>
      <select
        id={@field.id <> "_country_code"}
        name={@field.name <> "[country_code]"}
        aria-label="Country calling code"
      >
        {Phoenix.HTML.Form.options_for_select(@calling_codes, @country_code)}
      </select>
      <input
        type="tel"
        id={@field.id <> "_number"}
        name={@field.name <> "[number]"}
        value={@number}
        autocomplete="tel-national"
        {@rest}
      />
      <p :for={message <- @errors}>{message}</p>
    </fieldset>
    """
  end

  defp split(%EctoPhone{e164: e164}, _default) do
    {:ok, phone} = ExPhoneNumber.parse("+#{e164}", nil)
    {phone.country_code, ExPhoneNumber.format(phone, :national)}
  end

  defp split(%{"country_code" => code, "number" => number}, _default), do: {code, number}
  defp split(%{country_code: code, number: number}, _default), do: {code, number}
  defp split(number, default) when is_binary(number), do: {default, number}
  defp split(_value, default), do: {default, nil}
end
```

Use it like any other input:

``` heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.phone_input field={@form[:phone]} label="Phone" default_calling_code={39} />
</.form>
```

## Notes

- **National format round-trips.** A stored number is shown in its
  country's national format, such as `06 1234 5678` for Italy or
  `01 2345678` for Austria, including any trunk `0`. Submitting it again
  with the same calling code parses to the same number.
- **Matching the select.** `options_for_select/2` compares values as
  strings, so the integer calling code from `%EctoPhone{}` and the
  string from submitted params both select the right option. A stored
  number whose calling code is not in the list shows the first option;
  include every calling code you accept, or add the stored one to the
  list.
- **Translating errors.** If your application translates errors with
  Gettext, map `@field.errors` through your `translate_error/1` instead
  of taking the message alone.
