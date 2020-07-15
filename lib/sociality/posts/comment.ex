defmodule Sociality.Posts.PostComment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts_comments" do
    belongs_to :post, Sociality.Posts.Post
    belongs_to :comment, Sociality.Comments.Comment
    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:post_id, :comment_id])
  end
end
