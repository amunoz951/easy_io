#
# Author:: Alex Munoz (<amunoz951@gmail.com>)
# Copyright:: Copyright (c) 2020 Alex Munoz
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'easy_format'
require 'easy_json_config'
require 'logger'
require 'open3'
require 'fileutils'
require 'tmpdir'
require 'os'
require 'digest'
require 'sys/filesystem'
require 'win32/registry' if OS.windows? && !defined?(::Win32::Registry)

require_relative 'easy_io/config'
require_relative 'easy_io/disk'
require_relative 'easy_io/logger'
require_relative 'easy_io/registry' if OS.windows?
require_relative 'easy_io/run'
require_relative 'easy_io/terminal'
