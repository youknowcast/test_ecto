import Config

config :test_ecto, ecto_repos: [TestEcto.Repo]

config :test_ecto, TestEcto.Repo,
  adapter: Sqlite.Ecto3,
  database: "test_ecto_#{Mix.env()}.sqlite3",
  pool_size: 10
