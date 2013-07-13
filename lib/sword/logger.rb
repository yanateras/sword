module Sword
  module Logger
    def debug(message, symbol = false)
      if @debug
        return print symbol * 2 + ' ' + message if symbol
        print message
      end
    end

    def puts(*args)
      STDERR.puts(*args) unless @silent
    end

    def print(*args)
      STDERR.print(*args) unless @silent
    end
  end
end
