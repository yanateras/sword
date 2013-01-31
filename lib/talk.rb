class Talk; class << self
  def build
    `mkdir build`
    SinatraStatic.new(Sword)
      .build! 'build'
    `zip -9 -r build.zip build`
    `rm -r build`
    puts '`build.zip` is ready'
  end
  def run; Sword.run!; end
end; end
