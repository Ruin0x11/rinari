defmodule Rinari.MessageQueue do
  @moduledoc """
  Consumes events from the producer.

  Processed messages are batched and stored as entries in the database.
  """
  use Broadway
  alias Broadway.{BatchInfo, Message}

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
        batch_insert: [
          batch_size: 50,
          batch_timeout: 1_000
        ]
      ]
    )
  end

  @impl Broadway
  def handle_message(_processor_name, message, _context) do
    message
    |> Message.update_data(fn d -> Jason.decode!(d, keys: :atoms) end)
    |> process_message()
    |> IO.inspect(label: "Got message")
  end

  defp process_message(%Message{data: %{type: type}} = message) do
    case Rinari.Processor.for_type(type |> String.to_atom()) do
      nil -> message
      processor -> processor.process(message)
    end
  end

  defp process_message(message) do
    Message.failed(message, "No message type specified")
  end

  @impl Broadway
  def handle_batch(:default, messages, _, _), do: messages

  def handle_batch(type, messages, batch_info, _) do
    IO.inspect(type)
    case Rinari.Batcher.for_type(type) do
      nil -> Enum.map(messages, &Message.failed(&1, "No batcher with type #{type} registered."))
      batcher -> batcher.batch(messages, batch_info)
    end
  end
end
