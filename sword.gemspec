# encoding: utf-8

version = `gem list sword -r`[/(?<=\().+(?=\))/] #=> (0.1.5)
  .split('.')
  .map { |v| v.to_i }
version[2] += 1

if version[2] >= 10 
  version[1] += 1
  version[2] = 0
end

if version[1] >= 10 
  version[0] += 1
  version[1] = 0
end

Gem::Specification.new do |s|
  s.name = 'sword'
  s.platform = Gem::Platform::RUBY
  s.files = `git ls-files`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  # s.require_paths = %w[lib]
  s.authors = %w[George ソム]
  s.date = Date.today.to_s
  s.email = 'somu@so.mu'
  s.homepage = 'http://so.mu/blog/sword'
  s.licenses = %w[MIT]
  s.description = "Design development unabridged."
  s.summary = "Develop using SASS/Compass, Slim, LESS &c. and convert it to static."

  %w[
    sinatra 1.3.2
    sinatra-static 0.1.1
    sinatra-advanced-routes 0.5.1

    compass 0.12.2
    slim 1.3.6
    less 2.2.2
    therubyracer 0.10.2

    thin 1.5.0
    rack-test 0.6.2
    bundler 1.2.3
    rake 10.0.3
  ].each_slice(2) do |n, v|
    s.add_dependency(n, [] << "~> #{v}")
  end
end
