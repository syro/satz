# encoding: UTF-8
#
# Copyright (c) 2015 Michel Martens
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require "syro"
require "json"
require "basica"

class Satz

  # The JSON module from stdlib provides a safe way of loading data
  # with the `parse` method, but the most widespread API for encoding
  # and decoding data is with the `load` and `dump` methods, which in
  # the case of JSON are unsafe. This module wraps the JSON constant
  # from stdlib in order to expose a safe version of `load`. As the
  # serializer is configurable, the user is expected to provide
  # objects that respond safely to those methods.
  module Serializer
    def self.load(value)
      JSON.load(value, nil, create_additions: false)
    end

    def self.dump(value)
      JSON.dump(value)
    end
  end

  @@serializer = Serializer

  def self.serializer
    @@serializer
  end

  # Modify the serializer to be used for all Satz applications.
  # The serializer object must reply to `load(arg)` and `dump(arg)`.
  def self.serializer=(value)
    @@serializer = value
  end

  class Deck < Syro::Deck
    include Basica

    # Checks the Basic Auth headers and yields
    # user and pass if credentials are provided.
    # Returns nil if there are no credentials or
    # if the block returns false or nil.
    #
    # Usage:
    #
    #     @user = auth do |user, pass|
    #       User.authenticate(user, pass)
    #     end
    #
    #     on @user.nil? do
    #       res.status = 401
    #       reply(error: "Unauthorized")
    #     end
    #
    def auth
      basic_auth(env) { |user, pass| yield(user, pass) }
    end

    # Read JSON data from the POST request.
    def read
      Satz.serializer.load(req.body.read)
    ensure
      req.body.rewind
    end

    # Write JSON data to the response.
    def reply(data)
      res.json(Satz.serializer.dump(data))
    end
  end

  def self.define(&code)
    Syro.new(Deck, &code)
  end
end
