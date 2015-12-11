Satz
====

Framework for JSON microservices

Description
-----------

Satz is a framework for writing microservices that serve and read
JSON. It uses [Syro][syro] for routing requests. Check the [Syro
tutorial][tutorial] to learn more about how the routing works.

[syro]: http://soveran.github.io/syro/
[tutorial]: http://files.soveran.com/syro/

Usage
-----

An example of a Satz application would look like this:

```ruby
App = Satz.new do
  on "players" do
    on :player_id do
      get do
        @player = Player[inbox[:player_id]]

        reply @player
      end
    end

    get do
      reply Player.all.to_a
    end

    post do
      @player = Player.new(read)

      on @player.valid? do
        @player.create

        reply @player
      end

      default do
        reply @player.errors
      end
    end
  end
end
```

The argument to `reply` is served as JSON by calling `JSON.dump(arg)`.
In user defined objects, you can define the method `to_json` according
to your needs. Most ORMs already provide meaningful definitions for
that method.

API
---

Apart from [Syro][syro]'s API, the following methods are available:

`read`: Reads the body of the requst and parses it as JSON.

`reply`: Writes to the response its argument encoded as JSON.

```
$ gem install satz
```
