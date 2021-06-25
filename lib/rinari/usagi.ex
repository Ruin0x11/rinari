defmodule Rinari.Usagi do
  def open_connection do
    options = [
      host: Application.get_env(:rinari, :amqp_host),
      port: 5672,
      virtual_host: "/",
      username: Application.get_env(:rinari, :amqp_username),
      password: Application.get_env(:rinari, :amqp_password)
    ]
    {:ok, connection} = AMQP.Connection.open(options)
    connection
  end

  @spec get_channel :: %{channel: AMQP.Channel.t(), connection: AMQP.Connection.t()}
  def get_channel() do
    connection = open_connection()
    {:ok, channel} = AMQP.Channel.open(connection)
    %{channel: channel, connection: connection}
  end

  def close(connection) do
    AMQP.Connection.close(connection)
  end

  def get_queue(queue_name) do
    test = get_channel()
    # AMQP.Exchange.declare(test.channel, "delay-exchange", :"x-delayed-message", durable: true, auto_delete: false, arguments: ["x-delayed-type": "direct"])
    # AMQP.Exchange.declare(test.channel, "exchange", durable: true, auto_delete: false)
    AMQP.Queue.declare(test.channel, queue_name, durable: true)
    # AMQP.Queue.bind(test.channel, queue_name, "delay-exchange", routing_key: queue_name)
    close(test.connection)
  end

  def send_message(queue_name, message, exchange \\ "") do
    amqp = get_channel()
    headers = [] # [{"x-delay", delay}]
    AMQP.Basic.publish(amqp.channel, exchange, queue_name, Jason.encode!(message), headers: headers, persistence: true)
    close(amqp.connection)
  end
end
