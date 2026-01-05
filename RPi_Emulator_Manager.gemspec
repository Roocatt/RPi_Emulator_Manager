# frozen_string_literal: true

require_relative "lib/RPi_Emulator_Manager/version"

Gem::Specification.new do |spec|
  spec.name = 'RPi_Emulator_Manager'
  spec.version = RPiEmulatorManager::VERSION
  spec.authors = [ 'Roos Catling-Tate' ]
  spec.email = [ 'roos@catling-tate.net' ]

  spec.summary = 'A basic tool for easily running QEMU commands for Raspberry Pi devices.'
  spec.description = 'A basic tool for easier QEMU emulation of Raspberry Pi devices. Automatically download images '
  + 'and run QEMU without dealing with a long list of command arguments.'
  spec.homepage = 'https://github.com/Roocatt/RPi_Emulator_Manager'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata["allowed_push_host"] = 'null'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Roocatt/RPi_Emulator_Manager'
  spec.metadata['changelog_uri'] = 'https://github.com/Roocatt/RPi_Emulator_Manager/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = [ 'lib' ]
  spec.add_dependency 'ruby-xz', '~> 1.0', '>= 1.0.3'
  spec.add_dependency 'progressbar', '~> 1.13'
end
