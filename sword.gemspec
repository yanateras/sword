# encoding: utf-8
require File.dirname(__FILE__) + '/lib/sword'

Gem::Specification.new do |s|
  s.name = 'sword'
  s.version = Sword::VERSION

  s.files = `git ls-files`.split "\n"
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename f }

  s.date = Date.today.to_s
  s.authors = 'George'
  s.email = 'somu@so.mu'
  s.homepage = 'http://github.com/somu/sword'

  s.files = `git ls-files`.split("\n") - %w[.gitignore .travis.yml sword.sublime-project]
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename f }
  s.require_paths = %w[lib]

  s.add_dependency 'sinatra', '>= 1.3.2'
  s.add_development_dependency 'rake', '>= 10.0.2'
  s.required_ruby_version = '>= 1.8.7'

  s.license = 'MIT'
  s.summary = 'Designer’s best friend forever.'
  s.description = 'Develop using SASS/Compass, Slim, LESS &c. and convert it to static.'
end
