class Build; class << self
  def run!
    Dir.glob("**/*").each do |f|
      p $engine['pages'] + $engine['styles']
    end
  end
end; end
