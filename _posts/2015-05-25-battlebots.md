---
layout: post
title:  BattleBots!
author: Dave Kinkead
status: forthcoming
meetup: May 2015
---

The idea is simple enough: Code your bot; submit it; and battle it out.  But how do we do it exactly?  Let's have a look...

The game is powered by the [Gosu gaming library][gosu]. The first thing you'll need to do is install Gosu's C dependencies. You can do this using homebrew via `$ brew install sdl2 libogg libvorbis`. After doing that, run `bundle install`.

Gosu gives us all the fancy GUI and gaming geometry tools we'll need and its high level API is dead easy.  Just extend `Gosu::Window`, call `super` in your `#initialize` method, and implement the `#update` -> `#draw` -> `#button_up` -> `#button_down` loop.  The loop will run every 16.667 milliseconds and allows for silky smoth animation as the screen is updated at 60 fps.

Here's the shell of game that we execute by calling `ruby game.rb` from the CLI.


    require 'gosu'

    class Game < Gosu::Window

      def initialize(x=1200, y=800, resize=false)
        super
        ...
      end

      def update
        ...
      end

      def draw
        ...
      end

      def button_up(id)
        ...
      end

      def button_down(id)
        ...
      end
    end

    Game.new.show


## Building a Bot

To make a bot, simply extend the `Bot` class and implement the required methods.

Think of your bot as a brain.  In normal object oriented game code, your bot would be doing most of the work. The Game object would be calling Bot methods and the bot itself would be keeping track of state.

But this is a competitive endeavour and programmers can't be trusted!  So rather than allowing your bot to track state and take actions, your bot will signal its intentions to a Proxy which which will query your bot's wants, track state, and enforce the game rules.

Every tick of the game (60 times per second), the proxy will inform your bot about the battlespace by calling `bot.observe`.  This give your information on your current position, health, heading, and turret heading, for you as well as the other competitors.

So what intentions can your bot signal?


    attr_reader :name, :turn, :drive, :aim, :shoot


You set your name as well as your skill matrix in the `#initialize` method.  The remainder are signalled in the `#think` method.

  - `@turn` is a value of +1 to turn clockwise, -1 to turn anti-clockwise, or 0 to maintain direction.

  - `@drive` is a value of 1 to move forward or 0 to maintain position.

  - `@aim` is a value of +1 to -1 to turn the turret clockwise or anti-clockwise.

  - `@shoot` is a value of true or false to fire your weapons.

The specifics of how you implement `#think` is entirely up to you.  I've included three example bots for you to examine and test against.


## Skill Set

Your bot also contain a skill set representing relative virtues of `@speed`, `@strength`, `@stamina`, and `@sight`.  These virtues must sum to 100 and allow you to enhance some attributes at the expense of others.

  - `@speed` determines to how fast your bot can move.

  - `@strength` increases bullet velocity and firepower.

  - `@stamina` aids your ability to sustain damage.

  - `@sight` improves your peripheral vision.

The Proxy will check that your virtues sum to 100 and will not allow values above this.  The default is 25 each.


## Submitting your bot

To submit your bot:

  1. For this repo and install the Gosu gem and dependencies
  2. Extend BattleBot::Bot
  3. Add your bot to players.rb
  4. Ensure your bot works by running `$ ruby game.rb` in terminal
  4. Create a pull request with your bot's name.


Happy hunting!


## Credits

Graphics have been blatantly plagiarised from Adam Williams' [rTanque](https://github.com/awilliams/RTanque)

Sounds by [Mike Koenig](http://soundbible.com/2075-RPG-Plus-Shrapnel.html)

[gosu]: https://github.com/jlnr/gosu/