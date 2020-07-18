defmodule Sociality.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Sociality.Repo

  alias Sociality.Posts.{Post, PostComment, Reaction}
  alias Sociality.Accounts.User
  alias Sociality.Comments.Comment

  @page 1
  @page_size 10

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(params \\ %{}, filters \\ %{}) do
    build_query(params, filters)
    |> Repo.all()
  end

  defp base_query() do
    from(posts in Post)
  end

  defp build_query(params, filters) do
    base_query()
    |> maybe_preload_author(params[:author])
    |> maybe_preload_comments(params[:comments])
    |> maybe_preload_reactions(params[:reactions])
    |> maybe_filter_by_author(filters[:author])
    |> paginate(params[:page], params[:page_size])
    |> sort(params[:sort])
  end

  defp maybe_preload_author(query, nil), do: query

  defp maybe_preload_author(query, _) do
    from(post in query,
      left_join: author in User,
      on: author.id == post.author_id,
      preload: [author: author]
    )
  end

  defp maybe_preload_comments(query, nil), do: query
  defp maybe_preload_comments(query, true), do: maybe_preload_comments(query, %{})

  defp maybe_preload_comments(query, params) do
    comments_query =
      from(comment in Comment)
      |> maybe_preload_comment_author(params[:author])

    from(posts in query, preload: [comments: ^comments_query])
  end

  defp maybe_preload_comment_author(query, nil), do: query

  defp maybe_preload_comment_author(query, _) do
    from(comment in query,
      left_join: author in User,
      on: author.id == comment.author_id,
      preload: [author: author],
      order_by: [asc: comment.inserted_at]
    )
  end

  defp maybe_preload_reactions(query, nil), do: query

  defp maybe_preload_reactions(query, _) do
    from(posts in query, preload: :reactions)
  end

  defp maybe_filter_by_author(query, nil), do: query

  defp maybe_filter_by_author(query, id) do
    from(posts in query,
      inner_join: author in User,
      on: author.id == posts.author_id,
      where: author.id == ^id
    )
  end

  defp paginate(query, nil, nil), do: paginate(query, @page, @page_size)
  defp paginate(query, page, nil), do: paginate(query, page, @page_size)
  defp paginate(query, nil, page_size), do: paginate(query, @page, page_size)

  defp paginate(query, page, page_size) do
    offset = page_size * (page - 1)

    query
    |> offset(^offset)
    |> limit(^page_size)
  end

  defp sort(query, nil), do: sort(query, desc: :inserted_at)

  defp sort(query, field) do
    from query, order_by: ^field
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id, params \\ %{}) do
    build_query(params, %{})
    |> Repo.get!(id)
  end

  def with_comments(query \\ Post) do
    query
    |> preload(comments: :author)
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(%User{} = user, attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:author, user)
    |> Repo.insert()
    |> notify_subscribers(:post_created)
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers(:post_updated)
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
    |> notify_subscribers(:post_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
    |> Comment.changeset()
  end

  def add_comment(%User{} = user, %Post{} = post, comment) do
    Repo.transaction(fn ->
      comment =
        Comment.changeset(%Comment{}, %{"content" => comment})
        |> Ecto.Changeset.put_assoc(:author, user)
        |> Repo.insert!()

      PostComment.changeset(%PostComment{}, %{post_id: post.id, comment_id: comment.id})
      |> Repo.insert()

      notify_subscribers({:ok, Repo.preload(post, :comments)}, :post_commented_on)
    end)
  end

  @doc """
  Likes a post
  """
  def like_post(%User{} = user, %Post{} = post) do
    %Reaction{}
    |> Reaction.changeset(%{user_id: user.id, post_id: post.id})
    |> Repo.insert()

    notify_subscribers({:ok, Repo.preload(post, :reactions)}, :post_liked)
  end

  @doc """
  Likes a post
  """
  def unlike_post(%User{} = user, %Post{} = post) do
    query = from(r in Reaction, where: r.user_id == ^user.id and r.post_id == ^post.id)

    case Repo.one(query) do
      nil ->
        {:ok, :none_found_so_done}

      reaction ->
        Repo.delete(reaction)

        notify_subscribers({:ok, Repo.preload(post, :reactions)}, :post_unliked)
    end
  end

  @pubsub Sociality.PubSub
  @topic "posts"
  defp topic, do: @topic
  # defp topic(post_id), do: "#{topic()}:#{to_string(post_id)}"

  def subscribe() do
    Phoenix.PubSub.subscribe(@pubsub, topic(), link: true)
  end

  def notify_subscribers({:ok, %Post{} = post} = payload, event) do
    Phoenix.PubSub.broadcast(@pubsub, topic(), {__MODULE__, [:posts, event], post})

    payload
  end

  def notify_subscribers(payload, _) do
    payload
  end
end
