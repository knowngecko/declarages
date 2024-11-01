local Configuration = {
    Pacman = {
       Official = {
        	--> Required applications
        "base",
        "base-devel",
        "git",
        "grub",
        "linux-zen", "linux-zen-headers",
        "linux-firmware",
        "flatpak", -- Required for script
        "zsh", -- The shell is ZSH for root
        "zsh-syntax-highlighting",
        "zsh-autosuggestions",
        "zsh-history-substring-search",
        "networkmanager",
        "openssh",
        "amd-ucode",
        "gst-plugin-pipewire",
        "efibootmgr",
        "libpulse",
        "pipewire",
        "pipewire-alsa",
        "pipewire-jack",
        "pipewire-pulse",
        "wireplumber",
        "linux-headers",
        "dkms",
        "dnsmasq",
        "libvirt",
        "qemu-full",
        "ntfs-3g",
        "noto-fonts", "noto-fonts-emoji",
        "ttf-jetbrains-mono-nerd",
        "nvidia-open-dkms", "nvidia-settings",
        "cuda",
        "libnotify",
        "cryptsetup",
    
        --> Apps
        "rustup",
        "fastfetch",
        "dunst",
        "signal-desktop",
        "rofi-wayland",
        "btop",
        "virt-manager",
        "qbittorrent",
        "neovim",
        "nvtop",
        "clang",
        "macchanger",
        "docker", "docker-compose", "nvidia-container-toolkit",
        "ranger",
        "jdk21-openjdk",
        "xorg-server",
        "xorg-xinit",
        "obs-studio",
        "flameshot",
        "meson",
        "xorg-xrandr",
        "alacritty",
        "feh",
        "python-pywal",
        "xclip",
        "npm",
        "telegram-desktop",
        "audacity",
        "movit",
        "kdenlive",
        "monero",
        "lutris",
        "system-config-printer",
        "bind",
        "cmake", "libdisplay-info", "seatd",
        "less",
        "weston",
        "nfs-utils",
        "firefox", "geckodriver",
        "neovim",
        "pacman-contrib",
        "jshon",
        "lua-lanes",
        "lua-luv",

       },
       
       CustomLocation = "/home/pika/.aur/",
       Custom = {
        --> Simple AUR
        "nvm", "vscodium",
        "zapzap",
        "jellyfin-media-player",
        "nvim-lazy",
        "picom-git",
        "brave-bin",
        "epson-inkjet-printer-escpr",
        "dmg2img",
        "libsrm-devel-git", "louvre-devel-git",
        "drm_info-git",
        "zen-browser-avx2-bin",
        "python-selenium",
    
        --> Advanced AUR
        { Base = "Rust-VPN-Handler", Sub = {"vpn_handler"}, Url = "https://github.com/kingdomkind/Rust-VPN-Handler.git"},
        { Base = "symlink-manager", Sub = {"symlink-manager-git"}, Url = "https://github.com/knowngecko/symlink-manager.git"},
       },
    },

    Settings = {
        WarnOnPackageRemovalAbove = 5;
        SuperuserCommand = "sudo";
        AddPathConfirmation = true;
        RemovePathConfirmation = true;
        Cores = { "pacman" }
    }
}

return Configuration;