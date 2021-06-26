defmodule Rinari.Processor.TorrentIndex do
  @behaviour Rinari.Processor

  alias Broadway.Message

  @impl Rinari.Processor
  def type, do: :torrent_index

  @impl Rinari.Processor
  def process(%Message{data: %{media_type: media_type, id: id}} = message) do
    case Rinari.ProviderStrategies.get_strategies(media_type, id) do
      {:ok, strategies} ->
        Enum.each(strategies, fn strategy -> Rinari.Usagi.send_message(%{type: :fetch_torrents, strategy: strategy}) end)
        message

      {:error, _} ->
        Message.failed(message, "Could not preprocess media #{media_type} #{id}")
    end
  end
end
