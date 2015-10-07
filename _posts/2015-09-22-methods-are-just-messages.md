---
title:  Methods are just messages
author: Dave Kinkead
layout: post
status: published
meetup: Sep 2015
---

You've probably heard that Ruby is an Object Oriented Language.  That's certainly correct but I find it more useful to think about Ruby as a [Message Oriented Language](http://dave.kinkead.com.au/thoughts/ruby-is-a-message-oriented-language/) as the two are deeply intertwined.

Most new programmers grasp the idea of sending messages and payloads pretty quickly once it is explained.  We can send messages with the `send` message, or send messages themselves. The following are synonymous:


    object.send(:message, payload)
    object.message(payload)

    "Ruby is awesome!".send(:reverse)
    "Ruby is awesome!".reverse


Equally straight forward is how we define how objects respond to messages with `def` blocks in class statements.


    class String
      def reverse_up
        reverse.upcase
      end
    end

    "hello ruby!".reverse_up
    # => "!YBUR OLLEH"


Where things start to get a little fuzzy is when blocks get introduced into the mix.  Let's look at a very common Ruby idiom:


    (1..10).each do |number|
      puts number * 2
    end
    # => 2 4 6 ... 20


What's going on here?  We are obviously sending the message `.each` to a `Range` object but what exactly is the block's relationship with the message & object?  It turns out that blocks are just message payloads - optional payloads that are appended to a message.


## Blocks are just payloads. Almost

Blocks are optional payloads that are appended to messages - any message.  Append a block to any message and see what happens:

    
    "Ruby is awesome!".reverse
    # => "!emosewa si ybuR"

    "Ruby is awesome!".reverse { puts "I'm in a single line block!" }
    # => "!emosewa si ybuR"    

    "Ruby is awesome!".reverse do
      puts "I'm in a multi-line block!"
    end
    # => "!emosewa si ybuR" 


See - nothing extra happens.  If an object receives a message with a block payload, the block is silently ignored unless the message definition explicitly yields to it.  Note however, that the block is appended to the message, not included with the rest of the payload.


    "Ruby is sweet!".send(:reverse) { puts "I'm in a block!" }
    # => "!teews si ybuR"

    "Ruby is sweet!".send(:reverse, { puts "I'm in a block!" })
    # => SyntaxError: syntax error, unexpected tSTRING_BEG, expecting keyword_do or '{' or '('    


So our new pattern for Ruby messaging looks like this:


    object.message(payload) {block}


So far, so good.  Let's see how things work on the message definition side of things by creating a method that responds to messages with a block.


    def yield_me
      yield
    end

    yield_me { p "I'm in a block!" }
    # => "I'm in a block!"


Here we send the message `yield_me` to the object `main` - ([the context that IRB runs in](https://banisterfiend.wordpress.com/2010/11/23/what-is-the-ruby-top-level/)) - along with a block.  The method `yield_me` then just yields control to the block `{ p "I'm in a block!" }` that was appended to the message, before control is returned to the method.

Great. But what can you actually use passing-a-block-with-a-message for?  Lots it turns out but lets use it to create a custom enumerator.  We will monkey patch the core `Enumerable` module to create an `every_nth` method that will iterate over, you guessed it, every nth item in an enumerable.


    module Enumerable
      def every_nth(n)
        counter = 0
        each do |enum|
          counter += 1
          yield enum if counter % n == 0
        end
      end
    end


Now there's a little Ruby magic at work here.  Inside `every_nth`, we send `each` to `self` with a block that counts the enumerations and passes control to the message block if the enumeration is evenly divisible by `n`.  Yeps, the block we pass to `each` is yielding to the block passed to `every_nth`. Ruby is meta.

And because we monkey patched `Enumerable`, `every_nth` is available to all objects mixin `Enumerable` like ranges and arrays.


    (1..50).every_nth(5) { |n| p n }
    # => 5 10 15 20 ... 50

    "ruby is clever".chars.every_nth(2) { |n| p n.upcase }
    # => "U" "Y" "I" " " "L" "V" "R"


Et voilà!.