defmodule OTPotatoWeb.GardenControllerTest do
  use OTPotatoWeb.ConnCase

  describe "create/2" do
    test "with valid data creates a garden" do
      conn =
        build_conn()
        |> put_req_header("content-type", "text/csv")
        |> post("/api/gardens", """
        "soil_type","x","y","w","l"
        chalk,0,0,2.5,1.8
        loam,5,3,3.0,3.0
        """)

      assert %{
               "garden" => %{
                 "beds" => [
                   %{
                     "length" => "1.8",
                     "width" => "2.5",
                     "origin_x" => 0,
                     "origin_y" => 0,
                     "soil_type" => "chalk"
                   },
                   %{
                     "length" => "3.0",
                     "width" => "3.0",
                     "origin_x" => 5,
                     "origin_y" => 3,
                     "soil_type" => "loam"
                   }
                 ]
               }
             } = json_response(conn, 201)
    end

    test "with invalid data returns an error" do
      conn =
        build_conn()
        |> put_req_header("content-type", "text/csv")
        |> post("/api/gardens", """
        "soil_type","x","y"
        chalk,0,0
        loam,5,3
        """)

      assert json_response(conn, 422) == %{
               "error" => "Invalid bed data, expected {x, y, l, w, soil_type}"
             }
    end

    test "with no beds returns an error" do
      conn =
        build_conn()
        |> put_req_header("content-type", "text/csv")
        |> post("/api/gardens", """
        "soil_type","x","y","w","l"
        """)

      assert json_response(conn, 422) == %{
               "error" => ["beds: at least one bed is required"]
             }
    end

    test "with overlapping beds returns an error" do
      conn =
        build_conn()
        |> put_req_header("content-type", "text/csv")
        |> post("/api/gardens", """
        "soil_type","x","y","w","l"
        chalk,0,0,2.5,1.8
        loam,1,1,2.5,1.8
        """)

      assert json_response(conn, 422) == %{
               "error" => ["beds: beds must not overlap"]
             }
    end

    test "with no CSV body returns an error" do
      conn =
        build_conn()
        |> post("/api/gardens")

      assert json_response(conn, 422) == %{
               "error" =>
                 "Invalid request, please provide a garden in CSV format, e.g. \"x,y,l,w,soil_type\". Don't forget to set the ContentType header to \"text/csv\"."
             }
    end
  end
end
