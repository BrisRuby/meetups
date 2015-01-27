---
layout: post
title:  rSpec vs Minitest Smackdown
author: Dave Kinkead
status: forthcoming
meetup: Jan 2015
---

# Minitest vs rSpec

Notes for our head-to-head talk.  Each plus for one should equate to a minus for the other (ie they are relative).

Please complete before Monday!


## Minitest

### + Simplicity

Minitest is part of the ruby standard library which means you don't need to install any gems and setup is as easy as a single require line.


    # /spec/logic_spec.rb
    require 'minitest/autorun'

    describe "bivalent logic" do
      it "rejects contradiction" do
        true.wont_equal false
      end
    end

    $ ruby logic_spec.rb


The [codebase itself][minitest] is also relatively tiny. The core module is just a pip over 700 LOC making it easy to get your head around.  Of course, this also means minitest doesn't have the same feature set as rSpec.  But it does give you 90% of the functionality with only 10% of the magic.

[minitest]: https://github.com/seattlerb/minitest


### + Choice of Style

Minitest gives you a great deal of stylistic choice.  You can use the traditional assert style of testing or the spec style DSL.  This is because Minitest::Spec is just a collection of aliases for Minitest::Assertions with a little sprinkling of syntactic sugar include `it`, `let`, 'subject`, and specify'.

You can mix and match these as you like but why would you. Hey, we're Rubyists. Looks matter.


    require 'minitest/autorun'

    describe "bivalent logic" do
      let(:the_truth) { true }
      subject { true }

      specify { true.wont_equal false }

      it "is either true or false" do
        the_truth.must_equal false || true
      end

      def test_non_contradiction
        subject.wont_equal true && false
      end
    end


### + Extensibility 

Minitest is also incredibly simple to extend.  The base methods include (with corresponding wont, assert, and refute methods): 

  - :must_be
  - :must_be_close_to
  - :must_be_empty
  - :must_be_instance_of
  - :must_be_kind_of
  - :must_be_nil
  - :must_be_same_as
  - :must_be_silent
  - :must_be_within_delta
  - :must_be_within_epsilon
  - :must_equal
  - :must_include
  - :must_match
  - :must_output
  - :must_raise
  - :must_respond_to
  - :must_send
  - :must_throw

The standard library also includes Mocks, Stubs, Expectations, and Parallelisation.  Beyond the standard library however, exists a rich ecosystem of extensions - Rails, Capybara, Chef, metadata, spec-context, Growl etc, or my personal favourite - minitest/emoji - which poops failures to your terminal.


### - Hooks

So what then are the negatives?  For me, the only negatives are the lack of hooks compared to rSpec.  Minitest offers the `before` and `after` hooks but these act the same as rSpec's before :all.  Neither does Minitest offer an `around` hook.

Of course, these typically only affect performance during complex tests which can be mitigated somewhat by the lazy loading offered by `let`.