# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     OTPotato.Repo.insert!(%OTPotato.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias OTPotato.{Repo, Plant}

IO.puts("Seeding plants...")

# read and parse file background-knowledge.json
# note - using the functions with ! so will raise an error if the file isn't readable or the JSON isn't valid!
json_file = File.read!("#{__DIR__}/../seed_data/background-knowledge.json")
json_data = Jason.decode!(json_file)

Repo.transaction(fn ->
  # truncate any previous plants
  Repo.delete_all(Plant)

  # insert plants into database
  # not really doing any file validation right now, but assuming as the data comes from a seed file, rather than user input, this _should_ be correct.
  for plant <- json_data do
    Repo.insert!(%Plant{
      name: plant["name"],
      # below we map the soil types from strings to atoms, using to_existing_atom/1 to avoid allowing any old strings
      soil_types: plant["soil_types"] |> Enum.map(&String.to_existing_atom/1),
      benefits_from: plant["benefits_from"]
    })
  end
end)
