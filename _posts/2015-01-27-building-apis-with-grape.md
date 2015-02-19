---
layout: post
title:  Building APIs with Grape
author: Tom Ridge
status: published
meetup: Jan 2015
---
# Building APIs with Grape

Grape is a micro-framework for building APIs with Ruby. It enables you to quickly build and iterate on your API alongside your existing Rails or Sinatra application, as well as on it's own as a standalone API.


It gives you versioning, entities, validations, and importantly easy ways to document your API as you build it (please do this last thing in particular) all out of the box. For the extra stuff you need, there's a metric tonne of 3rd-party gems available to utilise.


Let's take a bit of a look at how you might build an API using grape as a standalone product:


Getting started is, as always pretty easy in Ruby land, just add grape to your gemfile

```ruby

# Gemfile

gem 'grape'

```

If you find yourself wanting to mount the API alongside your existing Rails or Sinatra application, take a quick look at the below samples for working with the router:

```ruby
# Rails

# config/routes.rb

mount AwesomeCompany::API => '/'

# Using rails 4? youll need the hashie rails gem if working with activerecord so you can bypass strong params and use grapes params validation instead

```

```ruby
# Sinatra

# config.ru

use Rack::Session::Cookie
run Rack::Cascade.new [API, Web]
```


For our standalone application, our setup could not be simpler

```ruby

# config.ru

run AwesomeCompany::API

```	


So now that we have grape installed and have our application ready and waiting to go, lets get started defining some resources and actually building our API. Whilst grape doesn't have any strong opinions on how you should structure your code, I personally prefer to house my API files in a controller directory, so let's start there:


```ruby

# /lib/controllers/api/base.rb

module AwesomeCompany
  module API
    class Base < Grape::API
      prefix :api # set the url prefix
      format :json # define the format
      mount AwesomeCompany::API::V1::Base
    end
  end
end

``` 

Our base file's job is purely to declare some ground rules for the different versions of our API and to make available those versions if it receives an appropriate request.
Let's dive a little deeper now, and take a look at how our API can make some resources and end-points available for our users to consume.


```ruby
# /lib/controllers/api/v1/base.rb

module AwesomeCompany
  module API
    module V1
      class Base < Grape::API
        mount AwesomeCompany::API::V1::Companies      
        mount AwesomeCompany::API::V1::Employees              
      end
    end
  end
end  

# /lib/controllers/api/v1/companies.rb

module AwesomeCompany
  module API
    module V1
      class Companies < Grape::API
      end
    end
  end
end  

``` 

So all we've done above is simply define which resources are available as part of the first version of our API. Currently our companies resource isn't doing much, let's setup an end-point so we can retrieve a list of companies.


```ruby

# /lib/controllers/api/v1/companies.rb

module AwesomeCompany
  module API
    module V1
      class Companies < Grape::API
      	params do
      	  optional :name, type: String, desc: 'Company name you wish to filter on'
      	end
      	resource :companies do
      	  desc "Retrieve a list of Companies"
      	  get do
      	  	if params[:name]
      	  	  Company.where(name: params[:name])
      	  	else
      	  	  Company.all
      	  	end  
      	  end
      	end
      end
    end
  end
end  

``` 

We've setup an optional parameter, `name` which enables us to filter on our company. Ugly implementation aside, we've also been able to document as we go, and return all companies if no params were supplied. In addition to optional parameters, Grape also has options for required parameters with either custom, or inbuilt validations. For more fine grained validations, its even possible to validate on optional nested attributes if supplied, like so:

``` ruby

...
      params do
        requires :name, type: String, desc: 'Name of company'

        optional :contacts, type: Array, desc: 'List of contacts. Must be 1 or more.' do
          requires :first_name, type: String, desc: 'Contact First Name'
          requires :last_name, type: String, desc: 'Contact Last Name'
          optional :email_address, type: String, desc: 'Contact Email'
        end
      end


...

```


What if we'd like to control what data our end users get back though? Especially if we have some confidential information stored. Well, that's where entities come in, grape comes with entity support and whilst you're free to utilise RABL and ActiveModelSerializers, we're going to be utilising the `grape-entity` gem. 


Simply add `grape-entity` to your Gemfile, and let's go ahead and create our first entity. 


```ruby

# /lib/controllers/api/v1/entities/company.rb

module AwesomeCompany
  module API
    module V1
      module Entities
        class Company < Grape::Entity
          expose :name, documentation: { type: 'String', desc: 'Company Name'}
          expose :address, documentation: { type: 'String', desc: 'Company Address'}
          expose :phone, documentation: { type: 'String', desc: 'Company Phone'}                  
        end
      end
    end
  end
end

```

We now wrap our data with a call to `present` and give it our entity object to ensure what we're only sending back what we want to.


```ruby

# /lib/controllers/api/v1/companies.rb

module AwesomeCompany
  module API
    module V1
      class Companies < Grape::API
      	params do
      	  optional :name, type: String, desc: 'Company name you wish to filter on'
      	end
      	resource :companies do
      	  desc "Retrieve a list of Companies"
      	  get do
      	  	companies = CompanyQuery.new(params)
      	  	present :company, companies, with: AwesomeCompany::API::V1::Entities::Company
          # -> { company: { name: 'Nigerian Royalty Incorporated', phone: '555-555', address: '55 Nigeria, Nigeria St, Nigeria' } }            
      	  	
      	  end
      	end
      end
    end
  end
end  

``` 

We've only really scratched the surface of what grape offers, their documentation is simply fantastic, so now that you have an API, have a dive into [their README](https://github.com/intridea/grape) and see what else you can get up to



