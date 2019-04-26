defmodule NoaaTest do
  use ExUnit.Case
  doctest Noaa

  test "greets the world" do
    assert Noaa.hello() == :world
  end
end
