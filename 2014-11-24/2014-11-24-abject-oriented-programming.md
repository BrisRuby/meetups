---
layout: post
title:  Abject Oriented Programming for the Rubyist
meetup: Nov 2014
status: archive
---

Abject Oriented Programming (Abject-O) is a set of best practices that promotes code reuse and ensures programmers are producing code that can be used in production for a long time.  For too long, the beauty of ruby has been sullied by the misguided follies of Gamma & his cronies.  Abject rectifies this by finally bringing Abject-O to Ruby in a snapply DSL.

These are some notes on Ruby meta-programming I gave at a recent [BrisRuby meetup](http://meetup.com/brisruby) inspired by a blog post by [Greg Jorgensen](http://typicalprogrammer.com/abject-oriented/) - and more importantly, the comments to it.


## Key Concepts

### Inheritance

Inheritance is a way to retain features of old code in newer code. The programmer derives from an existing function or block of code by making a copy of the code, then making changes to the copy. The derived code is often specialized by adding features not implemented in the original. In this way the old code is retained but the new code inherits from it.

Unlike Object Oriented programming, inheritance in Abject-O need not be limited to classes - functions and blocks may also inherit from other code.  Programs that use inheritance are characterized by similar blocks of code with small differences appearing throughout the source. Another sign of inheritance is static members: variables and code that are not directly referenced or used, but serve to maintain a link to the original base or parent code. 


    class Customer

      def find_name(id)
        results = DB.query :customer, id
        fullname = "#{results[1]} #{results[2]}"
      end


      def find_email(id)
        results = DB.query :customer, id
        fullname = "#{results[1]} #{results[2]}"
      
        # email addresses can now be found in the 
        # `fax-home` column 
        email = "#{results[5]}"
      end

    end


The function `find_email` was inherited from `find_name` when email addresses were added to the application. Inheriting code in this way leverages working code with less risk of introducing bugs.  But this is Ruby - implicit is better than explicit - so Abject provides a helpful DSL for functional and block inheritance that dynamically copies and pastes the inherited code at run time. 


    class Customer
      include Abject::Inheritance

      def find_name(id)
        results = DB.query :customer, id
        fullname = "#{results[1]} #{results[2]}"
      end      

      def find_email(id)
        inherits_from :find_name, id: id do 
          email = "#{results[5]}"
        end
      end

    end


How does this work? Clearly we can't just copy and paste the code so we'll need use some Ruby meta-programming magic.  But how exactly? The idea is to concatenate the parent method with the extended behaviour in the block we passed. But a straight concatenation wont work because we wouldn't be able to reference the parent method's variables with the arguments we passed. What to do, what to do....

The solution is simple and elegant. Ok, maybe not but it is pretty awesome!  Here, we read the source code of the parent method and extending block as a string from the file location specified by `source_location`.  Next, we construct a Proc that concatenates the two method strings using interpolation to embed our passed arguments, then eval it, and call it with our arguments!


    module Abject

      module Inheritance
        include Abject::Reader

        # Method chaining helps methods adhere to the single responsibility principle as well as
        # improving performance and saving memory by getting rid of all those pesky local variables.
        # Such eval! So performant! Much wow!
        def inherits_from(method_name, *args, &block)
          eval("Proc.new { |#{args.first.keys.map { |k| k.to_s }.join ','}| #{parse_method method(method_name).to_proc.source_location}\n#{parse_method block.source_location} }").call args
        end
      end
    end


[View source](https://github.com/davekinkead/abject/blob/master/lib/abject/inheritance.rb).    


### Encapsulation

The idea behind encapsulation is to keep data separate from the code. This is sometimes called data hiding, but the data is not really hidden, just protected inside another layer of code. For example, it’s not a good practice to scatter database lookups all over the place. An Abject-O practice is to wrap or hide the database in a function, thereby encapsulating the database. In the `find_name` function above the database is not queried directly — a function is called to read the database record. All `find_name` and `find_email` (and the many other functions like them) “know” is where in the customer record to find the bits of data they need. How the customer record is read is encapsulated in some other module.

Encapsulation can also be achieved through the use of protected functions.  The importance of function safety cannot be stressed enough as unprotected methods may result in data spillage, tight object coupling, and other morally questionable behaviours. In Ruby, functions can be protected with the `#` character and many IDE's also provide macros to protect large sections of your code base efficiently - `opt arrow` on Sublime Text for example.  


    # An exposed public method
    def exposed_method(customer, id)
      query = DB.find :customer, id
      customer = Customer.new query
    end

    #  A protected method
    # def protected_method(customer, id)
    #   query = DB.find :customer, id
    #   customer = Customer.new query
    # end


The Abject gem provides an elegant means of protecting methods from any unwanted spillage and leakage that might result from tight coupling.  Simply declare a function protected at the end of a class and let Ruby's metaprogramming magic do its work. 


    class Foo
      include Abject::Encapsulation

      def bar
        "bar"
      end

      def baz
        "baz"
      end

      protects :baz

    end

    p Foo.new.bar # => "bar"
    p Foo.new.baz # => nil


Now if you think all that's going on here is that `protects` redefines a method to return a `nil` you'd be wrong - damn wrong!  What's meta about that eh? No, a far more authentic way would be to dynamically comment out code at run time.


    module Abject

      module Encapsulation
        include Abject::Reader

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods

          # Copying and pasting is so 1999.  Lets use some ruby meta programming magic to 
          # dyanmically protect our methods with some `#` hashes at run time!
          def protects(name)
            location = self.instance_method(name).source_location
            define_method name do |*args|
              eval parse_method(location).gsub(/^/m, "#")
            end
          end
        end
      end
    end


Here, we use `source_location` again to read the source code of the method name passed as a string, insert some `#` at the start of every line and eval the newly _encapuslated_ function.  So authentic!

[View source](https://github.com/davekinkead/abject/blob/master/lib/abject/encapsulation.rb).


### Don’t Repeat Yourself

Don’t Repeat Yourself (DRY) is a principle of software development, aimed at reducing repetition of information of all kinds, especially useful in multi-tier architectures. The DRY principle is stated as

> Every piece of knowledge must have a single, unambiguous, authoritative representation within a system.

The antonym of DRY is, obviously, WET: Write Everything Twice.  When the DRY principle is applied successfully, a modification of any single element of a system does not require a change in other logically unrelated elements.

Owing to their naivety and laziness, junior developers often try to implement the DRY paradigm by copying and pasting code they found somewhere on the internet.  This is of course, myopic and inefficient.  The Abject-O Rubyist doesn't need to debased themselves with such short sighted behaviour though, as the Abject gem turns the entire internet into your code base. 


    class FizzBuzzer
      include Abject::DRY

        def fizzbuzz(number)
          url = 'http://stackoverflow.com/questions/24435547/ruby-fizzbuzz-not-working-as-expected#24435693'
          adjustments = {'puts' => 'return', 'def fizzbuzz(n)' => 'lambda do |n|'}
          fuck_it_just_copy_something_from_stackoverflow(url, adjustments).call(number).last.to_s
        end

    end


I hope you have a pretty good idea of what's coming next by now.  The URL passed specifies a stackoverflow question and answer.  We use Curl and Nokogiri to query the URL and parse the first HTML code block for the answer id.  We create an adjustment lambda that has some regex replacements that we want to gsub on the resulting string - in this case returning rather than putting, and converting a method definition into a lambda.  We then eval our adjustment lambda on our code from stackoverflow, and eval the resultant string.  Glorious!


    require 'curb'
    require 'nokogiri'

    module Abject
      module DRY

        # Why copy & paste answers from stack overflow when you can curl & eval them!
        # Expects a url#answer-id and a hash of adjustments to the answer code to gsub over
        def fuck_it_just_copy_something_from_stackoverflow(url, adjustments)
          # build the adjustment lambda
          edit = "lambda { |method_string| method_string"
          adjustments.each { |k,v| edit += ".gsub('#{k}', '#{v}')" }
          edit += "}"

          # then get some of that overflow goodness
          answer = url.split('#').last
          @doc ||= Nokogiri::HTML Curl.get(url).body_str
          @doc.css("#answer-#{answer} code").each do |code|
            # Oh yeah, it's lambda time! Eval the edit string, pass it the overflow code
            # and eval the resulting lambda
            return eval eval(edit).call code.content
          end

        end
      end
    end


[View source](https://github.com/davekinkead/abject/blob/master/lib/abject/dry.rb).  Have you ever seen a DRYer FizzBuzz?

