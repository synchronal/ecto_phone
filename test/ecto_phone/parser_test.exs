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

    test "parses Vienna landlines with an integer default prefix" do
      for input <- ["+43 1 234567", "43 1 234567", "+43 1 2345678", "43 1 2345678"] do
        assert {:ok, phone} = Parser.parse(input, default_prefix: 43, format: :e164), input
        assert phone.e164 in [431_234_567, 4_312_345_678], input
      end
    end

    test "parses Vienna landlines without country code" do
      assert {:ok, phone} = Parser.parse("01 2345678", default_prefix: 43, format: :e164)
      assert phone.e164 == 4_312_345_678
    end

    test "parses numbers with a national trunk prefix" do
      assert {:ok, phone} = Parser.parse("0664 1234567", default_prefix: 43, format: :e164)
      assert phone.e164 == 436_641_234_567
    end

    test "parses numbers with an international call prefix" do
      assert {:ok, phone} = Parser.parse("0043 664 1234567", default_prefix: 43, format: :e164)
      assert phone.e164 == 436_641_234_567

      assert {:ok, phone} = Parser.parse("011 43 664 1234567", default_prefix: 1, format: :e164)
      assert phone.e164 == 436_641_234_567
    end

    test "does not add the default prefix to numbers starting with +" do
      assert {:ok, phone} = Parser.parse("+45 32 123456", default_prefix: 43, format: :e164)
      assert phone.e164 == 4_532_123_456
    end

    test "parses 10-digit international numbers with a different default prefix (issue #1)" do
      assert {:ok, phone} = Parser.parse("+46 40 19 12 40", default_prefix: 1, format: :international)
      assert phone |> to_string() == "+46 40 19 12 40"
    end

    test "parses national numbers without a trunk prefix for the default country" do
      assert {:ok, phone} = Parser.parse("1 2345678", default_prefix: 43, format: :e164)
      assert phone.e164 == 4_312_345_678

      assert {:ok, phone} = Parser.parse("8 445 04 40", default_prefix: 46, format: :e164)
      assert phone.e164 == 4_684_450_440
    end

    test "keeps the leading 0 where it is part of the national number" do
      assert {:ok, phone} = Parser.parse("06 1234 5678", default_prefix: 39, format: :e164)
      assert phone.e164 == 390_612_345_678
    end

    test "parses international numbers missing their + when not valid for the default country" do
      assert {:ok, phone} = Parser.parse("45 32 123456", default_prefix: 1, format: :e164)
      assert phone.e164 == 4_532_123_456

      assert {:ok, phone} = Parser.parse("39 06 1234 5678", default_prefix: 43, format: :e164)
      assert phone.e164 == 390_612_345_678
    end

    test "parses international numbers missing their + without a default prefix" do
      assert {:ok, phone} = Parser.parse("43 1 2345678", default_prefix: nil, format: :e164)
      assert phone.e164 == 4_312_345_678
    end

    test "returns the error for the default country when neither reading is valid" do
      assert {:error, error} = Parser.parse("555 000 0000", default_prefix: 1, format: :e164)
      assert Exception.message(error) == "is not a valid phone number"
    end

    test "returns a format error for non-numeric input" do
      assert {:error, error} = Parser.parse("0664 abc", default_prefix: 43, format: :e164)
      assert Exception.message(error) == "expected to be in the format +<country code> <number>"
    end
  end
end
