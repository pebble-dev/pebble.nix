{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchFromGitLab,
  meson,
  ninja,
  dtc,
  glib,
  libpng,
  libx11,
  pixman,
  pkg-config,
  python3,
  SDL2,

  berkeley-softfloat-3-src ? null,
  berkeley-testfloat-3-src ? null,
  keycodemapdb-src ? null,
}:

let
  berkeley-softfloat-3 =
    if berkeley-softfloat-3-src != null then
      berkeley-softfloat-3-src
    else
      fetchFromGitLab {
        owner = "qemu-project";
        repo = "berkeley-softfloat-3";
        rev = "b64af41c3276f97f0e181920400ee056b9c88037";
        hash = "sha256-Yflpx+mjU8mD5biClNpdmon24EHg4aWBZszbOur5VEA=";
      };

  berkeley-testfloat-3 =
    if berkeley-testfloat-3-src != null then
      berkeley-testfloat-3-src
    else
      fetchFromGitLab {
        owner = "qemu-project";
        repo = "berkeley-testfloat-3";
        rev = "e7af9751d9f9fd3b47911f51a5cfd08af256a9ab";
        hash = "sha256-inQAeYlmuiRtZm37xK9ypBltCJ+ycyvIeIYZK8a+RYU=";
      };

  keycodemapdb =
    if keycodemapdb-src != null then
      keycodemapdb-src
    else
      fetchFromGitLab {
        owner = "qemu-project";
        repo = "keycodemapdb";
        rev = "f5772a62ec52591ff6870b7e8ef32482371f22c6";
        hash = "sha256-GbZ5mrUYLXMi0IX4IZzles0Oyc095ij2xAsiLNJwfKQ=";
      };
in
stdenv.mkDerivation (finalAttrs: {
  name = "pebble-qemu";
  version = "10.1.5-pebble14";

  src = fetchFromGitHub {
    owner = "coredevices";
    repo = "qemu";
    rev = "v${finalAttrs.version}";
    hash = "sha256-WbW08UfDrPgIFmMbQF/O4kMdkDm93odg9Cs1eOtAGRo=";
    fetchSubmodules = true;
  };

  postUnpack = ''
    (
      cd $sourceRoot
      cp -r ${keycodemapdb} subprojects/keycodemapdb
      cp -r ${berkeley-softfloat-3} subprojects/berkeley-softfloat-3
      chmod -R u+w subprojects/berkeley-softfloat-3
      cp -r subprojects/packagefiles/berkeley-softfloat-3/* subprojects/berkeley-softfloat-3/
      cp -r ${berkeley-testfloat-3} subprojects/berkeley-testfloat-3
      chmod -R u+w subprojects/berkeley-testfloat-3
      cp -r subprojects/packagefiles/berkeley-testfloat-3/* subprojects/berkeley-testfloat-3/
    )
  '';

  nativeBuildInputs = [
    dtc
    meson
    ninja
    pkg-config
    python3
  ];

  buildInputs = [
    glib
    libpng
    libx11
    pixman
    SDL2
  ];

  dontUseMesonConfigure = true;

  configureFlags = [
    "--target-list=arm-softmmu"
    "--enable-sdl"
    "--disable-tools"
    "--disable-docs"
    "--disable-guest-agent"
    "--disable-curses"
    "--disable-gtk"
    "--disable-vte"
    "--disable-vnc-jpeg"
    "--disable-spice"
    "--disable-spice-protocol"
    "--disable-dbus-display"
    "--disable-sdl-image"
    "--disable-opengl"
    "--disable-virglrenderer"
    "--disable-rutabaga-gfx"
    "--disable-pvg"
    "--disable-gnutls"
    "--disable-gcrypt"
    "--disable-nettle"
    "--disable-libssh"
    "--disable-auth-pam"
    "--disable-libcbor"
    "--disable-crypto-afalg"
    "--disable-libusb"
    "--disable-usb-redir"
    "--disable-libudev"
    "--disable-smartcard"
    "--disable-u2f"
    "--disable-canokey"
    "--disable-tpm"
    "--disable-brlapi"
    "--disable-slirp"
    "--disable-vde"
    "--disable-vmnet"
    "--disable-netmap"
    "--disable-l2tpv3"
    "--disable-af-xdp"
    "--disable-bpf"
    "--disable-bzip2"
    "--disable-lzfse"
    "--disable-lzo"
    "--disable-snappy"
    "--disable-zstd"
    "--disable-qatzip"
    "--disable-qpl"
    "--disable-bochs"
    "--disable-cloop"
    "--disable-dmg"
    "--disable-parallels"
    "--disable-qcow1"
    "--disable-qed"
    "--disable-vdi"
    "--disable-vhdx"
    "--disable-vmdk"
    "--disable-vpc"
    "--disable-vvfat"
    "--disable-blkio"
    "--disable-curl"
    "--disable-glusterfs"
    "--disable-libiscsi"
    "--disable-libnfs"
    "--disable-rbd"
    "--disable-libpmem"
    "--disable-libdaxctl"
    "--disable-replication"
    "--disable-fuse"
    "--disable-fuse-lseek"
    "--disable-virtfs"
    "--disable-attr"
    "--disable-mpath"
    "--disable-linux-aio"
    "--disable-linux-io-uring"
    "--disable-vhost-crypto"
    "--disable-vhost-kernel"
    "--disable-vhost-net"
    "--disable-vhost-user"
    "--disable-vhost-user-blk-server"
    "--disable-vhost-vdpa"
    "--disable-libvduse"
    "--disable-vduse-blk-export"
    "--disable-hv-balloon"
    "--disable-kvm"
    "--disable-hvf"
    "--disable-whpx"
    "--disable-xen"
    "--disable-capstone"
    "--disable-gio"
    "--disable-numa"
    "--disable-rdma"
    "--disable-seccomp"
    "--disable-selinux"
    "--disable-libdw"
    "--disable-libkeyutils"
    "--disable-multiprocess"
    "--disable-vfio-user-server"
    "--disable-modules"
    "--disable-plugins"
    "--disable-rust"
    "--disable-sndio"
    "--disable-oss"
    "--disable-keyring"
  ];

  ninjaFlags = [ "qemu-system-arm" ];
  preBuild = ''
    cd build
  '';

  postInstall = ''
    mv $out/bin/qemu-system-arm $out/bin/qemu-pebble
  '';

  meta = with lib; {
    homepage = "https://github.com/pebble/qemu";
    description = "Fork of QEMU with support for Pebble devices";
    license = licenses.gpl2Plus;
    mainProgram = "qemu-pebble";
    platforms = platforms.linux ++ platforms.darwin;
  };
})
