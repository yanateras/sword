task :default do
  `bin/sword`
end

task :make do
  `gem build sword.gemspec`
  `for gem in sword-*.gem; do
    gem push $gem
    rm $gem
  done`
end

task :update do
  exec 'gem install sword && gem cleanup sword'
end
