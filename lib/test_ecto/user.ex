defmodule TestEcto.User do
  alias TestEcto.User
  use Ecto.Schema
  import Ecto.Changeset

  alias TestEcto.{Repo, Post}

  schema "users" do
    field(:name, :string)
    has_many(:posts, TestEcto.Post, on_delete: :delete_all)

    timestamps()
  end

  def create_with_posts(attrs) do
    %User{}
    |> changeset(attrs)
    |> cast_assoc(:posts, with: &Post.changeset/2)
    |> Repo.insert()
  end

  def update_with_posts(user, attrs) do
    updated_attrs = to_map(attrs)

    user
    |> Repo.preload(:posts)
    |> changeset(updated_attrs)
    |> cast_assoc(:posts, with: &Post.changeset/2)
    |> Repo.update()
  end

  # Changeset, Struct, Map をなんでも受け付けるようにする
  defp to_map(%{posts: posts} = attrs) do
    %{attrs | posts: Enum.map(posts, &to_map_or_struct/1)}
  end

  defp to_map_or_struct(%Ecto.Changeset{} = changeset),
    do: to_map_or_struct(apply_changes(changeset))

  defp to_map_or_struct(%TestEcto.Post{} = post), do: Map.from_struct(post)
  defp to_map_or_struct(map), do: map

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
