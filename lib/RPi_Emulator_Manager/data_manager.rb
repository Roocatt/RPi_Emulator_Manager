# frozen_string_literal: true

require 'fileutils'
require 'json'

class DataManager
  attr_reader :images, :os, :hardware, :last_image, :firmware

  def initialize(data_root = "#{Dir.home}/.rpem")
    @data_root = data_root
    @data_file = File.join data_root, 'index.json'
    @hardware = {}
    @os = {}
    @images = {}
    @firmware = {}
    @last_image = nil

    Dir.mkdir data_root unless Dir.exist? data_root
    image_dir = File.join(data_root, 'images')
    Dir.mkdir image_dir unless Dir.exist? image_dir
    fw_dir = File.join(data_root, 'fw')
    Dir.mkdir fw_dir unless Dir.exist? fw_dir

    if File.exist? @data_file
      load_data(@data_file)
    else
      File.write(@data_file, JSON.dump(Defaults.get_defaults))
      load_data(@data_file)
    end
  end

  def dump
    output = {
      hardware: [],
      os: [],
      image: [],
      firmware: [],
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
        firmware_id: operating_system.firmware_id,
      }
    end
    @images.each do |image_id, image|
      output[:image] << {
        name: image.name,
        os_id: image.os_id,
        hardware_id: image.hardware_id,
      }
    end
    @firmware.each do |firmware_id, firmware|
      output[:firmware] << {
        id: firmware_id,
        dl_link: firmware.dl_link,
      }
    end
    output[:last_image] = @last_image
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

    new_image.ensure_present(File.join(@data_root, 'images'), @os[os_id.to_sym].dl_link)
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

  def create_os(id, name, details, firmware_id, hardware_ids, dl_link)
    raise ArgumentError.new "operating system already present for id '#{id}'" if self.has_resource? :os, id.to_sym
    hardware_ids.each do |hw_id|
      raise ArgumentError.new "no hardware found for id '#{hw_id}'" unless self.has_resource? :hardware, hw_id.to_sym
    end
    raise ArgumentError.new "no firmware found for id '#{firmware_id}'" unless self.has_resource? :firmware, firmware_id.to_sym

    new_os = OperatingSystem.new(name, details, false, hardware_ids, dl_link, firmware_id)
    @os[id] = new_os
    self.save
  end

  def create_firmware(id, dl_link)
    raise ArgumentError.new "firmware already present for id '#{id}'" if self.has_resource? :firmware, id.to_sym
    firmware = Firmware.new(id, dl_link, false)
    firmware.ensure_present(File.join(@data_root, "fw"))
    @firmware[id] = firmware
  end

  def get_qemu_cmd(img_id)
    raise ArgumentError.new "no image found for id '#{img_id}'" unless self.has_resource? :image, img_id.to_sym

    image = @images[img_id.to_sym]
    fw = @firmware[@os[image.os_id.to_sym].firmware_id.to_sym]
    hardware = @hardware[image.hardware_id.to_sym]

    "qemu-system-#{hardware.qemu_arch} #{build_disk_arg(image.id)} #{hardware.qemu_args} #{build_fw_arg(fw.ensure_present(File.join(@data_root, "fw")))}"
  end

  def has_resource?(resource, id)
    case resource
    when :os
      return @os.include? id.to_sym
    when :hardware
      return @hardware.include? id.to_sym
    when :image
      return @images.include? id.to_sym
    when :firmware
      return @firmware.include? id.to_sym
    else
      nil
    end
  end

  def delete_resource(resource, id)
    case resource
    when :os
      raise ArgumentError.new("cannot delete default resource") if @os[id.to_sym].is_default
      @os.delete(id.to_sym)
    when :hardware
      raise ArgumentError.new("cannot delete default resource") if @hardware[id.to_sym].is_default
      @hardware.delete(id.to_sym)
    when :image
      @os.delete(id.to_sym)
    when :firmware
      raise ArgumentError.new("cannot delete default resource") if firmware[id.to_sym].is_default
      @firmware.delete(id.to_sym)
    else
      nil
    end
    self.save
  end

  # TODO user created resources may reference defaults that are deleted. Or new defaults may conflict IDs
  def update_defaults
    # images are always user created so ignore
    user_os = @os.filter { |k,o| !o.is_default }
    user_hw = @hardware.filter { |k,hw| !hw.is_default }
    user_fw = @firmware.filter { |k,fw| !fw.is_default }

    File.write(@data_file, JSON.dump(Defaults.get_defaults))
    @os = {}
    @hardware = {}
    @firmware = {}
    load_data(@data_file)
    @os.merge!(user_os)
    @hardware.merge!(user_hw)
    @firmware.merge!(user_fw)
    self.save
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
                                               os_entry[:hardware_ids].map { |id| id.to_sym }, os_entry[:dl_link], os_entry[:firmware_id])
    end
    json_data[:image].each do |image_entry|
      image = Image.new(image_entry[:name], image_entry[:hardware_id], image_entry[:os_id])
      @images[image.id.to_sym] = image
    end
    json_data[:firmware].each do |firmware_entry|
      @firmware[firmware_entry[:id].to_sym] = Firmware.new(firmware_entry[:id], firmware_entry[:dl_link], firmware_entry[:is_default])
    end
    @last_image = json_data[:last_image]
  end

  def build_disk_arg(name)
    "-drive file=#{File.join(@data_root, '/images/', "#{name}.img")},if=none,id=hd0,media=disk,format=raw"
  end

  def build_fw_arg(name)
    "-bios #{name}"
  end
end
