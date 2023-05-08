defmodule TestEcto.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string
      add :post_tag_id, references(:post_tags)

      timestamps()
    end

    create table(:post_tags) do
      add :tag_id, references(:tags)
      add :post_id, references(:posts)

      timestamps()
    end
  end
end
