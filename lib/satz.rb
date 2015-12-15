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
require "base64"

class Satz
  class Deck < Syro::Deck
    HTTP_AUTHORIZATION = "HTTP_AUTHORIZATION".freeze

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
      http_auth = env.fetch(HTTP_AUTHORIZATION) do
        return nil
      end

      cred = http_auth.split(" ")[1]
      user, pass = Base64.decode64(cred).split(":")

      yield(user, pass) || nil
    end

    # Respond by default with JSON.
    def default_headers
      { "Content-Type" => "application/json" }
    end

    # Read JSON data from the POST request.
    def read
      body = req.body.read
      body && JSON.parse(body)
    end

    # Write JSON data to the response.
    def reply(data)
      res.write(JSON.dump(data))
    end
  end

  def self.define(&code)
    Syro.new(Deck, &code)
  end
end
