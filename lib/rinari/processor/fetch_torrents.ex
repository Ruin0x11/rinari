defmodule Rinari.Processor.FetchTorrents do
  @behaviour Rinari.Processor

  alias Broadway.Message
  alias Rinari.Model.Torrent

  @impl Rinari.Processor
  def type, do: :fetch_torrents

  @impl Rinari.Processor
  def process(%Message{data: %{strategy: strategy}} = message) do
    case Rinari.TorrentFetcher.fetch_torrents(strategy) do
      {:ok, torrents, media} ->
        type = Rinari.Utils.entity_to_typed_id(media)
        Enum.each(torrents, fn torrent ->
          msg = %{
          type: :batch_insert,
          schema: Torrent.__schema__(:source),
          entity: torrent,
          assoc: %{
            type: type,
            id: media.id,
            relation: :torrents
          }
        }
          Rinari.Usagi.send_message(msg)
        end)
        message

      {:error, _} ->
        Message.failed(message, "Could not preprocess strategy #{inspect(strategy)}")
    end
  end
end
