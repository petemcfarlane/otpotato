defmodule OTPotatoWeb.PlantingPlanControllerTest do
  use OTPotatoWeb.ConnCase

  alias OTPotato.{Plant, Repo}

  setup do
    {:ok, garden = %{beds: [bed]}} =
      OTPotato.Gardens.create([
        %{length: 2, width: 2, origin_x: 0, origin_y: 0, soil_type: :loam}
      ])

    Repo.insert(%Plant{name: "spinach", soil_types: [:clay], benefits_from: []})
    Repo.insert(%Plant{name: "potato", soil_types: [:chalk], benefits_from: []})
    Repo.insert(%Plant{name: "tomato", soil_types: [:sandy], benefits_from: []})

    {:ok, garden: garden, bed: bed}
  end

  describe "create/2" do
    test "with valid data", %{bed: %{id: bed_id}} do
      conn =
        build_conn()
        |> put_req_header("content-type", "text/csv")
        |> post("/api/planting-plans", """
        "bed-id","plant","area"
        #{bed_id},spinach,0.5
        #{bed_id},potato,1.2
        #{bed_id},tomato,0.3
        """)

      assert %{
               "planting_plan" => %{
                 "id" => _,
                 "entries" => [
                   %{
                     "bed-id" => ^bed_id,
                     "plant" => "spinach",
                     "area" => 0.5
                   },
                   %{
                     "bed-id" => ^bed_id,
                     "plant" => "potato",
                     "area" => 1.2
                   },
                   %{
                     "bed-id" => ^bed_id,
                     "plant" => "tomato",
                     "area" => 0.3
                   }
                 ]
               }
             } = json_response(conn, 201)
    end

    test "with invalid request body returns an error" do
      conn =
        build_conn()
        |> put_req_header("content-type", "text/csv")
        |> post("/api/planting-plans", """
        "bed-id","foo"
        x,y,z,invalid
        """)

      assert json_response(conn, 422) == %{
               "error" => "Invalid plan data, expected {bed-id, plant, area}"
             }
    end

    test "should have at least one entry" do
      conn =
        build_conn()
        |> put_req_header("content-type", "text/csv")
        |> post("/api/planting-plans", """
        "bed-id","plant","area"
        """)

      assert json_response(conn, 422) == %{
               "error" => ["entries: at least one entry is required"]
             }
    end

    test "beds must exist" do
      conn =
        build_conn()
        |> put_req_header("content-type", "text/csv")
        |> post("/api/planting-plans", """
        "bed-id","plant","area"
        #{Ecto.UUID.generate()},spinach,0.5
        """)

      assert json_response(conn, 422) == %{
               "error" => ["entries: bed(s) must exist"]
             }
    end

    test "beds must belong to the same garden", %{bed: %{id: bed_id}} do
      {:ok, %{beds: [bed2]}} =
        OTPotato.Gardens.create([
          %{length: 2.0, width: 2.0, origin_x: 0, origin_y: 0, soil_type: :loam}
        ])

      conn =
        build_conn()
        |> put_req_header("content-type", "text/csv")
        |> post("/api/planting-plans", """
        "bed-id","plant","area"
        #{bed_id},spinach,0.5
        #{bed2.id},potato,1.2
        """)

      assert json_response(conn, 422) == %{
               "error" => ["entries: beds must belong to the same garden"]
             }
    end

    test "total of area of plants must not exceed area of bed", %{bed: %{id: bed_id}} do
      conn =
        build_conn()
        |> put_req_header("content-type", "text/csv")
        |> post("/api/planting-plans", """
        "bed-id","plant","area"
        #{bed_id},spinach,2.1
        #{bed_id},potato,2.0
        """)

      assert json_response(conn, 422) == %{
               "error" => ["entries: total of area of plants must not exceed area of bed"]
             }
    end

    test "plants must exist", %{bed: %{id: bed_id}} do
      conn =
        build_conn()
        |> put_req_header("content-type", "text/csv")
        |> post("/api/planting-plans", """
        "bed-id","plant","area"
        #{bed_id},okra,0.5
        """)

      assert json_response(conn, 422) == %{
               "error" => "Plant not found: okra"
             }
    end
  end
end
