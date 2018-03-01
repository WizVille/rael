lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rael/version"

Gem::Specification.new do |spec|
  spec.name          = "rael"
  spec.version       = Rael::VERSION
  spec.authors       = ["Oxyless"]
  spec.email         = ["clement.bruchon@gmail.com"]

  spec.summary       = %q{ Active Record Tree : Import / Export / Clone }
  spec.description   = %q{ Add tools to clone active_record tree with a schema strategy in order to keep control on what to copy }
  spec.homepage      = "http://wizville.fr/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.11"
  spec.add_development_dependency "awesome_print", "~> 1.8"
  spec.add_development_dependency "activerecord", "~> 5.1"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "globalize", "~> 5.1"
end
