defmodule TestEcto.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias TestEcto.{Repo, User, Post}

  schema "posts" do
    field(:title, :string)
    field(:body, :string)
    belongs_to(:user, TestEcto.User)

    timestamps()
  end

  @spec create_or_update_with_user(%{:user_id => integer, optional(:id) => integer()}) ::
          {:ok, %TestEcto.Post{}} | {:error, %Ecto.Changeset{}}
  @doc """
  Creates or updates a `Post` associated with a `User`.

  This function first tries to fetch a user with the given `:user_id` from the `attrs` map.
  If the user is found, it checks if an `:id` is present in the `attrs` map.

  If an `:id` is present, it fetches the corresponding post with the given `:user_id` and `:id`
  and updates it with the provided attributes. Otherwise, it creates a new post associated with
  the user using the provided attributes.

  ## Examples

      iex> create_or_update_with_user(%{user_id: 1, title: "New Post", body: "Post content"})
      {:ok, %Post{}}

      iex> create_or_update_with_user(%{user_id: 1, id: 1, title: "Updated Post", body: "Updated content"})
      {:ok, %Post{}}

  """
  def create_or_update_with_user(attrs) do
    user = Repo.get(User, Map.fetch!(attrs, :user_id))

    case Map.fetch(attrs, :id) do
      {:ok, id} ->
        post = Repo.one(from(p in Post, where: [user_id: ^user.id, id: ^id]))

        post
        |> changeset(Map.from_struct(attrs))
        |> Repo.update()

      _ ->
        Ecto.build_assoc(user, :posts)
        |> changeset(attrs)
        |> Repo.insert()
    end
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
    |> assoc_constraint(:user)
  end
end
