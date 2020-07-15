defmodule Sociality.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :content, :text
      add :author_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:comments, [:author_id])
  end
end
