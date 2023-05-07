defmodule UserTest do
  use ExUnit.Case
  import Ecto.Query
  import Ecto

  alias TestEcto.{Repo, User, Post}

  # すでにEcto.Adapters.SQL.Sandbox.mode(TestEcto.Repo, :manual)が設定されていて、TestEcto.DataCaseを使用していない場合、DBConnection.OwnershipErrorの原因は、データベース接続の所有権がテストプロセスに正しく設定されていないことです。
  # このsetupブロックは、各テストケースが実行される前に実行されます。Ecto.Adapters.SQL.Sandbox.checkout/1関数を使用してデータベース接続をチェックアウトし、Ecto.Adapters.SQL.Sandbox.mode/2関数を使用してテストプロセスに所有権を付与します。
  # このsetupブロックを各テストファイルに追加することで、データベース接続の所有権が適切に設定され、DBConnection.OwnershipErrorが発生しなくなります。
  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    :ok
  end

  describe "user" do
    test "creates correctly" do
      changeset = User.changeset(%User{}, %{name: "foo"})
      {:ok, user} = Repo.insert(changeset)

      inserted_user = Repo.one(User)
      assert inserted_user.id == user.id
      assert inserted_user.name == user.name
    end

    test "creates correctly with posts" do
      User.create_with_posts(%{name: "foo", posts: [%{title: "t", body: "b"}]})

      count = Repo.one(from(u in User, select: count(u.id)))
      inserted_user = Repo.one(User)
      inserted_post = Repo.one(Post)
      assert count == 1
      assert inserted_user.id != nil
      assert inserted_post.user_id != nil
      assert inserted_post.title == "t"
    end

    test "adds post for existing user and updates post" do
      {:ok, user} = User.changeset(%User{}, %{name: "foo"}) |> Repo.insert()

      user
      |> build_assoc(:posts, %{title: "t", body: "b"})
      |> Repo.insert()

      inserted_post = Repo.one(Post)
      assert inserted_post.user_id == user.id
      assert inserted_post.title == "t"
      assert inserted_post.body == "b"

      # then change body

      inserted_post
      |> Post.changeset(%{body: "changed"})
      |> Repo.update()

      updated_post = Repo.one(Post)
      assert updated_post.user_id == user.id
      assert updated_post.id == inserted_post.id
      assert updated_post.body == "changed"
    end

    test "adds new post and updates existing post" do
      User.create_with_posts(%{name: "foo", posts: [%{title: "t", body: "b"}]})

      user = Repo.one(User)
      existing_post = Repo.one(Post)

      changeset_of_exiting = existing_post |> Post.changeset(%{body: "changed"})

      User.update_with_posts(user, %{
        posts: [changeset_of_exiting, %{title: "new t", body: "new b"}]
      })

      inserted_posts = Repo.all(Post)
      first_post = Enum.at(inserted_posts, 0)
      second_post = Enum.at(inserted_posts, 1)
      assert Enum.count(inserted_posts) == 2
      assert first_post.id == existing_post.id
      assert first_post.body == "changed"
      assert second_post.body == "new b"
    end
  end

  test "greets the world" do
    assert TestEcto.hello() == :world
  end
end
