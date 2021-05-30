# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'everythingop/version'

Gem::Specification.new do |spec|
  spec.name          = "everythingop"
  spec.version       = Everythingop::VERSION
  spec.authors       = ["yasuo kominami"]
  spec.email         = ["ykominami@gmail.com"]

  spec.summary       = %q{find git repository with Evrything.}
  spec.description   = %q{find git repository with Evrything.}
  spec.homepage      = ""
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord" , "~> 4.2"
  spec.add_runtime_dependency "mysql2" , "~> 0.4.1"
  spec.add_runtime_dependency "sqlite3" , "~> 1.3.13"
  spec.add_runtime_dependency "arxutils", "~> 0.1.10"

  spec.add_development_dependency "bundler", "~> 2.2.10"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
#  spec.add_dependency "arxutils"
  spec.add_dependency "sinatra"
  spec.add_dependency "rugged", "0.24.0"
end
