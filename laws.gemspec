Gem::Specification.new do |spec|
  spec.name = 'lazy-aws-cli'
  spec.version = '0.0.1'
  spec.authors = ['Physium']
  spec.email = ['wjloh91@gmail.com']
  spec.summary = 'AWS CLI Easy Mode'
  spec.description = 'Helps figure out your missing option inputs'
  spec.homepage = 'https://github.com/Physium/lazy-aws-cli'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.3.1'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*', 'bin/*', '*.gemspec', 'README.md', 'LICENSE']
  spec.bindir = 'bin'
  spec.executables = ['laws']
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-ecs', '~> 1.0'
  spec.add_dependency 'aws-sdk-secretsmanager', '~> 1.0'
  spec.add_dependency 'tty-prompt', '~> 0.23'
end
