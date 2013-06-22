task :default => [:test]

task :test do
  require 'rubygems'
  require 'rspec/autorun'
  require 'rspec'
  require 'rack/test'

  require './lib/sword'
  Dir['./test/*.rb'].each { |t| require t.chomp '.rb' }
end

task :gem do
  system 'gem build sword.gemspec
  for gem in sword-*.gem; do
    gem push $gem
    rm $gem
  done'
end

task :doc do
  system 'yard doc'
end

task :update do
  system 'gem install sword && gem cleanup sword'
end
