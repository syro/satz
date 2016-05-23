A1 = Satz.define do
  get do
    reply(read)
  end

  post do
    reply(read)
  end

  on "protected" do
    @user = auth do |user, pass|
      user == "foo" && pass == "bar"
    end

    on @user.nil? do
      res.status = 401
      reply(error: "Unauthorized")
    end

    get do
      reply(true)
    end
  end
end

setup do
  Driver.new(A1)
end

test "get" do |app|
  app.get("/")

  assert_equal 200, app.last_response.status
  assert_equal %Q(null), app.last_response.body
end

test "post" do |app|
  data = { "foo" => "bar" }.to_json

  app.post("/", data)

  assert_equal data, app.last_response.body
  assert_equal 200, app.last_response.status
end

test "auth" do |app|
  app.get("/protected")

  assert_equal %Q({"error":"Unauthorized"}), app.last_response.body
  assert_equal 401, app.last_response.status

  app.authorize("foo", "bar")

  app.get("/protected")

  assert_equal %Q(true), app.last_response.body
end

module Reverser
  def self.load(data)
    data
  end

  def self.dump(data)
    data.reverse
  end
end

Satz.serializer = Reverser

A2 = Satz.define do
  get do
    reply("hello")
  end
end

setup do
  Driver.new(A2)
end

test "get" do |app|
  app.get("/")

  assert_equal 200, app.last_response.status
  assert_equal %Q(olleh), app.last_response.body
end

Stream = Satz.define do
  post do
    _ = read

    res.write(req.body.read)
  end
end

test "stream" do
  json = JSON.generate(ok: true)

  app = Driver.new(Stream)
  app.post("/", json)

  assert_equal json, app.last_response.body
end
