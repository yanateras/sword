task :default => [:test]

task :test do
  %w[/lib /test].each { |dir| $:.unshift File.dirname(__FILE__) + dir }
  require 'minitest/spec'
  require 'minitest/autorun'
  require 'main'
  
  Dir['./test/*.rb'].each { |t| require t[/[^\/]+(?=\.)/] }
end

task :make do
  system 'gem build sword.gemspec
  for gem in sword-*.gem; do
    gem push $gem
    rm $gem
  done'
end

task :update do
  system 'gem install sword && gem cleanup sword'
end
