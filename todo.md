- [x] Create Phoenix webapp. Note: could have just used Cowboy or Bandit and Plug, Phoenix is perhaps a little heavy for a simple API, but I customised it without assets/HTML. The bonus is it's got Ecto DB adapter built in, and it's compatible with [Open API Spex](https://hexdocs.pm/open_api_spex/readme.html) which I might use for docs.

  mix phx.new ./ --app otpotato --module OTPotato --no-assets --no-html --no-live --no-mailer --binary-id --database postgres
- [x] Create a data model
- [x] Create DB migrations
  I opted to use UUIDs for primary keys as this is potentially more future-proof. Did have to modify the Repo config for this, and set the @primary_key attribute in each schema to autogenerate.
  I've left out timestamps for now for the sake of MVP simplicity!
- [x] Use seeds to import the background knowledge
- [x] Create an API endpoint for creating a new garden, by accepting a collection of vegetable bed descriptions. The bed descriptions will be lines of a CSV, one line per bed. The return value should either acknowledge the created beds, or an error if the bed descriptions cannot be processed.
- [x] Create an API endpoint for storing a planting plan. The planting plan will consist of a CSV file, one line per plant type. The return value should be either acknowledge the created plan, or an error if the planting plan cannot be processed.
- [x] Create an API endpoint to get a score for a plan, given a plan identifier. The score is an average of the scores for each bed in the plan. A single bed’s score is calculated by:
the base score is 10
add one for each plant that is planted alongside a beneficial companion
add one if the bed is fully planted (i.e. the area of the bed equals the summed areas of the planted vegetables)
deduct one for each plant that is not planted in its preferred soil type
any bed with an error automatically returns 0
- [ ] Check am I happy with the test coverage?
- [ ] Consider security, resilience, performance, monitoring
- [ ] Is it documented thoroughly?
- [ ] Add Open API Spex - nice to have
- [ ] Ponder future iterations: In the MVP, we're not going to worry about the time that plants are sown or harvested, though that will likely be a feature we would want to add in future.
Should we use a plant identifier or is the plant name good enough?

See more, coped from the end of the Livebook:


Throughout the project I had a few thoughts of things I might to differently, given more time:

* Plants don't have an id in the background knowledge file, but when I created the model I gave them a generated uuid. This caused more issues because the other endpoints only give/return a plant name, and for some of the logic I have to look up the plant by name to get the id.
* The API response could do with some more thought, I just returned a similar payload to the request but with generated IDs. Perhaps the create planting plan endpoint could also return the score immediately?
* The API can only create new gardens/planting plans - it'd be very useful to be able to edit existing gardens/plans I'm sure.
* The CSV API parsing is slightly non-standard, working with JSON would have been easier with Phoenix out-the-box.
* I really wanted to add Open API specs, using [open_api_spex](https://hexdocs.pm/open_api_spex/3.4.0/readme.html) but I didn't have time. Hopefully the interactive nature of the Livebook has been an interesting alternative.
* I'm fairly happy with the test coverage - I added integration tests at the Controller and Context layer - sometimes I think it's safer to not mock out the data layer. But if performance was an issue it's something I'd consider. Also using Ecto test factories would improve the code readability.
* It'd be nice to add a UI to this app - being able to view the area of plants would be easier to see how much space we have left in each bed.
* Using gen AI to generate a recommended planting plan, for the user to tweak, based on some params, e.g. garden dimensions, soil types.
* Right now there is no authentication system in this app - anyone can create gardens and planting plans for any other garden. Using an auth system in front to make sure that users can only plant in their own gardens would be a good idea! This could be modelled in the DB by adding a user_id/owner_id/tenant_id column to the gardens table.


