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
App = Satz.define do
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

Authentication
--------------

The `auth` method checks if Basic Auth headers were provided and
returns `nil` otherwise. If it's able to access the supplied
credentials, it yield the username and password and returns the
result (if it's not false) or nil.

Here's an example of how to use it:

```ruby
@user = auth do |user, pass|

  # Here you can use any method of your
  # choice. The example is from Shield.
  User.authenticate(user, pass)
end

on @user.nil? do
  res.status = 401
  reply(error: "Unauthorized")
end
```

Anything defined after that `on` block will be executed only if the
authentication succeded.

Serialization
-------------

The default serializer is `JSON`, but it can be customized by
supplying a serializer:

```ruby
Satz.serializer = MySerializer
```

A serializer must respond to `load(arg)` and `dump(arg)`, and that's
the only restriction. Note that the supplied serializer will be used
by all `Satz` applications.

API
---

Apart from [Syro][syro]'s API, the following methods are available:

`auth`: Process Basic Auth headers and yield username and password.

`read`: Reads the body of the request and parses it as JSON.

`reply`: Writes to the response its argument encoded as JSON.

Installation
------------

```
$ gem install satz
```
