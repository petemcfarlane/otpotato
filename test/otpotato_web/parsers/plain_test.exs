defmodule OTPotatoWeb.Plug.Parsers.PlainTest do
  use OTPotatoWeb.ConnCase, async: true

  alias OTPotatoWeb.Plug.Parsers.Plain

  test "parse/4 with valid CSV" do
    conn =
      Plug.Test.conn(:post, "/", """
      "soil_type","x","y","w","l"
      chalk,0,0,2.5,1.8
      loam,5,3,3.0,3.0
      """)
      |> put_req_header("content-type", "text/csv")

    {:ok, params, _conn} =
      Plain.parse(conn, "text", "csv", %{}, [])

    assert params["_csv"] == [
             %{"soil_type" => "chalk", "x" => "0", "y" => "0", "w" => "2.5", "l" => "1.8"},
             %{"soil_type" => "loam", "x" => "5", "y" => "3", "w" => "3.0", "l" => "3.0"}
           ]
  end

  test "parse/4 with invalid CSV returns empty list" do
    conn =
      Plug.Test.conn(:post, "/", "invalid csv")
      |> put_req_header("content-type", "text/csv")

    assert {:ok, %{"_csv" => []}, _conn} = Plain.parse(conn, "text", "csv", %{}, [])
  end
end
