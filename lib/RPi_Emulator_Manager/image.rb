# frozen_string_literal: true

require 'zlib'
require 'fileutils'
require 'open-uri'

class Image
  attr_reader :id, :hardware_id, :os_id, :name

  def initialize(name, hardware_id, os_id)
    @name = name
    @hardware_id = hardware_id
    @os_id = os_id
    @id = "#{@os_id}_#{@hardware_id}_#{@name.downcase.gsub(/\W/, '_').gsub(/[^a-z0-9_-]/, '')}"
  end

  def ensure_present(dl_path)
    is_gzip = dl_path.end_with? '.gz'
    image_destination = File.join(@data_root, 'images', "#{new_image.id}.img")
    download_destination = "#{image_destination}#{if is_gzip then '.gz' else '' end}"
    download = URI.open(dl_path)
    IO.copy_stream(download, File.open(download_destination, 'w'))

    if is_gzip
      Zlib::GzipReader.open(download_destination) do |gz|
        File.open(image_destination, 'wb') do |file|
          file.write gz.read
        end
      end
      File.delete(download_destination)
    end
    image_destination
  end
end
