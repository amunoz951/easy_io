# Add a couple methods to the Logger class
class Logger << self
  def line(filler_character)
    info filler_character * (EasyIO::TerminalSize.columns - 25)
  end

  def header(header_text = '', header_type: :standard, filler_character: '*')
    terminal_columns = EasyIO::TerminalSize.columns
    max_header_size = terminal_columns - 31 # Allow at least 1 character on either side of the header
    header_text = header_text[0...max_header_size] if header_text.length > max_header_size # Truncate the header if it is too big
    filler = filler_character * ((terminal_columns - (header_text.length + 29)) / 2)
    info filler_character * (terminal_columns - 27) if [:primary, :secondary].include?(header_type)
    info "#{filler} #{header_text} #{filler}" + filler_character * ((terminal_columns + header_text.length + 1) % 2)
    info filler_character * (terminal_columns - 27) if header_type == :primary
  end
end

module EasyIO
  @logger = Logger.new(STDOUT)
  @logger.formatter = proc do |severity, datetime, _progname, msg|
    "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} #{severity}: #{msg}\n"
  end

  # For portability, can be overridden with a class that has methods :level, :fatal, :error, :warn, :info, :debug and the others specified below.
  # See https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html
  #
  # For example, when using with Chef, set the logger to Chef::Log
  attr_accessor :logger

  def self.levels
    {
      'info' => Logger::INFO,
      'debug' => Logger::DEBUG,
      'warn' => Logger::WARN,
      'error' => Logger::ERROR,
      'fatal' => Logger::FATAL,
      'unknown' => Logger::UNKNOWN,
    }
  end
end
