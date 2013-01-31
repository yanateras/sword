class Sword; class << self
  def run!(options={})
    set options
    handler = detect_rack_handler
    handler_name = handler.name.gsub(/.*::/, '')
    server_settings = settings.respond_to?(:server_settings) ? settings.server_settings : {}
    handler.run self, server_settings.merge(Port: port, Host: bind) do |server|
      $stderr.puts ">> Sword #{Sword.version} at your service!\n" +
      "   http://localhost:#{port} to see your project.\n" +
      "   CTRL+C to stop."
      [:INT, :TERM].each { |sig| trap(sig) { quit!(server, handler_name) } }
      server.silent = true if server.respond_to? :silent
      server.threaded = settings.threaded if server.respond_to? :threaded=
      set :running, true
      yield server if block_given?
    end
  rescue Errno::EADDRINUSE, RuntimeError
    $stderr.puts "!! Another instance of Sword is running.\n"
  end

  def quit!(server, handler_name)
    server.respond_to?(:stop!) ? server.stop! : server.stop
    $stderr.print "\n"
  end
end; end

class Talk; class << self
  def build; end
  def run; Sword.run!; end
end; end
