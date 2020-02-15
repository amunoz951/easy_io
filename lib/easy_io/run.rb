module EasyIO
  module_function

  # execute a command with real-time output. Any stdout you want returned to the caller must come after the :output_separator which defaults to '#return_data#:'
  #   return_all_stdout: return all output to the caller instead after process completion
  def execute_out(command, pid_logfile: nil, working_folder: Dir.pwd, regex_error_filters: [], info_on_exception: '', exception_exceptions: [], powershell: false, show_command_on_error: false, raise_on_first_error: true, return_all_stdout: false, output_separator: nil)
    output_separator ||= '#return_data#:'
    if return_all_stdout
      result = ''
      return_data_flag = true
    else
      STDOUT.sync = true
      result = nil
      return_data_flag = false
    end
    exit_status = nil
    error_messages = []
    info_on_exception = "#{info_on_exception}\n" unless info_on_exception.end_with?("\n")
    error_options = { 'show_command_on_error' => show_command_on_error, 'info_on_exception' => info_on_exception, 'regex_error_filters' => regex_error_filters, 'raise_on_first_error' => raise_on_first_error }
    if powershell
      ps_script_file = "#{EasyIO.config['paths']['cache']}/scripts/ps_script-thread_id-#{Thread.current.object_id}.ps1"
      FileUtils.mkdir_p(::File.dirname(ps_script_file)) unless ::File.directory? ::File.dirname(ps_script_file)
      ::File.write(ps_script_file, command)
    end
    popen_arguments = powershell ? ['powershell.exe', ps_script_file] : [command]
    Dir.chdir(working_folder) do
      Open3.popen3(*popen_arguments) do |_stdin, stdout, stderr, wait_thread|
        unless pid_logfile.nil? # Log pid in case job or script dies
          FileUtils.mkdir_p(::File.dirname(pid_logfile)) unless ::File.directory? ::File.dirname(pid_logfile)
          ::File.write(pid_logfile, wait_thread.pid)
        end
        buffers = [stdout, stderr]
        queued_buffers = IO.select(buffers) || [[]]
        queued_buffers.first.each do |buffer|
          case buffer
          when stdout
            while (line = buffer.gets)
              if return_data_flag
                result += line
                next
              end
              stdout_split = line.split(output_separator)
              stdout_message = stdout_split.first.strip
              _parse_for_errors(stdout_message, error_messages, error_options, command)
              EasyIO.logger.info stdout_message unless stdout_message.empty?
              if stdout_split.count > 1
                return_data_flag = true
                result = stdout_split.last
              end
            end
          when stderr
            error_message = ''
            error_message += line while (line = buffer.gets)
            next if error_message.empty?
            if exception_exceptions.any? { |ignore_filter| error_message =~ ignore_filter }
              EasyIO.logger.info error_message.strip
              next
            end
            _process_error_message(error_message, error_messages, error_options, command)
          end
        end
        exit_status = wait_thread.value
      end
    end
    unless error_messages.empty?
      last_error = _full_error_message(error_messages.pop, error_options, command)
      error_messages.map! { |error_message| _full_error_message(error_message, error_options, nil) }
      error_messages.push(last_error)
      raise error_messages.join("\n")
    end
    [result, exit_status]
  end

  # execute a powershell script with real-time output. Any stdout you want returned to the caller must come after the :output_separator which defaults to '#return_data#:'
  #   return_all_stdout: return all output to the caller instead after process completion
  def powershell_out(ps_script, pid_logfile: nil, working_folder: Dir.pwd, regex_error_filters: [], info_on_exception: '', exception_exceptions: [], show_command_on_error: false, return_all_stdout: false, output_separator: nil)
    execute_out(ps_script, pid_logfile: pid_logfile, working_folder: working_folder, regex_error_filters: regex_error_filters, info_on_exception: info_on_exception, exception_exceptions: exception_exceptions, powershell: true, show_command_on_error: show_command_on_error, return_all_stdout: return_all_stdout, output_separator: output_separator)
  end

  def _parse_for_errors(message, error_messages, error_options, command)
    errors_found = error_options['regex_error_filters'].any? { |regex_filter| message =~ regex_filter }
    _process_error_message(message, error_messages, error_options, command) if errors_found
  end

  def _process_error_message(error_message, error_messages, error_options, command)
    raise _full_error_message(error_message, error_options, command) if error_options['raise_on_first_error']
    error_messages.push(error_message) # if we're not raising right away, add to the list of errors
  end

  def _full_error_message(error_message, error_options, command)
    command_message = error_options['show_command_on_error'] && command ? "\nCommand causing exception: " + command + "\n" : ''
    "Exception: #{error_message}\n#{error_options['info_on_exception']}#{'=' * 120}\n#{command_message}"
  end

  def pid_running?(pid)
    begin
      Process.kill(0, pid) # Does not actually kill process, checks if it's running.
    rescue Errno::ESRCH
      nil
    end == 1
  end

  def notepad_prompt(text_file_path, comment)
    ::FileUtils.mkdir_p ::File.dirname(text_file_path) unless ::File.directory?(::File.dirname(text_file_path))
    ::File.write(text_file_path, "; #{comment}") unless ::File.exist?(text_file_path)
    EasyIO.logger.info comment.gsub('here', 'in the notepad window')
    `notepad #{text_file_path}`
    notepad_content = ::File.read(text_file_path)
    notepad_content.gsub(/;[^\r\n]*(\r\n|\r|\n)/i, '') # remove comments in text file
  end
end
