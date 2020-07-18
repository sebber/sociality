defmodule Sociality.Posts.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "post_reactions" do
    belongs_to :post, Sociality.Posts.Post
    belongs_to :user, Sociality.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(reaction, attrs \\ %{}) do
    reaction
    |> cast(attrs, [:post_id, :user_id])
    |> unique_constraint([:post_id, :user_id], name: :post_reactions_post_id_user_id_index)
    |> validate_required([:post_id, :user_id])
  end
end
