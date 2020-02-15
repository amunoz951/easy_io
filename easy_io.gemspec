# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'easy_io'
  spec.version       = '0.1.1'
  spec.authors       = ['Alex Munoz']
  spec.email         = ['amunoz951@gmail.com']
  spec.license       = 'Apache-2.0'
  spec.summary       = 'Ruby library for ease of running commands with realtime output and return results, logging, retrieving disk space info, emailing, and more.'
  spec.homepage      = 'https://github.com/amunoz951/easy_io'

  spec.required_ruby_version = '>= 2.3'

  spec.files         = Dir['LICENSE', 'lib/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'easy_format', '~> 0'
  spec.add_dependency 'easy_json_config', '~> 0'
  spec.add_dependency 'logger', '~> 1'
  spec.add_dependency 'open3', '~> 0'
end
