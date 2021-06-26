# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :rinari,
  ecto_repos: [Rinari.Repo]

# Configures the endpoint
config :rinari, RinariWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "m31HQquBZOfCORwjZrWXDp5rBU1qaaP2Fez2X96IW4pfA02zsYxEmXDR0rXyR7I9",
  render_errors: [view: RinariWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Rinari.PubSub,
  live_view: [signing_salt: "9PN2r/cc"]

config :rinari, Rinari.Repo, migration_timestamps: [type: :utc_datetime]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

import_config "elasticsearch.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

import_config "secret.exs"
