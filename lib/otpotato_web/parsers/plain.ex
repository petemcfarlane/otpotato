defmodule OTPotatoWeb.Plug.Parsers.Plain do
  @moduledoc """
  Parses plain text and CSV content types.
  """

  alias NimbleCSV.RFC4180, as: CSV

  @behaviour Plug.Parsers

  def init(opts), do: opts

  def parse(conn, "text", "csv", _headers, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)

    csv_data =
      CSV.parse_string(body, skip_headers: false)
      |> Enum.reduce({[], []}, fn row, {rows, headers} ->
        case headers do
          [] ->
            {[], row}

          _ ->
            {[Enum.zip(headers, row) |> Map.new() | rows], headers}
        end
      end)
      |> elem(0)
      |> Enum.reverse()

    {:ok, %{"_csv" => csv_data}, conn}
  end

  # This will match "text/*" content types
  def parse(conn, "text", _subtype, _headers, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    {:ok, %{"_plain" => body}, conn}
  end

  def parse(_conn, _type, _subtype, _headers, _opts) do
    {:next, %{}}
  end
end
