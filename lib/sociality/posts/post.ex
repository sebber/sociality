defmodule Sociality.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string
    belongs_to :author, Sociality.Accounts.User

    many_to_many :comments, Sociality.Comments.Comment,
      join_through: "posts_comments",
      on_replace: :mark_as_invalid,
      on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
