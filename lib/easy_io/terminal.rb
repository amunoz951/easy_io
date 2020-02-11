module EasyIO
  module Terminal
    module_function

    # returns [rows, columns]
    def dimensions
      require 'io/console'
      IO.console.winsize
    rescue LoadError
      # This works with older Ruby, but only with systems
      # that have a tput(1) command, such as Unix clones.
      [Integer(`tput li`), Integer(`tput co`)]
    end

    def rows
      dimensions.first
    end

    def columns
      dimensions.last
    end

    def line(filler_character)
      filler_character * (TerminalSize.columns - 1)
    end

    def interactive?
      $stdout.isatty
    end
  end
end
