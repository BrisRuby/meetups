# intro
  - me
  - forrest
  - topics
    - web frameworks
    - persistence patterns

# rails
  - from the outside: learning curve: not overly small, but not too large either
  - from the inside: the lazy option
  - all magic comes at a price

# APIs
  - overview
    - resources
    - versioning
    - content negotiation
  - just do it
  - web as a platform (Google+, etc. breaking the web)
  - mobile apps, CLI, third-party integrations
  - forces you to think about your architecture
  - mildly to highly incompatible with a web app (in the same repo)
  - but, buyer beware (not all rainbows and unicorns)

# APIs in Rails
  - mixed content negotiation is bad (show controller with `responds_to`)
  - Rails is overkill for an API
  - compare middleware in Rails vs. Rails::API
  - rails-api exists, but why not try something new?
  - everything is not a nail, so don't keep using a hammer

# enter: grape
  - rack-based
  - show code

# rack request specs
  - can test like this: (show code)
  - talk about idea for unit testing

# persistence patterns
  - activerecord
  - what else?
  - repository pattern

# active record
  - design pattern (show diagram)
  - what would DHH do?
  - now do the opposite (test::unit v. rspec, etc.)
  - show code
  - works, in theory (like communism)
  - breaks srp (w/ code)
    - https://gist.github.com/ltw/836525
    - not advocating POROs
  - hard to test (w/ code)
  - schema drives model, not the other way around (w/ code)
  - there is a better way...

# repository pattern
  - just another design pattern (show diagram)
  - show code
  - single responsibility
  - test in isolation
  - model is the source of truth
  - ruby implementations
    - curator
    - minimapper
    - datamappify (not datamapper)
    - edr

# what does this give us?
  - lightning fast specs
  - less magic
