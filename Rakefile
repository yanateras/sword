task :default => [:test]

task :test do
  require 'minitest/spec'
  require 'minitest/autorun'

  require './lib/sword'
  Dir['./test/*.rb'].each { |t| require t.chomp '.rb' }
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
