class Talk; class << self
  def version; '0.4.2' end
  def build
    require "#{$dir}/build"
    Build.run!
  end
  def run
    require "#{$dir}/app"
    Sword.run!
  end
  def help
    puts "Usage: sword [<gem>/build/h/v]",
    "Require a gem: `sword <gemname>`",
    "Build your project: `sword build`"
  end
  def gem names
    $engine['gems'] |= names
    puts "Next time you run Sword,"
    puts names[1].nil? ? 
      "`#{names[0]}` gem will be avaliable." :
      "`#{names * '`, `'}` gems will be avaliable."
    File.write "#{$dir}/engine.yml",
      Psych.dump($engine)
  end
  # Aliases
  def h; self.help; end
  def v; puts "Sword #{self.version}" end
end; end
