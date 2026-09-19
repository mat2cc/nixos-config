# Secondary storage: everything on this box that isn't the NixOS root drive.
#
# Mounts are named after the physical device they live on, so `df` tells you
# which piece of hardware you're looking at. Where one device holds several
# partitions they nest underneath it.
#
#   /mnt/seagate_st8000              sda      7.3T  Seagate ST8000NT001
#   /mnt/samsung_980_pro/{...}       nvme0n1  931G  Samsung SSD 980 PRO
#   /mnt/samsung_990_evo             nvme2n1  1.8T  Samsung SSD 990 EVO Plus (LUKS2 -> btrfs)
#
# nvme1n1 (WD_BLACK SN850X) is the NixOS root drive and is declared in
# hosts/nixos/hardware-configuration.nix, not here.
#
{ config, lib, pkgs, username, ... }:

let
  # Secondary drives must never be able to block boot. `nofail` downgrades a
  # failed mount to a warning, and the short device-timeout stops systemd from
  # spending 90s waiting on a drive that isn't there.
  optional = [ "nofail" "x-systemd.device-timeout=10s" ];

  # ntfs3 has no on-disk unix ownership, so it's assigned at mount time.
  # uid 1000 / gid 100 == mattc:users.
  ntfsOwner = [ "uid=1000" "gid=100" "windows_names" ];
in
{
  # ntfs3 is the in-kernel driver (faster than the ntfs-3g FUSE one). The
  # package is still worth having for `ntfsfix`, which is what you reach for
  # when Windows leaves a volume dirty.
  boot.supportedFilesystems.ntfs = true;
  boot.supportedFilesystems.btrfs = true;
  environment.systemPackages = [ pkgs.ntfs3g pkgs.btrfs-progs pkgs.cryptsetup ];

  fileSystems = {
    # --- sda: Seagate ST8000NT001, single NTFS data partition -------------
    "/mnt/seagate_st8000" = {
      device = "/dev/disk/by-uuid/10E8F13B45E34CFD";
      fsType = "ntfs3";
      options = optional ++ ntfsOwner ++ [ "rw" ];
    };

    # --- nvme0n1: Samsung 980 PRO, old Windows + Ubuntu 24.04 dual-boot --------
    # Windows C: is read-only. It's kept for reading files off, not for
    # booting, and ro sidesteps the dirty-volume/hibernation problem entirely.
    "/mnt/samsung_980_pro/windows" = {
      device = "/dev/disk/by-uuid/4268E27968E26ADD";
      fsType = "ntfs3";
      options = optional ++ ntfsOwner ++ [ "ro" ];
    };

    "/mnt/samsung_980_pro/ubuntu-root" = {
      device = "/dev/disk/by-uuid/086826b3-60a8-48c0-b3a5-cbb0e27307f8";
      fsType = "ext4";
      options = optional;
    };

    "/mnt/samsung_980_pro/ubuntu-home" = {
      device = "/dev/disk/by-uuid/376bf05a-e989-499f-9aed-3006448ee652";
      fsType = "ext4";
      options = optional;
    };

    # --- nvme2n1: Samsung 990 EVO Plus, LUKS2 -> btrfs --------------------
    # An old Arch install: subvolumes @, @home, @log, @pkg. Mounting the
    # top-level subvolume (subvolid=5) rather than @ exposes all of them at
    # once, which is what you want for an archive drive you're pulling files
    # off rather than booting.
    #
    # The device only appears once crypttab has unlocked it, so this mount is
    # ordered after that unit.
    #
    # Note the longer device-timeout: this one waits on LUKS2 key derivation
    # (Argon2id, deliberately memory-hard) rather than on hardware showing up.
    # At the 10s used elsewhere a slow unlock would trip the timeout and, with
    # `nofail`, be silently skipped — the drive would just quietly not be there.
    "/mnt/samsung_990_evo" = {
      device = "/dev/mapper/samsung_990_evo";
      fsType = "btrfs";
      options = [
        "nofail"
        "x-systemd.device-timeout=60s"
        "subvol=/"
        "x-systemd.requires=systemd-cryptsetup@samsung_990_evo.service"
      ];
    };
  };

  # The 990 EVO Plus is a LUKS2 container. It's a data drive, not root, so it
  # is unlocked *after* initrd by systemd-cryptsetup-generator rather than
  # being dragged into the initrd — a bad keyfile then degrades to "drive
  # missing" instead of "unbootable system".
  #
  # `nofail` here is what keeps a failed unlock from blocking boot.
  environment.etc.crypttab.text = ''
    samsung_990_evo UUID=c78fc2b2-e338-4bb0-ac7f-c12a9bdf8fd6 /etc/luks-keys/samsung_990_evo luks,nofail
  '';
}
