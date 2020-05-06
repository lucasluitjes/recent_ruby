
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "recent_ruby/version"

Gem::Specification.new do |spec|
  spec.name          = "recent_ruby"
  spec.license       = "MIT"
  spec.version       = RecentRuby::VERSION
  spec.authors       = ["Lucas Luitjes"]
  spec.email         = ["lucas@luitjes.it"]

  spec.summary       = %q{CLI tool for your CI/CD to make sure a recent and secure ruby version is used.}
  spec.homepage      = "https://github.com/lucasluitjes/recent_ruby"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = "recent_ruby"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency('rdoc')
  spec.add_development_dependency('pry')
  spec.add_development_dependency('aruba')
  spec.add_dependency('methadone', '~> 1.9.5')
  spec.add_dependency('parser')
  spec.add_development_dependency('test-unit')
end
