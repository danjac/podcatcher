defmodule Podcatcher.Repo.Migrations.AddSearchVectors do
  use Ecto.Migration

  def change do

    alter table(:podcasts) do
      add :keywords, :text
      add :tsv, :tsvector
    end

    alter table(:episodes) do
      add :keywords, :text
      add :tsv, :tsvector
    end

    execute "CREATE INDEX podcasts_tsv_idx ON podcasts USING GIN (tsv);"
    execute "CREATE INDEX episodes_tsv_idx ON episodes USING GIN (tsv);"

    execute """
    CREATE TRIGGER podcasts_tsv_update
    BEFORE INSERT OR UPDATE ON podcasts
    FOR EACH ROW EXECUTE PROCEDURE
    tsvector_update_trigger(tsv, 'pg_catalog.english', title, description, keywords, subtitle);
    """

    execute """
    CREATE TRIGGER episodes_tsv_update
    BEFORE INSERT OR UPDATE ON episodes
    FOR EACH ROW EXECUTE PROCEDURE
    tsvector_update_trigger(tsv, 'pg_catalog.english', title, description, keywords, subtitle, summary);
    """

  end
end
