# frozen_string_literal: true

class OperatingSystem
  attr_reader :name, :details, :hardware_ids, :dl_link, :is_default, :firmware_id

  def initialize(name, details, is_default, hardware_ids, dl_link, firmware_id)
    @name = name
    @details = details
    @is_default = is_default
    @hardware_ids = hardware_ids
    @dl_link = dl_link
    @firmware_id = firmware_id
  end
end
