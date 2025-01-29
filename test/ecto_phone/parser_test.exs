defmodule EctoPhone.ParserTest do
  use EctoTemp, repo: Test.Repo
  use Test.DataCase, async: true

  alias EctoPhone.Parser

  describe "parse/2" do
    test "works with Swedish landline" do
      assert {:ok, _} = Parser.parse("+4684450440", default_prefix: "46", format: :international)
    end
  end
end
