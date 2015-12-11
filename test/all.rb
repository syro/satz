App = Satz.define do
  get do
    reply(true)
  end

  post do
    reply(read)
  end
end

setup do
  Driver.new(App)
end

test "get" do |app|
  app.get("/")

  assert_equal 200, app.last_response.status
  assert_equal %Q(true), app.last_response.body
end

test "post" do |app|
  data = { "foo" => "bar" }.to_json

  app.post("/", data)

  assert_equal data, app.last_response.body
  assert_equal 200, app.last_response.status
end
