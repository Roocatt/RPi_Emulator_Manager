# frozen_string_literal: true

require 'zlib'
require 'fileutils'
require 'open-uri'
require 'json'

DEFAULT_JSON = {
  hardware: [ # TODO fix file path, and check all args (4b is good)
    {
      id: :rpi4b,
      name: 'RaspberryPi 4B',
      qemu_arch: 'aarch64',
      is_default: true,
      qemu_args: '-machine raspi4b -M virt -cpu cortex-a53 -smp 4 -m 4g -drive file=./arm64.img,if=none,id=hd0,media=disk,format=raw -device virtio-blk-device,drive=hd0 -netdev type=user,id=net0 -device virtio-net-device,netdev=net0,mac=00:11:22:33:44:55 -bios QEMU_EFI.fd -nographic'
    },
    {
      id: :rpi3b,
      name: 'RaspberryPi 3B',
      qemu_arch: 'aarch64',
      is_default: true,
      qemu_args: '-machine raspi3b -M virt -cpu cortex-a53 -smp 4 -m 4g -drive file=./arm64.img,if=none,id=hd0,media=disk,format=raw -device virtio-blk-device,drive=hd0 -netdev type=user,id=net0 -device virtio-net-device,netdev=net0,mac=00:11:22:33:44:55 -bios QEMU_EFI.fd -nographic'
    },
    {
      id: :rpi3ap,
      name: 'RaspberryPi 3A+',
      qemu_arch: 'aarch64',
      is_default: true,
      qemu_args: '-machine raspi3ap -M virt -cpu cortex-a53 -smp 4 -m 4g -drive file=./arm64.img,if=none,id=hd0,media=disk,format=raw -device virtio-blk-device,drive=hd0 -netdev type=user,id=net0 -device virtio-net-device,netdev=net0,mac=00:11:22:33:44:55 -bios QEMU_EFI.fd -nographic'
    },
    {
      id: :rpi2b,
      name: 'RaspberryPi 2B',
      qemu_arch: 'aarch64',
      is_default: true,
      qemu_args: '-machine raspi2b -M virt -cpu cortex-a53 -smp 4 -m 4g -drive file=./arm64.img,if=none,id=hd0,media=disk,format=raw -device virtio-blk-device,drive=hd0 -netdev type=user,id=net0 -device virtio-net-device,netdev=net0,mac=00:11:22:33:44:55 -bios QEMU_EFI.fd -nographic'
    },
    {
      id: :rpi1ap,
      name: 'RaspberryPi 1A+',
      qemu_arch: 'arm',
      is_default: true,
      qemu_args: '-machine raspi1ap -M virt -cpu cortex-a53 -smp 4 -m 4g -drive file=./arm64.img,if=none,id=hd0,media=disk,format=raw -device virtio-blk-device,drive=hd0 -netdev type=user,id=net0 -device virtio-net-device,netdev=net0,mac=00:11:22:33:44:55 -bios QEMU_EFI.fd -nographic'
    },
    {
      id: :rpi0,
      name: 'RaspberryPi Zero',
      qemu_arch: 'aarch64',
      is_default: true,
      qemu_args: '-machine raspi0 -M virt -cpu cortex-a53 -smp 4 -m 4g -device virtio-blk-device,drive=hd0 -netdev type=user,id=net0 -device virtio-net-device,netdev=net0,mac=00:11:22:33:44:55 -bios QEMU_EFI.fd -nographic'
    }
  ],
  os: [
    {
      id: :netbsd_aarch64,
      name: 'NetBSD',
      details: 'v10 aarch64',
      is_default: true,
      hardware_ids: [ :rpi2b, :rpi3ap, :rpi3b, :rpi4b ],
      dl_link: 'https://nycdn.netbsd.org/pub/NetBSD-daily/netbsd-10/latest/evbarm-aarch64/binary/gzimg/arm64.img.gz'
    },
    {
      id: :netbsd_armv7,
      name: 'NetBSD',
      details: 'v10 armv7',
      is_default: true,
      hardware_ids: [ :rpi2b, :rpi3ap, :rpi3b ],
      dl_link: 'https://nycdn.netbsd.org/pub/NetBSD-daily/netbsd-10/latest/evbarm-earmv7hf/binary/gzimg/armv7.img.gz'
    },
    {
      id: :netbsd_armv6,
      name: 'NetBSD',
      details: 'v10 armv6',
      is_default: true,
      hardware_ids: [ :rpi1ap ],
      dl_link: 'http://nycdn.netbsd.org/pub/NetBSD-daily/netbsd-10/latest/evbarm-earmv6hf/binary/gzimg/rpi.img.gz'
    }
  ],
  image: []
}

class DataManager
  attr_reader :images, :os, :hardware

  def initialize(data_root = "#{Dir.home}/.rpem")
    @data_root = data_root
    @data_file = File.join data_root, 'index.json'
    @hardware = {}
    @os = {}
    @images = {}


    Dir.mkdir data_root unless Dir.exist? data_root
    image_dir = File.join(data_root, 'images')
    Dir.mkdir image_dir unless Dir.exist? image_dir

    if File.exist? @data_file
      load_data(@data_file)
    else
      File.write(@data_file, JSON.dump(DEFAULT_JSON))
      load_data(@data_file)
    end
  end

  def dump
    output = {
      hardware: [],
      os: [],
      image: []
    }
    @hardware.each do |hardware_id, hardware|
      output[:hardware] << {
        id: hardware_id,
        name: hardware.name,
        is_default: hardware.is_default,
        qemu_arch: hardware.qemu_arch,
        qemu_args: hardware.qemu_args,
      }
    end
    @os.each do |os_id, operating_system|
      output[:os] << {
        id: os_id,
        name: operating_system.name,
        details: operating_system.details,
        is_default: operating_system.is_default,
        hardware_ids: operating_system.hardware_ids,
        dl_link: operating_system.dl_link,
      }
    end
    @images.each do |image_id, image|
      output[:image] << {
        name: image.name,
        os_id: image.os_id,
        hardware_id: image.hardware_id,
      }
    end
    JSON.dump(output)
  end

  def save
    File.write(@data_file, self.dump)
  end

  def create_image(name, hardware_id, os_id)
    raise ArgumentError.new "no hardware found for id '#{hardware}'" unless self.has_resource? :hardware, hardware_id.to_sym
    raise ArgumentError.new "no operating system found for id '#{os}'" unless self.has_resource? :os, os_id.to_sym

    new_image = Image.new(name, hardware_id, os_id)

    raise ArgumentError.new "identical image named '#{name}' with os '#{os_id}' and hardware '#{hardware_id}'" if self.has_resource? :image, new_image.id

    dl_path = @os[os_id.to_sym].dl_link
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
    @images[new_image.id] = new_image
    self.save
    nil
  end


  def create_hardware(id, name, qemu_arch, qemu_args)
    raise ArgumentError.new "hardware already present for id '#{id}'" if self.has_resource? :hardware, id.to_sym

    hardware = Hardware.new(name, false, qemu_arch, qemu_args)
    @hardware[id] = hardware
    self.save
  end

  def create_os(id, name, details, hardware_ids, dl_link)
    raise ArgumentError.new "operating system already present for id '#{id}'" if self.has_resource? :os, id.to_sym
    hardware_ids.each do |hw_id|
      raise ArgumentError.new "no hardware found for id '#{hw_id}'" unless self.has_resource? :hardware, hw_id.to_sym
    end

    new_os = OperatingSystem.new(name, details, false, hardware_ids, dl_link)
    @os[id] = new_os
    self.save
  end

  def get_qemu_cmd(img_id)
    raise ArgumentError.new "no image found for id '#{os}'" unless self.has_resource? :image, img_id.to_sym

    image = @images[img_id.to_sym]
    hardware = @hardware[image.hardware_id.to_sym]

    "qemu-system-#{hardware.qemu_arch} #{hardware.qemu_args} #{build_disk_arg(image.id)}"
  end

  def has_resource?(resource, id)
    case resource
    when :os
      return @os.include? id.to_sym
    when :hardware
      return @hardware.include? id.to_sym
    when :image
      return @images.include? id.to_sym
    else
      nil
    end
  end

  private

  def load_data(data_file)
    json_data = JSON.parse(File.read(data_file), symbolize_names: true)
    json_data[:hardware].each do |hardware_entry|
      @hardware[hardware_entry[:id].to_sym] = Hardware.new(hardware_entry[:name], hardware_entry[:is_default],
                                                    hardware_entry[:qemu_arch], hardware_entry[:qemu_args])
    end
    json_data[:os].each do |os_entry|
      @os[os_entry[:id].to_sym] = OperatingSystem.new(os_entry[:name], os_entry[:details], os_entry[:is_default],
                                               os_entry[:hardware_ids].map { |id| id.to_sym }, os_entry[:dl_link])
    end
    json_data[:image].each do |image_entry|
      image = Image.new(image_entry[:name], image_entry[:hardware_id], image_entry[:os_id])
      @images[image.id.to_sym] = image
    end
  end

  def build_disk_arg(name)
    "-drive file=#{File.join(@data_root, '/images/', "#{name}.img")},if=none,id=hd0,media=disk,format=raw"
  end
end
