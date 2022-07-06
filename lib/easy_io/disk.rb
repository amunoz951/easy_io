module EasyIO
  module Disk
    module_function

    def free_space(path)
      raise 'Cannot check free space for path provided. Path is empty or nil.' if path.nil? || path.empty? || path == 'null'
      root_folder = root_directory(path)

      raise "Cannot check free space for #{path} - The path was not found." if root_folder.nil? || root_folder.empty?
      root_folder = EasyFormat::Directory.ensure_trailing_slash(root_folder)

      (Sys::Filesystem.stat(root_folder).bytes_free / 1024.0 / 1024.0).round(2)
    end

    def size(path)
      raise 'Cannot check free space for path provided. Path is empty or nil.' if path.nil? || path.empty? || path == 'null'
      root_folder = root_directory(path)

      raise "Cannot check free space for #{path} - The path was not found." if root_folder.nil? || root_folder.empty?
      root_folder = EasyFormat::Directory.ensure_trailing_slash(root_folder)

      (Sys::Filesystem.stat(root_folder).bytes_total / 1024.0 / 1024.0).round(2)
    end

    def move_files(search_string, destination_folder)
      files = Dir.glob(search_string.tr('\\', '/'))
      FileUtils.mkdir_p destination_folder unless ::File.directory? destination_folder
      FileUtils.move(files, destination_folder) { true }
    end

    def read_files(search_string)
      files = Dir.glob(search_string.tr('\\', '/'))
      files.map { |file| ::File.read(file) }
    end

    # Gets the root directory of a path. Local and UNC paths accepted
    def root_directory(path)
      computed_path = path
      computed_path = File.dirname(computed_path) while computed_path != File.dirname(computed_path)
      computed_path
    end

    def valid_checksum?(file, sha256_checksum)
      return false if sha256_checksum.nil? || !::File.exist?(file)
      Digest::SHA256.file(file).hexdigest.downcase == sha256_checksum.downcase
    end

    # Opens a file in the filesystem and locks it exclusively. If it fails, it will keep trying until the timeout.
    # Pass a block to be executed while the file is locked. The ::File object is passed to the block.
    def open_file_and_wait_for_exclusive_lock(path, timeout: 60, status_interval: 15, silent: false)
      start_time = Time.now
      raise "Cannot create #{::File.basename(path)} - the parent directory does not exist (#{::File.dirname(path)})!" unless ::File.directory?(::File.dirname(path))
      ::File.open(path, ::File::RDWR | ::File::CREAT) do |file|
        loop do
          if Time.now >= start_time + timeout # locking timed out.
            file.close
            raise "Failed to gain exclusive lock on #{path}! Timed out after #{timeout} seconds."
          end
          lock_success = file.flock(File::LOCK_EX | File::LOCK_NB)
          if lock_success
            yield(file) if block_given?
            file.close
            break
          end
          seconds_elapsed = Time.now - start_time
          EasyIO.logger.info "Waiting for another process to unlock #{path}... Time elapsed: #{seconds_elapsed}" if seconds_elapsed % status_interval == 0 && !silent # Output status every (status_interval) seconds
          sleep(1)
        end
      end
    end
  end
end
