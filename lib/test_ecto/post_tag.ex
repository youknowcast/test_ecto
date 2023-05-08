defmodule TestEcto.PostTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "post_tags" do
    belongs_to(:tag, TestEcto.Tag)
    belongs_to(:post, TestEcto.Post)

    timestamps()
  end

  def changeset(post_tag, _attrs) do
    post_tag
  end
end
