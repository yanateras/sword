module Sword
  module Boot
    module Require
      def require_list(list)
        debug "Including gems:\n", ' '
        list.each do |l|
          if Hash === l
            require_any(l)
          elsif String === l
            require_gem(l)
          else
            raise LoadError, 'Require list should contain hashes and strings only'
          end
        end
      end

      def require_any(hash)
        options.values.first.each do |option|
          begin
            debug option + '.' * (15 - option.length), '  '
            require option
            debug "OK\n"
            break
          rescue LoadError
            debug "Fail\n"
            next
          end
        end
      end

      def require_gem(name)
        begin
          debug lib + '.' * (15 - lib.length), '  '
          require lib
          debug "OK\n"
        rescue LoadError
          debug "Fail\n"
        end
      end
    end
  end
end
