defmodule Test.DataCase do
  @moduledoc false
  use ExUnit.CaseTemplate
  use EctoTemp, repo: Test.Repo

  using do
    quote do
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import SchemaAssertions.ChangesetAssertions
      import Test.DataCase
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Test.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    :ok
  end
end
