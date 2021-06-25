defmodule TorrentDissect.Test do
  require Assertions
  use ExUnit.Case, async: true

  test "parses filenames" do
    input = File.read!("test/fixtures/input.json") |> Jason.decode!
    output = File.read!("test/fixtures/output.json") |> Jason.decode!(keys: :atoms)
    for i <- 0..Enum.count(output) do
      expected = Enum.at(output, i)
      Assertions.assert_maps_equal(expected, Enum.at(input, i) |> TorrentDissect.parse, Map.keys(expected))
    end
  end
end
