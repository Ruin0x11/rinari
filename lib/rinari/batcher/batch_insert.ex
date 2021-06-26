defmodule Rinari.Batcher.BatchInsert do
  @behaviour Rinari.Batcher

  alias Broadway.{BatchInfo, Message}
  alias Ecto.Changeset
  alias Rinari.Repo
  alias Rinari.Model.Torrent

  @impl Rinari.Batcher
  def type, do: :batch_insert

  @impl Rinari.Batcher
  def batch(messages, %BatchInfo{batch_key: schema}) do
    batch_insert_all(schema, messages, [])
  end

  defp batch_insert_all(Torrent, messages, _opts) do
    entries = convert_batch_to_entries(Torrent, messages)

    case Repo.insert_all(Torrent, entries, returning: true) do
      {n, results} when n == length(entries) ->
        zip = Enum.zip([results, messages])
        groups = Enum.group_by(zip, fn {_, %Message{data: %{assoc: assoc}}} -> assoc end)

        entries = Enum.map(groups, fn {%{type: type, id: id, relation: relation}, msgs} ->
          relation = String.to_atom(relation)
          t = Enum.map(msgs, fn {result, _} -> result end)
          media = Rinari.Utils.typed_id_to_entity(type, id) |> Repo.preload(relation)
          media
          |> Changeset.change
          |> Changeset.put_assoc(relation, t ++ Map.get(media, String.to_existing_atom("#{relation}")))
          |> Repo.update()
        end)

        IO.inspect(entries)
        success = true

        if success do
          messages
        else
          batch_failed(messages, {:update_all, Torrent, {n, results}})
        end

      result ->
        batch_failed(messages, {:insert_all, Torrent, result})
    end
  end

  defp batch_insert_all(schema, messages, opts) do
    entries = convert_batch_to_entries(schema, messages)

    case Repo.insert_all(schema, entries, opts) do
      {n, _} when n == length(entries) ->
        messages

      result ->
        batch_failed(messages, {:insert_all, schema, result})
    end
  end

  # This converter should apply to any simple schemas
  defp convert_batch_to_entries(schema, messages) do
    Enum.map(messages, fn %Message{data: %{entity: attrs}} ->
      %Changeset{changes: changes} =
        schema
        |> struct!()
        |> schema.changeset(attrs)

      Map.merge(changes, timestamps(schema))
    end)
  end

  defp timestamps(_) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    %{inserted_at: now, updated_at: now}
  end

  defp batch_failed(messages, reason) when is_list(messages) do
    Enum.map(messages, &Message.failed(&1, reason))
  end
end
