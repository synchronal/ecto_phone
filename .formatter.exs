[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 120,
  locals_without_parens: [
    assert_changeset_invalid: :*,
    assert_changeset_valid: :*
  ]
]
