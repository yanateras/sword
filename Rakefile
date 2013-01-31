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
  `./bin/sword`
end

task :build do
  task :run
  builder = SinatraStatic.new(Pony)
  builder.build!('build')
  `zip -9 -r build.zip build`
  `rm build`
  puts '`build.zip` is ready'
  exit
end
