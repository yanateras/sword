# encoding: utf-8
require './lib/app'

Gem::Specification.new do |s|
  s.name = 'sword'
  s.version = Sword.version
  s.platform = Gem::Platform::RUBY
  s.files = `git ls-files`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w[lib]
  s.authors = %w[George ソム]
  s.date = Date.today.to_s
  s.email = 'somu@so.mu'
  s.homepage = 'http://so.mu/blog/sword'
  s.licenses = %w[MIT]
  s.description = "Designer’s best friend forever."
  s.summary = "Develop using SASS/Compass, Slim, LESS &c. and convert it to static."

  %w[sinatra 1.3.4 thin 1.5.0].each_slice(2) do |n, v| # psych 1.3.4 
    s.add_runtime_dependency(n, [] << "~> #{v}")
  end

  %w[bundler 1.2.3 rake 10.0.3].each_slice(2) do |n, v|
    s.add_development_dependency(n, [] << "~> #{v}")
  end
end
