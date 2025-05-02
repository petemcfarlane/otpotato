# OTPotato
OTPotato is a HTTP API for creating and scoring planting plans for vegetable gardens.

## Installation

To start your OTPotato server:

  * Run `mix setup` to install and setup dependencies
    (this should create a local database and import the background plant knowledge)
  * Start OTPotato API with `mix phx.server`

The default dev API server is available at `http://localhost:4000`

## Livebook

There is an accompanying Livebook, at `~/.otpotato.livemd`. To run this, please download and install [Livebook](https://livebook.dev/), then open this file. You should see further instructions for how to install dependencies and test the endpoints.

## Curl instructions

Alternatively, if you can't use the Livebook you can test the endpoints with curl:

```bash
# Create a garden
curl -X POST http://localhost:4000/api/gardens \
 -H "Accept: application/json" \
 -H "Content-Type: text/csv" \
 -d "\"soil_type\",\"x\",\"y\",\"w\",\"l\"
chalk,0,0,2.5,1.8
loam,5,3,3.0,3.0"
```

```bash
# Create a planting plan
curl -X POST http://localhost:4000/api/planting-plans \
 -H "Accept: application/json" \
 -H "Content-Type: text/csv" \
 -d "\"bed-id\",\"plant\",\"area\"
{:bed_id},spinach,3
{:bed_id},onion,1.5"
```

```bash
# Score a planting plan
curl http://localhost:4000/api/planting-plans/{:planting_plan_id}/score
```
