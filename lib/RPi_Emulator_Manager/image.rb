# frozen_string_literal: true

class Image
  attr_reader :id, :hardware_id, :os_id, :name

  def initialize(name, hardware_id, os_id)
    @name = name
    @hardware_id = hardware_id
    @os_id = os_id
    @id = "#{@os_id}_#{@hardware_id}_#{@name.downcase.gsub(/\W/, '_').gsub(/[^a-z0-9_-]/, '')}"
  end
end
