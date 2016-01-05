Gem::Specification.new do |s|
  s.name              = "satz"
  s.version           = "0.0.3"
  s.summary           = "Framework for JSON microservices"
  s.description       = "Framework for JSON microservices"
  s.authors           = ["Michel Martens"]
  s.email             = ["michel@soveran.com"]
  s.homepage          = "https://github.com/syro/satz"
  s.license           = "MIT"

  s.files = `git ls-files`.split("\n")

  s.add_dependency "syro", "~> 2.0"
  s.add_development_dependency "cutest"
  s.add_development_dependency "rack-test"
end
