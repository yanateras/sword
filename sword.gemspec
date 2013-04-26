# encoding: utf-8
require Pathname.new(__FILE__).dirname.realpath.to_s + '/lib/constants'
Gem::Specification.new do |s|
  s.name = 'sword'
  s.version = Sword::VERSION
  s.platform = Gem::Platform::RUBY

  s.files = `git ls-files`.split "\n"
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename f }
  s.require_paths = %w[lib]

  s.authors = %w[George]
  s.date = Date.today.to_s
  s.email = 'somu@so.mu'
  s.homepage = 'http://github.com/somu/sword'

  s.license = 'MIT'
  s.required_ruby_version = '>= 1.8.7'
  s.summary = 'Designer’s best friend forever.'
  s.description = 'Develop using SASS/Compass, Slim, LESS &c. and convert it to static.'
end
