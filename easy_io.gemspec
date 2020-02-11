# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'easy_io'
  spec.version       = '0.1.0'
  spec.authors       = ['Alex Munoz']
  spec.email         = ['amunoz951@gmail.com']
  spec.license       = 'Apache-2.0'
  spec.summary       = 'Ruby library for ease of running commands with realtime output and return results, logging, retrieving disk space info, emailing, and more.'
  spec.homepage      = 'https://github.com/amunoz951/easy_io'

  spec.required_ruby_version = '>= 2.3'

  spec.files         = Dir['LICENSE', 'lib/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'easy_format'
  spec.add_dependency 'logger'
  spec.add_dependency 'open3'
  spec.add_dependency 'fileutils'
  spec.add_dependency 'win32api'
end
