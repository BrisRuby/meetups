---
layout: post
title:  A beginner's guide to ruby gems
author: Dave Kinkead
status: published
---

On key factor of Ruby's success as a language - apart from its beautiful expressiveness - is it's package management ecosystem - RubyGems.  Just like Ruby, RubyGems is optimised for developer happiness - it makes the packaging and dependency requirements of distributed software a pleasure.

This post is a brief introduction to using, writing, and sharing gems in Ruby based on a talk I gave to the [BrisRuby][br] group this month.  The intended audience is the beginner Rubyist.  The source code [found here][ify].

[br]: http://www.meetup.com/Brisruby/
[ify]: https://github.com/davekinkead/ify


## What is a Gem?

Gems are self contained chunks of Ruby code - modules, packages, & libraries - that are designed to be shared and used either independent or more frequently, to extend functionality in other code bases.

RubyGems is Ruby's package management system.  Along with `Bundler` and the `Gem` gems, it provides a standardised format for creating, sharing, and reusing ruby gems.  And just like Rails, this consistent set of conventions is what makes it so powerful.


## Using Gems

The two most common ways to use gems is to install them directly or with a dependency manager like [Bundler][bundler].  The direct method installs a gem on your system and is the best option if your gem is a stand alone program or includes a console based API. To install Rails for example, you'd just execute the following one liner:

[bundler]: http://bundler.io/


    gem install rails


The other method is to use a gemfile and bundler.  In this case, you declare all the gems you want to use in the gemfile, along with any group namespaces:


    # Gemfile
    source 'https://rubygems.org'
    gem 'geokit'
    gem 'rack', '~>1.1'

    group :production do
      gem 'pg'
    end

    group :test do
      gem 'sqlite3'
    end


Then launch your program with bundler...


    bundle exec my_cool_app


Two points to note here are that the `pg` and `sqlite3` gems will only be loaded in their respective environments and that `rake` gem also has a version argument.  Versions can be exact or approximately greater than so `~> 2.0.1` means equal to or greater than in the last digit, ie `2.0.x`.


## Naming a gem

Before you build and share a gem, it's a good idea to make sure the functionality your are producing doesn't already exist.  Search for the behaviour on the [RubyGems][rg] website and [The Ruby Toolbox][rt] to prevent needless duplication.

[rt]: https://www.ruby-toolbox.com/
[rg]: https://rubygems.org/

If you didn't find anything there, then think up snappy name that preferably contains some word-play, innuendo, or double entendre.  

Need full text search in PostGres? You need [Texticle][texticle].  

Written a command line interface time tracker? Call it [Clitt][clitt].  

Or looking for a way to extend hashes?  [Hash Dealer][hd] has you covered.  

[hd]: https://github.com/LifebookerInc/hash_dealer
[texticle]: http://texticle.github.io/texticle/
[clitt]: https://github.com/francois/clitt

And if you are still struggling for a name, then just choose the 17th word on a random page from 4chan.  Now the gem we are going to build today is possibly the most useless gem every created.  And given the dubiuous quality surrounding it, and what it actually does, the only appropriate name for it is `ify`.


## Building a gem

Bundler makes building a gem effortless so fire up terminal and type:


    bundle gem ify


Bundle has created a gem skeleton for us that we now need to populate.  The most important files are be the README and the gemspec.


      create  ify/Gemfile
      create  ify/Rakefile
      create  ify/LICENSE.txt
      create  ify/README.md
      create  ify/.gitignore
      create  ify/ify.gemspec
      create  ify/lib/ify.rb
      create  ify/lib/ify/version.rb


Every good open source project has a compressive README with a [clear and unambitious description][ify] of what the project does and how it does it.  Make sure you document the public interface of your gem by showing how it can be used.  [Write your readme first][rdd].

[rdd]: http://tom.preston-werner.com/2010/08/23/readme-driven-development.html


Now it's time to code the awesome sauce and we'll start with a spec.


    # spec/ify_spec.rb
    require 'ify'
    require 'minitest/autorun'

    describe "Ify" do
      it "ifyifies a string" do
        "string".ify.must_equal "stringify"
      end
    end


Running our test results in a failure because we haven't written any code yet :(


    # Running:

    E

    Finished in 0.001509s, 2650.7621 runs/s, 0.0000 assertions/s.

      1) Error:
    Ify#test_0001_ifyifies a string:
    NoMethodError: undefined method `ify' for "string":String
        /Users/dave/Desktop/Projects/ify/spec/ify_spec.rb:6:in `block (2 levels) in <top (required)>'

    1 runs, 0 assertions, 0 failures, 1 errors, 0 skips


Our gem is going to extend the functionality of the `String` core library via a technique call monkey patching.  The simplest way to get our test to pass is to simply append "ify" to the end of a string when the `ify()` method is called


    # lib/ify.rb
    class String
      def ify()
        "#{self}ify"
      end
    end


Running our test again results in a success!


    # Running:

    .

    Finished in 0.001744s, 573.3945 runs/s, 573.3945 assertions/s.

    1 runs, 1 assertions, 0 failures, 0 errors, 0 skips


We then iterate this fail-code-pass process until we achieve the desired behaviour outlined in our readme.


    # spec/ify_spec.rb
    describe "Ify" do
      it "ifyifies a string" do
        "string".ify.must_equal "stringify"
      end

      it "is vowel aware" do
        "awesome".ify.must_equal "awesomify"
      end

      it "ignores trailing whitespace" do
        "spot ".ify.must_equal "spotify"
      end

      it "plays well with small animals" do
        "bee".ify.must_equal "beeify"
        "fruit fly".ify.must_equal "fruit flyify"
      end
    end


    # lib/ify.rb
    class String
      def ify()
        str = self.rstrip
        str.sub! /[aeiouy]$/, '' if str.split.last.length > 3
        "#{str}ify"
      end
    end


## Packaging a gem

Once our code is working as desired, it's time to package it up into gem to make sharing and reuse a breeze.  First, we ensure that our gemspec is up to date.  The bundler generator has does most of the work for use, so we just need to fill out a few more fields.


    # coding: utf-8
    lib = File.expand_path('../lib', __FILE__)
    $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
    require 'ify/version'

    Gem::Specification.new do |spec|
      spec.name          = "ify"
      spec.version       = Ify::VERSION
      spec.authors       = ["Dave Kinkead"]
      spec.email         = ["dave@kinkead.com.au"]
      spec.description   = %q{Ifyify anything}
      spec.summary       = %q{A vowel aware ifyfier of dubious quality.}
      spec.homepage      = "https://github.com/davekinkead/ify"
      spec.license       = "MIT"

      spec.files         = `git ls-files`.split($/)
      spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
      spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
      spec.require_paths = ["lib"]

      spec.add_development_dependency "bundler", "~> 1.3"
      spec.add_development_dependency "rake"
    end


Then, we package it with the command and we are done!


    gem build ify.gemspec


##  Sharing a gem

Our gem of dubious quality is now ready to be shared with the world.  There are a few ways we can do this:

- locally so only those with access to our file system can use it.
- on our own private or public gem server.
- on the [rubygems.org][rg] server.


Opens source is awesome sauce so we'll use the latter approach.  First you'll need to create an account on rubygems.org.  Once that's done, all you need is:


    gem push ify-0.0.1.gem


That's it.  You are now an open source contributor!  Of dubious quality...


## Resources

- [Ify on RubyGems.org](http://rubygems.org/gems/ify)
- [Ify source code][ify]
- [RubyGems guide](http://guides.rubygems.org/)



