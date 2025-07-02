defmodule EctoPhone.ParserTest do
  use EctoTemp, repo: Test.Repo
  use Test.DataCase, async: true

  alias EctoPhone.Parser

  describe "parse/2" do
    test "parses Swedish landlines" do
      assert {:ok, _} = Parser.parse("+4684450440", default_prefix: "46", format: :international)
    end

    test "parses Swedish landlines without prefix" do
      assert {:ok, _} = Parser.parse("020 899 123", default_prefix: "46", format: :international)
    end
  end
end
