defmodule Noaa.Cli do 
    @default_location "KLGA"

    @moduledoc """
    Handle command line parsing and the dispatch to various functions that end up generating a list
    of the last environmantal data gathered by NOAA for the specified region.
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
    """
    def parse_args(argv) do
        OptionParser.parse(argv, switches: [help: :boolean],
                                         aliases: [h: :help])
        |> args_to_internal_representation()
    end
        
    def args_to_internal_representation({_,[station_id],_}) do
        station_id
    end

    def args_to_internal_representation({[help: true], [], []}) do
        :help        
    end

    def args_to_internal_representation(_) do
        @default_location
    end

    def process(:help) do
        IO.puts """
        usage: noaa [ station_id | #{@default_location} ]
        """
        System.halt(0)
    end

    def process(station_id) do
        Noaa.NoaaData.fetch(station_id)
        |> decode_response

    end

    def decode_response({:ok, data}), do: data
    def decode_response({:error, error}) do
        IO.puts "Error fetching data from weather.gov: #{error["message"]}"
        System.halt(2)
    end
end