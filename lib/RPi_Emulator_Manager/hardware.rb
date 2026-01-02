# frozen_string_literal: true

class Hardware
  attr_reader :name, :qemu_arch, :qemu_args, :is_default

  def initialize(name, is_default, qemu_arch, qemu_args)
    @name = name
    @is_default = is_default
    @qemu_arch = qemu_arch
    @qemu_args = qemu_args
  end
end
