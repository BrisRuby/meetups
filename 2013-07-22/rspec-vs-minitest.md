---
title: RSpec vs Minitest | A Testing Fairytail
audience: BrisRuby Meetup July 2013
author: Dave Kinkead
email: dave@kinkead.com.au
url: http://dave.kinkead.com.au/
---
= id="intro" data-z="50000" data-rotate-z="90" data-scale="400" 

# RSpec _vs_ MiniTest 

---
=  data-z="60000" data-rotate-z="90" data-scale="100" 

# A fairy tail adventure

#### [@davekinkead](http://dave.kinkead.com.au)

---
= data-x="1000" data-y="1000"

### Once Upon A Time...

In a land far, far, away...

----
= data-x="2000" data-y="1000"

## The Kingdom didn't test

---
= id="tests-yeah" data-x="2000" data-y="1000"

Boo!

---
= id="tdd" data-x="2000" data-y="2000"

Luckily, the people discovered

# Test Driven Development

---
= id="tdd-rejoice" data-x="2000" data-y="2000"
There was much rejoicing.

---
= data-x="2000" data-y="3000" data-rotate-z="45"

## But all was not well...

Because test unit cause them pain.  Deep, aesthetic pain.

---
= data-y="2000" data-rotate-z="45"

	require 'test/unit'
	
	class TDD < Test::Unit::TestCase
		def setup
			@fairy = Fairy.new
		end
	
		def testUrCodeMakesMyEyesBleed
			assert(@fairy.sees_red, true)
		end
		
		def teardown
			@fairy.bite :dust
		end
	end

---
= id="rspec" data-x="-1000" data-y="1000" data-rotate-z="45"

# Enter RSpec, stage left.  

---
= data-x="-1500" data-y="1500" data-rotate-z="45"

	require 'rspec'

	describe BDD do	
		subject(:fairy) { Fairy.new }
		
		context "when writing specs"
			it { should weep_with_joy }
		end
	end

---
= id="rspec-rejoice" data-x="-1500" data-y="1500" data-rotate-z="45"

And there was much rejoicing.

---
= data-x="-2000" data-y="2000" data-rotate-z="45"

## Success breeds complacency. 

And complacency breeds bloat.  

---
= id="bloat" data-x="-2000" data-y="2000" data-rotate-z="45"

Mmmm, Bloat.

---
= data-x="-2000" data-y="-1000" data-rotate-z="270"

## There was a disturbance in the force. 

The gods were not happy.

---
= id="dhh-angry" data-x="-2000" data-y="-1000" data-rotate-z="270"

img DHH angry.

---
= data-x="-1000" data-y="-1000" data-rotate-z="270"

## Minitest is born!

but not all babies are beautiful

--- 
= id="minitest-born" data-x="0" data-y="-1000" data-rotate-z="270"

---
= data-x="0" data-y="-2000" data-rotate-z="270"

## But a problem remained...

---
= id="eyes-bleed" data-x="0" data-y="-2000" data-rotate-z="270"

img bleeding eyes

---
= data-x="5000" data-y="-2500" data-rotate-z="90" data-scale="5"

Just like another ugly duckling, minitest comes of age. 

# Minitest::Specs

---
= data-x="7500" data-y="-2500" data-rotate-z="90" data-scale="5"

	# require 'nadda-niks-nothing'

	describe BDD do	
		let(:fairy_tests) { FairyTail.new }
	
		describe "when writing minitest::specs"
			it { fairy_tests.must_be_kind_of :heaven }
		end
	end

---
= id="minitest-rejoice" data-x="7500" data-y="-2500" data-rotate-z="90" data-scale="5"

img Schwing!

More pretty, less bloat.

---
= data-x="10000" data-y="-2500" data-rotate-z="90" data-scale="5"

# Segway......

---
= data-x="10000" data-y="5000" data-scale="30"

So far, I've been heavy on metaphor but light on content.  Lets dive a little deeper....

# RSpec

---
= id="rspec-why" data-x="15000" data-y="10000" data-scale="20"

## Why?

---
= data-x="11000" data-y="10000" data-scale="15"

- tests are first class objects
- negation and self-description
- metadata
- around(:each) hooks
- DHH hates it

---
= data-x="20000" data-y="7000" data-scale="15" data-rotate-z="90"

# Why not?

---
= id="fatty" data-x="20000" data-y="7000" data-scale="15" data-rotate-z="90"

img Fat boy

---
= data-x="-20000" data-y="-12000" data-scale="30"

#MiniTest

---
= id="minitest-why" data-x="-25000" data-y="-8000" data-scale="20"

## Why?

---
= data-x="-8000" data-y="-7500" data-scale="20"

- included with ruby
- fast!
- eminently hackable!

---
= data-x="-2000" data-y="-7500" data-scale="15"

	#infect_an_assertion

---
= data-x="-15000" data-y="5000" data-rotate-z="45" data-scale="20"

# Rails Integration

---
= data-x="-17500" data-y="2500" data-rotate-z="45" data-scale="5"

	
	# test/test_helper.rb
	ENV["RAILS_ENV"] ||= "test"
	require File.expand_path('../../config/environment', __FILE__)
	require 'rails/test_help'
	require 'minitest/autorun'
	require 'minitest/rails'

---
= data-x="-12500" data-y="7500" data-rotate-z="45" data-scale="5"

	module MiniTest::Expectations
	  infect_an_assertion :assert_redirected_to, :must_redirect_to
	  infect_an_assertion :assert_template, :must_render_template
	  infect_an_assertion :assert_response, :must_respond_with
	  infect_an_assertion :assert_difference, :must_change
	  infect_an_assertion :assert_no_difference, :wont_change
	  infect_an_assertion :assert_recognizes, :must_recognize
	end

---
= id="xx" data-x="-5000" data-y="15000" data-rotate-z="45" data-scale="5"


img dos esque

---
= id="overview" data-scale="50"
