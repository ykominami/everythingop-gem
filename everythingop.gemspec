lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'everythingop/version'

Gem::Specification.new do |spec|
  spec.name          = 'everythingop'
  spec.version       = Everythingop::VERSION
  spec.authors       = ['yasuo kominami']
  spec.email         = ['ykominami@gmail.com']

  spec.summary       = 'find git repository with Evrything.'
  spec.description   = 'find git repository with Evrything.'
  # spec.homepage      = ""
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #  raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.7'

  spec.add_runtime_dependency 'bundler'
  spec.add_runtime_dependency 'rake', '~> 13.0'
  spec.add_runtime_dependency 'rugged'
  spec.add_runtime_dependency 'sinatra'
  
  spec.add_runtime_dependency 'arxutils_sqlite3'
  spec.add_runtime_dependency 'simpleoptparse'

  spec.add_runtime_dependency 'encx'
  spec.add_runtime_dependency 'ykutils'
  spec.add_runtime_dependency 'ykxutils'

  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop', '~> 1.7'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'

  # spec.add_development_dependency "yard"
  spec.metadata['rubygems_mfa_required'] = 'true'
end
