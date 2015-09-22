---
layout: post
title:  Ruby is a Message Oriented Language
author: Dave Kinkead
status: published
meetup: Jul 2015
---

Many people think of Ruby as an Object Oriented Language.  It is - and a lovely one at that.  But Ruby makes so much more sense if you think of it as a Message Oriented Language.  Most of programming in Ruby involves sending messages to objects, and defining how objects should respond to messages.  Master this and you've almost mastered Ruby.  

We can send a message to an object by using the dot operator, the message name, and an optional payload (typically known as arguments in other languages).


    object.send(:message)

    object.send(:message, payload)


So how do we add 2 & 3 in Ruby? We send the object `2` the message `+` and the payload `3`:

  
    2.send(:+, 3)
    # => 5


How do we reverse the string `RailsGirls`? By sending a `String` object the message `reverse`:


    "RailsGirls".send(:reverse)
    # => "slriGslisR"


And to randomly generate 5 numbers between 0 and 100, we send a `Range` object the message `to_a` which responds with an `Array` Object.  We then send this object the message `sample` and the payload `5`:


    (0..100).send(:to_a).send(:sample, 5)
    # => [75, 89, 76, 62, 55]


## Syntactic Sugar

Every language is optimised for some quality.  C is optimised for speed. Java is optimised for bureaucracy.  Ruby is [optimised for developer happiness](https://gettingreal.37signals.com/ch10_Optimize_for_Happiness.php).

One way to make developers happy is by giving them a rich and expressive language.  Ruby does this by sprinkling some semantic sugar on top of its message oriented architecture.  The first dollop of sugar let's us stop the tedious `.send(:message)` syntax and replace it with simply `.message`.


    2.send(:+, 3)
    # => 5

    2.+(3)
    # => 5  

    "Hello, Ruby!".send(:include?, "Z")
    # => false

    "Hello, Ruby!".include?("Z")
    # => false


Next, we can get rid of parenthesis so long as there is no ambiguity.


    2.+ 3
    # => 5  

    66.even?
    # => true


Finally, some core objects have additional semantic sugar baked in.


    2.send(:+, 3)
    2 + 3
    # => 5

    "I love Ruby".send(:[], (2..5))
    "I love Ruby"[2..5]
    # => "love"


Mmmm, syntax. Yummy.


## Everything in Ruby is an Object.  Almost

Spend any time around Rubyists and you'll here that [everything in Ruby is an object](http://stackoverflow.com/questions/3429553/is-everything-an-object-in-ruby).  That's _almost_ true but why it's almost true becomes clearer when you understand just how Ruby conceives of objects.  

The traditional coneption of an [object in computer science](https://en.wikipedia.org/wiki/Object_%28computer_science%29) is anything that holds state and exhibits behaviour.  In Ruby however, an object is anything that responds to a message.  

Numbers are objects because they respond to messages.


    42.class
    # => Fixnum


Strings are objects because they respond to messages.


    "Ruby is beautiful".class
    # => String


Booleans are objects because they respond to messages.


    true.class
    # => TrueClass


Nils are objects because they respond to messages.


    nil.class
    # => NilClass


Objects are obviously objects because they respond to messages.


    Object.class
    # => Class


Even Classes are objects because they respond to messages.


    Class.class
    # => Class


Yes, the `Class` class is an object of class `Class`.  Ruby is meta.


## Responding to Messages

While much of programming in Ruby involves sending messages to objects, a lot also involves the other side of this relationship - defining how objects should respond to messages.  The Ruby [Core](http://ruby-doc.org/core-2.2.3/) and [Standard](http://ruby-doc.org/stdlib-2.2.3/) libraries already provide a bunch of useful functionality.  Often however, we need to compose our own. Ruby of course, make this all very simple with the `class` keyword.  


    class MyFirstClass
    end


That it - we've just created a class of object called `MyFirstClass`. Out of the box, we get a lot of functionality thanks to Ruby's automatic inheritance from the `Object` class.


    MyFirstClass.ancestors
    # => [MyFirstClass, Object, Kernel, BasicObject]


    MyFirstClass.methods
    # => [:allocate, :new, :superclass, :freeze, :===, :==, :<=>, :<, :<=, :>, :>=, :to_s, :inspect, :included_modules, :include?, :name, :ancestors, :instance_methods, :public_instance_methods, :protected_instance_methods, :private_instance_methods, :constants, :const_get, :const_set, :const_defined?, :const_missing, :class_variables, :remove_class_variable, :class_variable_get, :class_variable_set, :class_variable_defined?, :public_constant, :private_constant, :singleton_class?, :include, :prepend, :module_exec, :class_exec, :module_eval, :class_eval, :method_defined?, :public_method_defined?, :private_method_defined?, :protected_method_defined?, :public_class_method, :private_class_method, :autoload, :autoload?, :instance_method, :public_instance_method, :nil?, :=~, :!~, :eql?, :hash, :class, :singleton_class, :clone, :dup, :taint, :tainted?, :untaint, :untrust, :untrusted?, :trust, :frozen?, :methods, :singleton_methods, :protected_methods, :private_methods, :public_methods, :instance_variables, :instance_variable_get, :instance_variable_set, :instance_variable_defined?, :remove_instance_variable, :instance_of?, :kind_of?, :is_a?, :tap, :send, :public_send, :respond_to?, :extend, :display, :method, :public_method, :singleton_method, :define_singleton_method, :object_id, :to_enum, :enum_for, :equal?, :!, :!=, :instance_eval, :instance_exec, :__send__, :__id__]


Typically though, that isn't enough.  Often, we need to define our own responses to messages which we do with the `def` keyword.


    class Hipster
      def ironic?
        true
      end

      def opinion_on(it)
         "#{it} is so last year.""
      end
    end


Now we can create instance objects of our `Hipster` class, send them messages, and watch them respond.


    byron = Hipster.new
    # => #<Hipster:0x007f83539f6130>

    byron.ironic?
    # => true

    byron.opinion_on "Craft beer"
    # => "Craft beer is so last year."


That's largely all there is to Ruby.  Just remember that it's a Message Oriented Language.