defmodule Rinari.MessageQueue do
  @moduledoc """
  Consumes events from the producer.

  Processed messages are batched and stored as entries in the database.
  """
  use Broadway
  alias Broadway.{BatchInfo, Message}
  alias Ecto.Changeset

  @queue_name "rinari"

  def start_link(_opts) do
    Rinari.Usagi.get_queue(@queue_name)
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {
          BroadwayRabbitMQ.Producer,
          queue: @queue_name,
          metadata: [:routing_key, :headers],
          on_failure: :reject
        }
      ],
      processors: [
        default: [
          concurrency: 2,
          min_demand: 1,
          max_demand: 2
        ]
      ],
      batchers: [
        default: [],
        insert_all: [
          batch_size: 50,
          batch_timeout: 1_000
        ]
      ]
    )
  end

  @impl Broadway
  def handle_message(
    _processor_name,
    %Message{data: data, metadata: %{headers: headers, routing_key: routing_key}} = message,
    _context
  ) do
    message
    |> Message.update_data(&Jason.decode!/1)
    |> process_message()
    |> route_message()
    |> IO.inspect(label: "Got message")
  end

  defp process_message(%Message{data: %{"type" => type}} = message) do
    case Rinari.Processor.for_type(type) do
      nil -> Message.failed(message, "No processor available for message type '#{type}'")
      processor -> processor.process(message)
    end
  end

  defp process_message(message) do
    Message.failed(message, "No message type specified")
  end

  # Route the messages to the proper batcher
  defp route_message(%Message{data: %{"type" => type}} = message) do
    case batching(type) do
      :default ->
        message

      {batcher, batch_key} when is_atom(batcher) ->
        message
        |> Message.put_batcher(batcher)
        |> Message.put_batch_key(batch_key)
    end
  end

  defp route_message(message), do: message

  defp batching(_), do: :default

  @impl Broadway
  def handle_batch(_, messages, _, _), do: messages
end
