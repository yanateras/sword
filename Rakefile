task :default => [:test]

task :test do
  require 'minitest/spec'
  require 'minitest/autorun'
  require './lib/main'
  Dir['./test/*.rb'].each { |l| require l.chomp '.rb' }
end

task :make do
  exec './make.sh'
end

task :update do
  exec 'gem install sword && gem cleanup sword'
end
