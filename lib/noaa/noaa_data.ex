defmodule Noaa.NoaaData do
    @moduledoc """
    Handle fetching data from weather.gov with a given `station id`. Respond with a map of environmental data.
    """
    require Logger

    @doc """
    Fetch data from `station_id` and report with a map.

    ## Examples

        iex> Noaa.NoaaData.fetch("KLGA")
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

    def fetch(station_id) do
        noaa_url(station_id)
        |> HTTPoison.get
        |> handle_response
    end

    @noaa_station_url Application.get_env(:noaa, :noaa_station_url)

    defp noaa_url(station_id) do
        "#{@noaa_station_url}#{station_id}"
    end

    defp handle_response({_, %{status_code: status_code, body: body}}) do
        Logger.info("Got response: status code=#{status_code}")
        Logger.debug(fn -> inspect(body) end)

        check_for_error(status_code, body)
    end

    defp check_for_error(200, body), do: {:ok, body |> parse_the_xml}
    defp check_for_error(_, body), do: {:error, body}

    defp parse_the_xml(body) do
        %{
            station_id: body |> SweetXml.xpath(SweetXml.sigil_x"//station_id/text()") |> to_string,
            location: body |> SweetXml.xpath(SweetXml.sigil_x"//location/text()") |> to_string,
            temp_c: body |> SweetXml.xpath(SweetXml.sigil_x"//temp_c/text()") |> to_string,
            temp_f: body |> SweetXml.xpath(SweetXml.sigil_x"//temp_f/text()") |> to_string,
            windchill_c: body |> SweetXml.xpath(SweetXml.sigil_x"///windchill_c/text()") |> to_string,
            weather: body |> SweetXml.xpath(SweetXml.sigil_x"//weather/text()") |> to_string,
            relative_humidity: body |> SweetXml.xpath(SweetXml.sigil_x"//relative_humidity/text()") |> to_string,
            wind_mph: body |> SweetXml.xpath(SweetXml.sigil_x"//wind_mph/text()") |> to_string
        }
    end

end