defmodule Sociality.Repo.Migrations.AddCommentsToPosts do
  use Ecto.Migration

  def change do
    create table(:posts_comments) do
      add :post_id, references(:posts)
      add :comment_id, references(:comments)
      timestamps()
    end
  end
end
