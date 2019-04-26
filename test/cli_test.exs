defmodule NoaaTest do
  use ExUnit.Case
  doctest Noaa

  import Noaa.Cli, only: [parse_args: 1]

  test ":help returned by option parsing with -h and --help options" do
      assert parse_args(["-h"]) == :help
      assert parse_args(["--help"]) == :help
  end

  test "one value returned if one value given" do
      assert parse_args(["station_id"]) == "station_id"
  end

  test "default value KLGA returned if no value given" do
      assert parse_args([]) == "KLGA"
  end

end
