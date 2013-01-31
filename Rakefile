task default: [:gem]

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
