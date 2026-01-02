
class Defaults
  def self.get_defaults
    return {
      hardware: [ # TODO fix file path, and check all args (4b is good)
        {
          id: :rpi4b,
          name: 'RaspberryPi 4B',
          qemu_arch: 'aarch64',
          is_default: true,
          qemu_args: '-machine raspi4b -M virt -cpu cortex-a53 -smp 4 -m 4g -device virtio-blk-device,drive=hd0 -netdev type=user,id=net0 -device virtio-net-device,netdev=net0,mac=00:11:22:33:44:55 -nographic'
        },
        {
          id: :rpi3b,
          name: 'RaspberryPi 3B',
          qemu_arch: 'aarch64',
          is_default: true,
          qemu_args: '-machine raspi3b -M virt -cpu cortex-a53 -smp 4 -m 4g -device virtio-blk-device,drive=hd0 -netdev type=user,id=net0 -device virtio-net-device,netdev=net0,mac=00:11:22:33:44:55 -nographic'
        },
        {
          id: :rpi3ap,
          name: 'RaspberryPi 3A+',
          qemu_arch: 'aarch64',
          is_default: true,
          qemu_args: '-machine raspi3ap -M virt -cpu cortex-a53 -smp 4 -m 4g -device virtio-blk-device,drive=hd0 -netdev type=user,id=net0 -device virtio-net-device,netdev=net0,mac=00:11:22:33:44:55 -nographic'
        },
        {
          id: :rpi2b,
          name: 'RaspberryPi 2B',
          qemu_arch: 'aarch64',
          is_default: true,
          qemu_args: '-machine raspi2b -M virt -cpu cortex-a53 -smp 4 -m 4g -device virtio-blk-device,drive=hd0 -netdev type=user,id=net0 -device virtio-net-device,netdev=net0,mac=00:11:22:33:44:55 -nographic'
        },
        {
          id: :rpi0,
          name: 'RaspberryPi Zero',
          qemu_arch: 'aarch64',
          is_default: true,
          qemu_args: '-machine raspi0 -M virt -cpu cortex-a53 -smp 4 -m 4g -device virtio-blk-device,drive=hd0 -netdev type=user,id=net0 -device virtio-net-device,netdev=net0,mac=00:11:22:33:44:55 -nographic'
        }
      ],
      os: [
        {
          id: :netbsd_aarch64,
          name: 'NetBSD',
          details: 'v10 aarch64',
          is_default: true,
          firmware_id: :aarch64_tianocore_edk2,
          hardware_ids: [ :rpi2b, :rpi3ap, :rpi3b, :rpi4b ],
          dl_link: 'https://nycdn.netbsd.org/pub/NetBSD-daily/netbsd-10/latest/evbarm-aarch64/binary/gzimg/arm64.img.gz'
        },
        {
          id: :netbsd_armv7,
          name: 'NetBSD',
          details: 'v10 armv7',
          is_default: true,
          firmware_id: :armv7_tianocore_edk2,
          hardware_ids: [ :rpi2b, :rpi3ap, :rpi3b ],
          dl_link: 'https://nycdn.netbsd.org/pub/NetBSD-daily/netbsd-10/latest/evbarm-earmv7hf/binary/gzimg/armv7.img.gz'
        }
      ],
      firmware: [
        {
          id: 'armv7_tianocore_edk2',
          dl_link: 'https://snapshots.linaro.org/components/kernel/leg-virt-tianocore-edk2-upstream/5552/QEMU-ARM/RELEASE_GCC/QEMU_EFI.fd'
        },
        {
          id: 'aarch64_tianocore_edk2',
          dl_link: 'https://snapshots.linaro.org/components/kernel/leg-virt-tianocore-edk2-upstream/5552/QEMU-AARCH64/RELEASE_GCC/QEMU_EFI.fd'
        }
      ],
      image: []
    }
  end
end
