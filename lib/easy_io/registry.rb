module EasyIO
  module Registry
    module_function

    def read(key_path, value_name)
      ::Win32::Registry::HKEY_LOCAL_MACHINE.open(key_path, ::Win32::Registry::KEY_READ).read_s(value_name)
    end

    def key_exists?(path)
      ::Win32::Registry::HKEY_LOCAL_MACHINE.open(path, ::Win32::Registry::KEY_READ)
      true
    rescue
      false
    end
  end
end
