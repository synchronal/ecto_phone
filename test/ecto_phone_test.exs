defmodule EctoPhoneTest do
  # @related [subject](lib/ecto_phone.ex)
  use EctoTemp, repo: Test.Repo
  use Test.DataCase, async: true
  import EctoPhone, only: [sigil_PHONE: 2]
  require EctoTemp.Factory

  deftemptable :has_phone_temp do
    column(:phone, :string)
  end

  defmodule HasPhone do
    use Ecto.Schema

    @primary_key false
    schema "has_phone_temp" do
      field(:id, :integer)
      field(:phone, EctoPhone)
    end

    def changeset(attrs), do: cast(%__MODULE__{}, Map.new(attrs), ~w[phone]a)
  end

  setup do
    create_temp_tables()
  end

  describe "~PHONE" do
    test "parses a phone number, defaulting to :international format" do
      assert ~PHONE[14155555555] == %EctoPhone{e164: 14_155_555_555, format: :international}
    end

    test "can specify international" do
      assert ~PHONE[14155555555]i == %EctoPhone{e164: 14_155_555_555, format: :international}
    end

    test "can specify national" do
      assert ~PHONE[14155555555]n == %EctoPhone{e164: 14_155_555_555, format: :national}
    end

    test "can specify e164" do
      assert ~PHONE[14155555555]e == %EctoPhone{e164: 14_155_555_555, format: :e164}
    end

    test "can specify rfc3966" do
      assert ~PHONE[14155555555]rfc == %EctoPhone{e164: 14_155_555_555, format: :rfc3966}
    end
  end

  describe "inspect" do
    test "renders as a ~PHONE sigil" do
      assert ~PHONE[14155555555]i |> inspect() == "~PHONE[+1 415-555-5555]i"
      assert ~PHONE[14155555555]e |> inspect() == "~PHONE[+1 415-555-5555]e"
      assert ~PHONE[14155555555]n |> inspect() == "~PHONE[+1 415-555-5555]n"
      assert ~PHONE[14155555555]rfc |> inspect() == "~PHONE[+1 415-555-5555]rfc"
    end
  end

  describe "to_string" do
    test "formats :international" do
      assert ~PHONE"14155555555"i |> to_string() == "+1 415-555-5555"
    end

    test "formats :national" do
      assert ~PHONE"14155555555"n |> to_string() == "(415) 555-5555"
    end

    test "formats :e164" do
      assert ~PHONE"14155555555"e |> to_string() == "+14155555555"
    end

    test "formats :rfc3966" do
      assert ~PHONE"14155555555"rfc |> to_string() == "tel:+1-415-555-5555"
    end
  end

  describe "cast" do
    test "is valid with a 10-digit phone number prefixed by 1" do
      changeset = HasPhone.changeset(phone: "14155555555")
      assert_changeset_valid changeset
      assert changeset.changes.phone == %EctoPhone{e164: 14_155_555_555, format: :international}
    end

    test "is valid with common punctuation" do
      assert_changeset_valid HasPhone.changeset(phone: "1 (415) 555-5555")
      assert_changeset_valid HasPhone.changeset(phone: "+1 (415) 555-5555")
      assert_changeset_valid HasPhone.changeset(phone: "+1 415-555-5555")
      assert_changeset_valid HasPhone.changeset(phone: "1 415.555.5555")
      assert_changeset_valid HasPhone.changeset(phone: "1 415 555 5555")
    end

    test "is nil with an empty string" do
      changeset = HasPhone.changeset(phone: "")
      assert_changeset_valid changeset
      assert changeset.changes == %{}
    end

    test "automatically prefixes 10-digit phone numbers" do
      changeset = HasPhone.changeset(phone: "4155555555")
      assert_changeset_valid changeset
      assert changeset.changes.phone == %EctoPhone{e164: 14_155_555_555, format: :international}
    end

    test "is invalid with letters" do
      assert_changeset_invalid HasPhone.changeset(phone: "415555abcd"),
        phone: ["expected to be in the format +1 ###-###-####"]
    end

    test "is invalid with a non-existent phone number" do
      assert_changeset_invalid HasPhone.changeset(phone: "000-000-0000"),
        phone: ["is not a valid phone number"]

      assert_changeset_invalid HasPhone.changeset(phone: "555-000-0000"),
        phone: ["is not a valid phone number"]
    end

    test "passes through ex_phone_number errors" do
      assert_changeset_invalid HasPhone.changeset(phone: "000"),
        phone: ["invalid country calling code"]

      assert_changeset_invalid HasPhone.changeset(phone: "+99 123 456 7890"),
        phone: ["invalid country calling code"]
    end
  end

  describe "dump" do
    test "can persist a valid phone number" do
      assert {:ok, record} = HasPhone.changeset(phone: "14155555555") |> Test.Repo.insert()
      assert record.phone == ~PHONE[1-415-555-5555]i
    end
  end

  describe "equal?" do
    test "is true when the numbers parse to the same value" do
      assert EctoPhone.equal?("1-415-555-5555", "415 555 5555", default_prefix: 1)
      assert EctoPhone.equal?("1-415-555-5555", "415.555.5555", default_prefix: 1)
    end

    test "is false when given different numbers" do
      refute EctoPhone.equal?("1-415-555-5555", "415 555 6666", default_prefix: 1)
    end

    test "is false when given numbers with different formats" do
      refute EctoPhone.equal?(~PHONE"1-415-555-5555"i, ~PHONE"1-415-555-5555"n, default_prefix: 1)
    end
  end

  describe "load" do
    test "loads nil" do
      EctoTemp.Factory.insert(:has_phone_temp, id: 0, phone: nil)
      assert Test.Repo.get_by(HasPhone, id: 0).phone == nil
    end

    test "loads a phone number" do
      EctoTemp.Factory.insert(:has_phone_temp, id: 0, phone: "14155555555")
      assert Test.Repo.get_by(HasPhone, id: 0).phone == ~PHONE[1-415-555-5555]i
    end
  end
end
