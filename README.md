# EctoPhone

An ecto type for phone numbers.

## Installation

``` elixir
  {:ecto_phone "~> 1.0"}
```

## Usage

`EctoPhone` may be used in place of `:string` fields, where extra
parsing and validation is desired.

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

Phone formats accept formats compatible with the `ex_phone_number`
library, and are used in the `EctoPhone` implementations of
`String.Chars` and `Phoenix.HTML.Safe`:

- `:e164` - example: `+14155555555`
- `:international` - example: `+1 415-555-5555`
- `:national` - example: `(415) 555-5555`
- `:rfc3966` - example: `tel:+1-415-555-5555`

`EctoPhone` also provides the `~PHONE` sigil for more concise creation
of phone structs.

``` elixir
iex> import EctoPhone, only: [sigil_PHONE: 2]
...>
iex> ~PHONE[1 415 555 5555]i
%EctoPhone{e164: 14155555555, format: :international}
```

## Configuration

`EctoPhone` may be configured at compile time with the following values:

``` elixir
config :ecto_phone,
    default_prefix: 1,
    default_format: :international
```

## Alternatives

- <https://hex.pm/packages/ecto_phone_number> — EctoPhone is heavily
  inspired by `EctoPhoneNumber`. It's a great library and may provide
  for your needs. We needed some extra parameterization and error
  messages.
