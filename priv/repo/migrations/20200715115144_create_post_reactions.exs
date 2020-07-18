defmodule Sociality.Repo.Migrations.CreatePostReactions do
  use Ecto.Migration

  def change do
    create table(:post_reactions) do
      add :post_id, references(:posts, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:post_reactions, [:post_id])
    create index(:post_reactions, [:user_id])
    create unique_index(:post_reactions, [:post_id, :user_id])
  end
end
