# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.nix-index-database.nixosModules.nix-index
    #inputs.niri.nixosModules.niri
    ./fonts.nix
  ];

  inherit ((import ./disko.nix { device = "/dev/nvme0n1"; })) disko;

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount /dev/root_vg/root /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';

  fileSystems."/boot".options = [
    "uid=0"
    "gid=0"
    "fmask=0077"
    "dmask=0077"
    "umask=0077"
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs;
    };
    users.hazel = import ../../homes/hazel/home.nix;
  };

  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist" = {
    enable = true; # NB: Defaults to true, not needed
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/etc/nixos"
      # if you want to save a root ssh key in /etc/ssh, then you will have to add something like this
      {
        directory = "/etc/ssh";
        mode = "600"; # might not be right idk
      }
      {
        directory = "/var/lib/colord";
        user = "colord";
        group = "colord";
        mode = "u=rwx,g=rx,o=";
      }
    ];
    files = [
      "/etc/machine-id"
      {
        file = "/var/keys/secret_file";
        parentDirectory = {
          mode = "u=rwx,g=,o=";
        };
      }
    ];
    users.root = {
      home = "/root";
      directories = [
        ".config"
        {
          directory = ".ssh";
          mode = "0700";
        }
      ];
    };
    users.hazel = {
      directories = [
        #".nix-profile"
        "Music"
        "Pictures"
        "Documents"
        "Projects"
        "Videos"
        ".local/state/home-manager"
        {
          directory = ".nixops";
          mode = "0700";
        }
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".config";
          mode = "0700";
        }
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
        ".local/share/direnv"
      ];
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 24; # lower this if "nh os switch" fails because of no space on /boot, then run "sudo nix store gc"
    editor = false; # by default this is true TwT
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # willow tweaks:
  # catppuccin boot :3
  boot.kernelParams = [
    "vt.default_red=0,243,166,249,137,245,148,186,88,243,166,249,137,245,148,166"
    "vt.default_grn=0,139,227,226,180,194,226,194,91,139,227,226,180,194,226,173"
    "vt.default_blu=0,168,161,175,250,231,213,222,112,168,161,175,250,231,213,200"
    "i915.force_probe=8086:3ea0"
  ];

  zramSwap.enable = true;

  programs.nh = {
    # alternative to nixos-rebuild switch :3_
    enable = true;
    flake = "/etc/nixos";
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d";
    };
  };

  services.xserver.videoDrivers = [ "intel" ];

  # enable auto-cpufreq and thermald
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };
  services.thermald.enable = true;

  # makes proton work faster magically, fedora devs picked this number lol
  boot.kernel.sysctl."vm.max_map_count" = 1048576;

  # some random serurity/performance stuffsh
  boot.kernel.sysctl = {
    ## TCP hardening
    # Prevent bogus ICMP errors from filling up logs.
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    # Reverse path filtering causes the kernel to do source validation of
    # packets received from all interfaces. This can mitigate IP spoofing.
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    # Do not accept IP source route packets (we're not a router)
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    # Don't send ICMP redirects (again, we're not a router)
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    # Refuse ICMP redirects (MITM mitigations)
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    # Protects against SYN flood attacks
    "net.ipv4.tcp_syncookies" = 1;
    # Incomplete protection again TIME-WAIT assassination
    "net.ipv4.tcp_rfc1337" = 1;

    ## TCP optimization
    "net.ipv4.tcp_fastopen" = 3;
    # Bufferbloat mitigations + slight improvement in throughput & latency
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";
    # Increase the TCP receive and transmit buffer sizes
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    # Enable TCP window scaling and timestamps
    "net.ipv4.tcp_window_scaling" = 1;
    "net.ipv4.tcp_timestamps" = 1;

    # Increase the maximum number of open file descriptors
    "fs.file-max" = 65535;
  };
  boot.kernelModules = [ "tcp_bbr" ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  hardware.graphics = { # hardware.opengl in 24.05
    enable = true;
    extraPackages = with pkgs; [
      intel-media-sdk # or intel-media-sdk for QSV
    ];
  };

  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    package = lib.mkDefault pkgs.lix;

    settings = {
      # Prevent impurities in builds
      sandbox = true;

      experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        # "configurable-impure-env"
        "flakes"
        # "no-url-literals"
        "nix-command"
        "parse-toml-timestamps"
        "read-only-local-store"
        "recursive-nix"
      ];

      commit-lockfile-summary = "chore: Update flake.lock";
      accept-flake-config = true;
      auto-optimise-store = true; # causes longer builds

      keep-derivations = false;
      keep-outputs = false;
      auto-allocate-uids = true;

      # Whether to warn/allow dirty Git/Mercurial trees.
      warn-dirty = true;
      allow-dirty = true;

      # Give root user and wheel group special Nix privileges.
      trusted-users = [
        "root"
        "@wheel"
      ];
      allowed-users = [ "@wheel" ];

      trusted-substituters = [
        "https://cache.nixos.org?priority=40"
        "https://nix-community.cachix.org?priority=42"
        "https://cache.garnix.io?priority=60"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };

    registry.nixpkgs.flake = inputs.nixpkgs;
  };

  services = {
    earlyoom.enable = true;
    fstrim.enable = true;
  };

  #services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.catppuccin.assertQt6Sddm = true;
  #services.displayManager.sddm.wayland.enable = true;

  programs.nix-index-database.comma.enable = true;
  programs.command-not-found.enable = false;

  # end willow tweaks

  networking.hostName = "willow-hazel"; # Define your hostname.

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "yes"; # Temporary while doing testing :3
    };
  };

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    #   keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  users.users = {
    hazel = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      initialPassword = "hazel";
    };
    root = {
      initialPassword = "root";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZnyiQx+k1ygX8E1lsUCB6aTdMc+OKzlZ4admlzknc5ulj0YrtUyqhbNhkNd6pP0QDBFMnXO/rzUvHp4TAyZXKFfpcBCa4zhK97ufymAfvzAjM4vRBqRNcr2n+2iRzxtolbklfjs3ocBQVxXW+pRT5wWxTgK2fcmP2xviDVldr7qte37x5YkQb5SAhYNH8tqJRnuGPe+Q0A3oN4HyHZFnrMq/HlbL5yg/0VKPTtF/IgHf+2dDz5OQQpBx3/N9u/QLwuIm9lkyOG03s0TGmE7up/i0jX2vIqp2BbGSnwdQEL/eSVZx73qQB/J62VFafg13P5yQWDJ33WSoiwhac6bg26HPmPOnCJp5R3c+7jM8N1F1ZbtsKicHSVsRg1RQSree4lchPy7FOPkCuUrB7LNE71mbpOzZNR767S6UAPaXxRw6QNYGBaDqQBwhlU8ZDF5F7EW6ahSUMOI6ECyoibzIMb56xs9osuNeUhB/BcL5sHSFpJjIbdcDLNkEKggrBl6s=" # hazel :3
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKwk5pgUdvfWzft+erxsYkfk/KRFlbvgZmt/ML5S2ZDE" # willow :3
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
    waybar
    _1password-gui
    bemenu
    firefox
    kitty
    fastfetch
    alacritty
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    prismlauncher
    cider
    steam
    vscode
    kdePackages.kleopatra
    termius
  ];

 # environment.sessionVariables = {
#    XDG_CONFIG_HOME = "$HOME/etc";
  #  XDG_DATA_HOME   = "$HOME/var/lib";
 #   XDG_CACHE_HOME  = "$HOME/var/cache";
#  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
