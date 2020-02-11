module EasyIO
  unless defined? GetDiskFreeSpaceEx
    # TODO: make this cross platform. sys-filesystem gem maybe?
    if RUBY_PLATFORM =~ /cygwin|mswin|mingw|bccwin|wince|emx/
      require 'win32api'
      GetDiskFreeSpaceEx = Win32API.new('kernel32', 'GetDiskFreeSpaceEx', 'PPPP', 'I')
    end
  end

  module_function

  def disk_free_space(path)
    raise 'Cannot check free space for path provided. Path is empty or nil.' if path.nil? || path.empty? || path == 'null'
    root_folder = root_directory(path)

    raise "Cannot check free space for #{path} - The path was not found." if root_folder.nil? || root_folder.empty?
    root_folder = EasyFormat::Directory.ensure_trailing_slash(root_folder)

    free = [0].pack('Q')
    GetDiskFreeSpaceEx.call(root_folder, 0, 0, free)
    free = free.unpack1('Q')

    (free / 1024.0 / 1024.0).round(2)
  end

  def disk_size(path)
    raise 'Cannot check free space for path provided. Path is empty or nil.' if path.nil? || path.empty? || path == 'null'
    root_folder = root_directory(path)

    raise "Cannot check free space for #{path} - The path was not found." if root_folder.nil? || root_folder.empty?
    root_folder = EasyFormat::Directory.ensure_trailing_slash(root_folder)

    total = [0].pack('Q')
    GetDiskFreeSpaceEx.call(root_folder, 0, total, 0)
    total = total.unpack1('Q')

    (total / 1024.0 / 1024.0).round(2)
  end

  def move_files(search_string, destination_folder)
    files = Dir.glob(search_string.tr('\\', '/'))
    FileUtils.mkdir_p destination_folder
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
end
