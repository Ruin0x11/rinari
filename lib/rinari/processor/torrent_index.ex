defmodule Rinari.Processor.TorrentIndex do
  @behaviour Rinari.Processor

  alias Broadway.Message

  @impl Rinari.Processor
  def type, do: "torrent_index"

  @impl Rinari.Processor
  def process(%Message{data: %{"media_type" => media_type, "id" => id}} = message) do
    # case Repo.insert(changeset, on_conflict: :nothing) do
    #   {:ok, _} ->
    #     message

    #   {:error, _} ->
    #     Message.failed(message, "Could not preprocess customer #{customer_id}")
    # end
  end
end
