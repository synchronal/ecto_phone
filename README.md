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

## Alternatives

- <https://hex.pm/packages/ecto_phone_number> — EctoPhone is heavily
  inspired by `EctoPhoneNumber`. It's a great library and may provide
  for your needs. We needed some extra parameterization and error
  messages.
