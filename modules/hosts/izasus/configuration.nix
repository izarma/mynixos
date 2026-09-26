{ self, inputs, ... }:
{

  flake.nixosModules.izasusConfiguration =
    { config, pkgs, ... }:
    {
      imports = [
        # Include the results of the hardware scan.
        self.nixosModules.izasusHardware
        self.nixosModules.niri
        self.nixosModules.rust
      ];

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nixpkgs.hostPlatform = "x86_64-linux";

      # 1. Enable automatic garbage collection
      nix.gc = {
        automatic = true;
        dates = "daily"; # Run the cleaner every day
        options = "--delete-older-than 10d"; # Delete generations older than 10 days
      };

      # 2. Automatically optimize the Nix store (hardlink identical files)
      # This runs alongside the garbage collector and saves a ton of disk space.
      nix.settings.auto-optimise-store = true;
      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      programs.nix-ld.enable = true;
      # Use latest kernel.
      boot.kernelPackages = pkgs.linuxPackages_latest;
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            # Shows battery charge of connected devices on supported
            # Bluetooth adapters. Defaults to 'false'.
            Experimental = true;
            # When enabled other devices can connect faster to us, however
            # the tradeoff is increased power consumption. Defaults to
            # 'false'.
            FastConnectable = true;
          };
          Policy = {
            # Enable all controllers when they are found. This includes
            # adapters present on start as well as adapters that are plugged
            # in later on. Defaults to 'true'.
            AutoEnable = true;
          };
        };
      };

      networking.hostName = "nixos"; # Define your hostname.
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Enable networking
      networking.networkmanager.enable = true;

      # Set your time zone.
      time.timeZone = "Asia/Kolkata";

      # Select internationalisation properties.
      i18n.defaultLocale = "en_IN";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_IN";
        LC_IDENTIFICATION = "en_IN";
        LC_MEASUREMENT = "en_IN";
        LC_MONETARY = "en_IN";
        LC_NAME = "en_IN";
        LC_NUMERIC = "en_IN";
        LC_PAPER = "en_IN";
        LC_TELEPHONE = "en_IN";
        LC_TIME = "en_IN";
      };

      # Enable the X11 windowing system.
      # You can disable this if you're only using the Wayland session.
      services.xserver.enable = true;

      # Enable the KDE Plasma Desktop Environment.
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      # Enable CUPS to print documents.
      services.printing.enable = true;

      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
      };

      # Enable touchpad support (enabled default in most desktopManager).
      # services.xserver.libinput.enable = true;

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.izarma = {
        isNormalUser = true;
        description = "izarma";
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
        ];
        # packages = with pkgs; [
        #   kdePackages.kate
        # #  thunderbird
        # ];
      };

      # Install firefox.
      programs.firefox.enable = true;

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      hardware.graphics.enable = true;
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia.open = true;

      # PRIME configuration for AMD iGPU + NVIDIA dGPU
      hardware.nvidia.prime = {
        amdgpuBusId = "PCI:6@0:0:0"; # Your AMD Cezanne iGPU
        nvidiaBusId = "PCI:1@0:0:0"; # Your RTX 3060 Mobile dGPU
      };

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        vim
        wget
        nil
        nixd
        zed-editor
        git
        mold
        clang
        tailscale
        ghostty
        aseprite
        discord
        odin
        asusctl
        just

        pkg-config
        wayland
        wayland-scanner
        wayland-protocols
        libxkbcommon
        libxkbcommon.dev
        alsa-lib
        alsa-lib.dev
        vulkan-loader
        vulkan-headers
        udev
        xorg.libX11
        xorg.libXcursor
        xorg.libXi
        xorg.libXrandr
        iptables
        qemu

        gnuplot
        tree
      ];

      services.tailscale.enable = true;
      networking.nftables.enable = true;
      networking.firewall = {
        enable = true;
        # Always allow traffic from your Tailscale network
        trustedInterfaces = [ config.services.tailscale.interfaceName ];
        # Allow the Tailscale UDP port through the firewall
        allowedUDPPorts = [ config.services.tailscale.port ];
      };

      # 2. Force tailscaled to use nftables (Critical for clean nftables-only systems)
      # This avoids the "iptables-compat" translation layer issues.
      systemd.services.tailscaled.serviceConfig.Environment = [
        "TS_DEBUG_FIREWALL_MODE=nftables"
      ];

      # 3. Optimization: Prevent systemd from waiting for network online
      # (Optional but recommended for faster boot with VPNs)
      systemd.network.wait-online.enable = false;
      boot.initrd.systemd.network.wait-online.enable = false;

      environment.sessionVariables = {
        LD_LIBRARY_PATH =
          with pkgs;
          lib.makeLibraryPath [
            wayland
            libxkbcommon
            alsa-lib
            vulkan-loader
            udev
          ];

        PKG_CONFIG_PATH =
          with pkgs;
          lib.makeSearchPath "lib/pkgconfig" [
            wayland.dev
            wayland-protocols
            libxkbcommon.dev
            alsa-lib.dev
            vulkan-headers
            udev.dev
          ];
      };
      programs.steam = {
        enable = true;

        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };

      services.asusd = {
        enable = true;
      };
      virtualisation.docker.enable = true;

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

      # List services that you want to enable:

      # Enable the OpenSSH daemon.
      # services.openssh.enable = true;

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "25.11"; # Did you read the comment?

    };
}
