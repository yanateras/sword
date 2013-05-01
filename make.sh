gem build sword.gemspec
for gem in sword-*.gem; do
  gem push $gem
  rm $gem
done
