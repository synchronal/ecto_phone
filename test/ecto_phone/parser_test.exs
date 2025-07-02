defmodule EctoPhone.ParserTest do
  use EctoTemp, repo: Test.Repo
  use Test.DataCase, async: true

  alias EctoPhone.Parser

  describe "parse/2" do
    test "parses Swedish landlines" do
      assert {:ok, phone} = Parser.parse("+4684450440", default_prefix: "46", format: :international)
      assert phone |> to_string() == "+46 8 445 04 40"
    end

    test "parses Swedish landlines without country code" do
      assert {:ok, phone} = Parser.parse("020 899 123", default_prefix: "46", format: :international)
      assert phone |> to_string() == "+46 20 89 91 23"
    end

    test "parses Danish international numbers" do
      assert {:ok, phone} = Parser.parse("+45 32 123456", default_prefix: "46", format: :international)
      assert phone |> to_string() == "+45 32 12 34 56"
    end

    test "parses +1 450 (Quebec) without country code" do
      assert {:ok, phone} = Parser.parse("4502001234", default_prefix: "1", format: :international)
      assert phone |> to_string() == "+1 450-200-1234"
    end
  end
end
