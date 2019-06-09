#
# Mark Karpov's NixOS configuration
#
# https://github.com/mrkkrp/nix-workstation
#

{ config, pkgs, ... }:

{
  ##########################################################
  # General

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # This value determines the NixOS release with which your
  # system is to be compatible, in order to avoid breaking
  # some software such as database servers. You should
  # change this only after NixOS release notes say you
  # should.
  system.stateVersion = "17.09";

  ##########################################################
  # Boot

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # This is only needed for BIOS systems:
  # boot.loader.grub.device = "/dev/sda";
  # boot.loader.timeout = 0;
  boot.earlyVconsoleSetup = true;

  ##########################################################
  # Extra file systems and swap

  fileSystems = {
    "/home/mark/store" = {
      device = "/dev/sdb1";
      fsType = "ext4";
    };
  };

  swapDevices = [
    { device = "/dev/sda2"; }
  ];

  ##########################################################
  # Packages

  nixpkgs = {
    system = "x86_64-linux";
    config = {
      pulseaudio = true;
      allowUnfree = true;
    };
  };

  nix = {
    package = pkgs.nixUnstable;
    trustedBinaryCaches = [
      "https://cache.nixos.org"
    ];
    binaryCaches = [
      "https://cache.nixos.org"
    ];
    gc.automatic = false;
    maxJobs = pkgs.stdenv.lib.mkForce 6;
    nixPath = [
      "nixpkgs=/home/mark/nixpkgs"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
  };

  environment.systemPackages = with pkgs; [
    alsaLib
    alsaOss
    alsaPlugins
    alsaTools
    alsaUtils
    aspell
    aspellDicts.en
    aspellDicts.ru
    autoconf
    automake
    bash
    binutils
    bzip2
    cargo
    coreutils
    cups
    diffutils
    docker
    dosfstools
    e2fsprogs
    eject
    emacs
    file
    findutils
    fish
    gcc
    gdb
    git
    glibc
    gnugrep
    gnumake
    gnupg
    gnused
    gnutar
    gnutls
    google-chrome
    groff
    htop
    inetutils
    less
    libtool
    man
    man-pages
    mupdf
    nano
    networkmanager
    nginxMainline
    ntfs3g
    ntp
    openssl
    openvpn
    p7zip
    patch
    pavucontrol
    postgresql
    pulseaudioFull
    python3Full
    ruby
    rustc
    sudo
    texlive.combined.scheme-full
    tor
    unzip
    vim
    wget
    which
    zip
  ];

  ##########################################################
  # Users

  security.sudo.enable = true;
  users.mutableUsers = false;
  users.defaultUserShell = pkgs.bash;

  users.users.mark = {
    isNormalUser = true;
    createHome = true;
    description = "Mark Karpov";
    extraGroups = [
      "audio"
      "docker"
      "networkmanager"
      "video"
      "wheel"
    ];
    hashedPassword = "$6$rBDWl6/g.dgUp$l6fYq.V1jzQRzsY9o6hSqsB77XAWVjSTLmcrzbjW7zl9DvNeO2LfjOHEOzH7j9Mr1WFofl6FO3CkyITN/UzRp0";
    packages = with pkgs; [
      AgdaStdlib
      bazel
      cabal-install
      coq
      flac
      gimp
      haskellPackages.Agda
      haskellPackages.brittany
      haskellPackages.ghcid
      haskellPackages.hasktags
      haskellPackages.hlint
      inkscape
      inotify-tools
      kid3
      lame
      pwsafe
      qbittorrent
      qiv
      stack
      tdesktop
      vlc
      wmctrl
    ];
    shell = "${pkgs.fish}/bin/fish";
  };

  ##########################################################
  # Fish

  programs.fish = {
    enable = true;
    shellInit = ''
      set -U fish_greeting ""
      set -U fish_user_paths $fish_user_paths ~/.local/bin
    '';
    shellAliases = {
      e  = "emacsclient";
      ls = "ls --human-readable --almost-all --color=auto";
    };
  };

  ##########################################################
  # Networking

  networking = {
    hostName = "nixos";
    firewall = {
      enable = true;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
    networkmanager.enable = true;
  };

  # wireless = {
  #   enable = true;
  #   networks = {
  #     "new-one" = {
  #       psk = "noganoga";
  #     };
  #   };
  # };

  ##########################################################
  # Misc services

  # services.openssh.enable = true;
  services.printing.enable = true;
  services.tor.enable = true;

  ##########################################################
  # GNUPG

  programs.gnupg.agent.enable = true;

  ##########################################################
  # Time

  time.timeZone = "Europe/Paris";
  services.ntp.enable = true;

  ##########################################################
  # Locale

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  ##########################################################
  # Fonts

  fonts = {
    fontconfig.enable = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      google-fonts
    ];
  };

  ##########################################################
  # Audio

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  ##########################################################
  # X server

  services.xserver = {
    enable = true;
    layout = "us";
    libinput.enable = true;
    # videoDrivers = ["nvidia"]; # or "ati_unfree"

    desktopManager = {
      plasma5.enable = true;
      default = "plasma5";
    };

    displayManager = {
      sddm.enable = true;
      sessionCommands = "export PATH=$HOME/.local/bin:$PATH";
    };
  };

  services.redshift = {
    enable = true;
    latitude = "52";
    longitude = "85";
    temperature.day = 5500;
    temperature.night = 3700;
  };

  ##########################################################
  # Virtualization

  virtualisation.docker.enable = true;

  ##########################################################
  # Nginx

  services.nginx.virtualHosts = {
    "localhost" = {
       listen = [
         {
           addr = "localhost";
           port = 5000;
         }
       ];
       locations."/" = {
         root = "/home/mark/projects/programs/haskell/markkarpov.com/_build/";
         index = "posts.html index.htm";
         extraConfig = "error_page 404 = /404.html;";
       };
    };
  };
  services.nginx.user = "mark";
  services.nginx.enable = true;
}
