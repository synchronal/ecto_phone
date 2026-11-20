# Change log

## Unreleased

## 3.1.0

- Numbers not starting with `+` are parsed as national numbers of the
  default prefix's main country, for every country. If that gives no
  valid number, the digits are tried as an international number missing
  its `+`. This replaces the 9–10 digit `default_prefix` guess.
- `cast/2` accepts `%{country_code: _, number: _}` (atom or string
  keys), so the calling code can be chosen per value.
- Remove the hard-coded rules for numbers starting with `45` and `450`.
  `450 200 1234` only becomes `+1 450-200-1234` when the default prefix
  is `1`, and a `45…` number that is valid for the default country is
  read as that country's number instead of a Danish one.
- Add a guide to building a Phoenix phone input with a calling code
  select.

## 3.0.0

- Fix integer `:default_prefix` being added to numbers that already
  start with it (e.g. `43 1 234567` with `default_prefix: 43`).
- Numbers starting with `+` never receive the default prefix.
- Numbers starting with `0` are parsed against the default prefix's
  region, so trunk prefixes (`0664 …`) and international call prefixes
  (`0043 …`, `011 …`) are handled.

### Breaking changes

- The format error message is now
  `"expected to be in the format +<country code> <number>"` instead of
  `"expected to be in the format +1 ###-###-####"`.

## 2.0.2

- Fix parsing Swedish landline number without prefix. Thanks
  <stefan@recycla.se>!

## 2.0.1

- Only add default prefix when the phone number does not already begin
  with it.

## 2.0.0

- Test against Elixir 1.18.
- **Breaking change:** drop support for Elixir 1.15.

## 1.1.0

- Implement `Phoenix.HTML.Safe` when `phoenix_html` is present.

## 1.0.2

- `inspect` returns a phone sigil.

## 1.0.1

- Docs open to main module.
- Fix error specs.

## 1.0.0

- Initial release
