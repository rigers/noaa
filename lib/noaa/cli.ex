defmodule Noaa.Cli do 
    @default_location "KLGA"

    @moduledoc """
    Handle command line parsing and the dispatch to various functions that end up generating a list
    of the last environmantal data gathered by NOAA for the specified region.
    """

    @doc """
    `argv` can be -h or --help, which returns help.
    Otherwise it is a NOAA `station_id`. Default argument is station id `KLGA`

    Returns a map of environmental data pertaining to the `station_id`. Default KLGA

    ## Examples

        iex> Noaa.Cli.main(["KLGA"])
        %{
        location: "New York, La Guardia Airport, NY",
        relative_humidity: "27",
        station_id: "KLGA",
        temp_c: "13.3",
        temp_f: "56.0",
        weather: "Partly Cloudy",
        wind_mph: "17.3",
        windchill_c: "11"
        }

    """
    def main(argv) do
        argv
        |> parse_args()
        |> process
        |> IO.inspect
    end

    @doc """
    `argv` can be -h or --help, which returns help.
    Otherwise it is a NOAA station_id. 

    Returns a string of the passed `station_id`.

    ## Examples

        iex> Noaa.Cli.main(["KLGA"])
        "KLGA"

        iex> Noaa.Cli.main(["-h | --help"])
        :help

    """
    def parse_args(argv) do
        OptionParser.parse(argv, switches: [help: :boolean],
                                         aliases: [h: :help])
        |> args_to_internal_representation()
    end
        
    defp args_to_internal_representation({_,[station_id],_}) do
        station_id
    end

    defp args_to_internal_representation({[help: true], [], []}) do
        :help        
    end

    defp args_to_internal_representation(_) do
        @default_location
    end

    defp process(:help) do
        IO.puts """
        usage: noaa [ station_id | #{@default_location} ]
        """
        System.halt(0)
    end

    defp process(station_id) do
        Noaa.NoaaData.fetch(station_id)
        |> decode_response

    end

    defp decode_response({:ok, data}), do: data
    defp decode_response({:error, error}) do
        IO.puts "Error fetching data from weather.gov: #{error["message"]}"
        System.halt(2)
    end
end