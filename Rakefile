require 'bundler/setup'
Bundler.require :default
require 'sinatra_static'
require 'sinatra/advanced_routes'

task default: [:run]

task :gem do
  `gem build sword.gemspec`
  `for gem in sword-*.gem; do
    gem push $gem
    rm $gem
  done`
end

task :update do
  print `gem install sword && gem cleanup sword`
end

task :run do
  ruby 'app.rb'
end

task :build do
  require 'rack/test'
  task :run
  builder = SinatraStatic.new(Pony)
  builder.build!('build')
  `zip -9 -r build.zip build`
  `rm build`
  puts '`build.zip` is ready'
  exit
end
