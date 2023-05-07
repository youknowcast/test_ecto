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
