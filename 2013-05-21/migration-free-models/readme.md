# Full Text Search & Migration Free Models

**Dave Kinkead, 21 May 2013**

This lightning talk will involve a bit of live coding of a single model [twitter clone](twatter/).

Now SQL Migrations are pretty cool

	rails g scaffold twats author:string status:text
	rake db:migrate

SQL keyword searches aren't horrible either.  Actually, they are pretty shit.

	Twat.create author:"Montgomery Burns", status:"Excellent Smithers"
	Twat.where("status like '%burns smithers%'")

[Elasticsearch](http://www.elasticsearch.org/) & [Tire](https://github.com/karmi/tire) to the rescue!

	Tire::Model::Search gives us the search API
	Tire::Model::Callbacks gives us ActiveModel integration (auto-indexing on create/update/destroy)

But what's the point of keeping duplicate data?  Why not One True Source to rule them all....

	require 'tire'

	class Twat
		include Tire::Model::Persistence

		property :author
		property :status
		property :created_on, :default => DateTime.now
	end

Wouldn't it be nice if we didn't even need to declare properties?  Why not instantiate a model with any hash?

Dat dada Dah....... tire/models/dynamic_persistence

	require 'tire'
	require 'tire/model/dynamic_persistence'

	class Twat 
	  include Tire::Model::Persistence
	  include Tire::Model::DynamicPersistence
	end


The ruby gem is well behind the github master so use karmi/tire-contrib for now

Use Cases:

- Full text search required
- Any document/NoSQL situation _a la_ Mongo, Couch
- Read heavy, write light.

Gotchas (for DynamicPersistence):

- mass assignment
- missing method (should return nil but doesn't)








