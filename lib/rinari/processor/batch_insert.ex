defmodule Rinari.Processor.BatchInsert do
  @behaviour Rinari.Processor

  alias Broadway.{BatchInfo, Message}

  @impl Rinari.Processor
  def type, do: :batch_insert

  @impl Rinari.Processor
  def process(%Message{data: %{schema: schema, entity: _entity}} = message) do
    message
    |> Message.put_batcher(:batch_insert)
    |> Message.put_batch_key(Rinari.Schemas.get(schema))
  end
end
