- [ ] Create Phoenix webapp. Note: could have just used Cowboy or Bandit and Plug, Phoenix is perhaps a little heavy for a simple API, but I customised it without assets/HTML. The bonus is it's got Ecto DB adapter built in, and it's compatible with [Open API Spex](https://hexdocs.pm/open_api_spex/readme.html) which I might use for docs.
- [ ] Create a data model
- [ ] Create DB migrations
- [ ] Script (mix task?) to import the background knowledge
- [ ] Create an API endpoint for creating a new garden, by accepting a collection of vegetable bed descriptions. The bed descriptions will be lines of a CSV, one line per bed. The return value should either acknowledge the created beds, or an error if the bed descriptions cannot be processed.
- [ ] Create an API endpoint for storing a planting plan. The planting plan will consist of a CSV file, one line per plant type. The return value should be either acknowledge the created plan, or an error if the planting plan cannot be processed.
- [ ] Create an API endpoint to get a score for a plan, given a plan identifier. The score is an average of the scores for each bed in the plan. A single bed’s score is calculated by:
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