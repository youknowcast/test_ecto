defmodule TestEctoTest do
  use ExUnit.Case
  doctest TestEcto

  test "greets the world" do
    assert TestEcto.hello() == :world
  end
end
