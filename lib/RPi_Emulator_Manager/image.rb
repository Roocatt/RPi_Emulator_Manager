# frozen_string_literal: true

require 'zlib'
require 'fileutils'
require 'open-uri'
require 'xz'
require 'progressbar'

class Image
  attr_reader :id, :hardware_id, :os_id, :name

  def initialize(name, hardware_id, os_id)
    @name = name
    @hardware_id = hardware_id
    @os_id = os_id
    @id = "#{@os_id}_#{@hardware_id}_#{@name.downcase.gsub(/\W/, '_').gsub(/[^a-z0-9_-]/, '')}"
  end

  def ensure_present(data_dir, dl_path)
    is_gzip = dl_path.end_with? '.gz'
    is_xz = dl_path.end_with? '.xz'
    image_destination = File.join(data_dir, "#{@id}.img")
    download_destination = "#{image_destination}#{if is_gzip then '.gz' elsif is_xz then '.xz' else '' end}"
    pbar = nil
    download = URI.open(dl_path, :content_length_proc => lambda do |t|
        if t && 0 < t
          pbar = ProgressBar.create(
            title: "Downloading image",
            total: t,
            progress_mark: '='
          )
        end
      end,
    :progress_proc => lambda {|s| pbar.progress = s if pbar })
    IO.copy_stream(download, File.open(download_destination, 'w'))

    if is_gzip
      Zlib::GzipReader.open(download_destination) do |gz|
        File.open(image_destination, 'wb') do |file|
          file.write gz.read
        end
      end
      File.delete(download_destination)
    end
    if is_xz
      XZ.decompress_file(download_destination, image_destination)
    end
    image_destination
  end
end
