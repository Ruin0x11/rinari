defmodule Rinari.Schemas do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{schemas: nil} end, name: __MODULE__)
  end

  defp load_schemas do
    {:ok, modules} = :application.get_key(:rinari, :modules)
    modules
    |> Enum.filter(fn mod -> function_exported?(mod, :__schema__, 1) end)
    |> Enum.map(fn mod -> {mod.__schema__(:source), mod} end)
    |> Enum.filter(fn {schema, _} -> schema end)
    |> Enum.map(fn {schema, mod} -> {schema |> String.to_atom, mod} end)
    |> Enum.into(%{})
  end

  def list do
    with %{schemas: schemas} <- Agent.get(__MODULE__, & &1) do
      case schemas do
        nil ->
          schemas = load_schemas()
          Agent.update(__MODULE__, & %{&1 | schemas: schemas})
          Agent.get(__MODULE__, & Map.get(&1, :schemas))
        schemas -> schemas
      end
    end
    Agent.get(__MODULE__, & Map.get(&1, :schemas))
  end

  def get(table_id) when is_binary(table_id) do
    String.to_atom(table_id) |> get
  end
  def get(table_id) do
    list() |> Access.get(table_id)
  end
end
