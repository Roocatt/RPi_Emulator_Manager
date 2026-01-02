# frozen_string_literal: true

class Firmware
  attr_reader :id, :dl_link, :is_default

  def initialize(id, dl_link, is_default)
    @id = id
    @dl_link = dl_link
    @is_default = is_default
  end

  def ensure_present(fw_dir)
    fw_path = File.join(fw_dir, "#{@id}.fw")
    unless File.exist? fw_path
      download = URI.open(@dl_link)
      IO.copy_stream(download, File.open(fw_path, 'w'))
    end
    fw_path
  end
end
