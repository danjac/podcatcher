defmodule Release.Tasks do
  def migrate do
    {:ok, _} = Application.ensure_all_started(:podcatcher)

    path = Application.app_dir(:podcatcher, "priv/repo/migrations")

    Ecto.Migrator.run(Podcatcher.Repo, path, :up, all: true)
  end
end
