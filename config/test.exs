use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :podcatcher, Podcatcher.Web.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :podcatcher, Podcatcher.Mailer,
  adapter: Bamboo.TestAdapter

# Configure your database
config :podcatcher, Podcatcher.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "podcatcher_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
