{
  pkgs,
  inputs,
  lib,
  cell,
  ...
}:
{
  programs.waybar = {
    enable = true;
    style = ./__style.css;
    settings =
      let
        shared = {
          layer = "top";
          height = 24;
          exclusive = true;
          passthrough = false;
          fixed-center = true;
          reload_style_on_change = true;

          # Modules configuration
          "niri/workspaces" = {
            active-only = false;
            # on-scroll-up = "hyprctl dispatch workspace e+1";
            # on-scroll-down = "hyprctl dispatch workspace e-1";
            disable-scroll = true;
            all-outputs = false;
            # format = "{}";
            # on-click = "activate";
          };

          "niri/window" = {
            max-length = 42;
            format = "{title}";
            rewrite = {
              "" = "empty";
              "org.wezfurlong.wezterm" = "wezterm";
              "com.github.flxzt.rnote" = "rnote";
              "Spotify" = "spotify";
              "org.prismlauncher.PrismLauncher" = "prismlauncher";
              "OpenTabletDriver.UX.Gtk" = "opentabletdriver";
              "teams-for-linux" = "teams";
            };
            separate-outputs = true;
            tooltip = false;
          };

          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              activated = " ";
              deactivated = " ";
            };
          };

          "cava" = {
            framerate = 30;
            hide_on_silence = true;
            sensitivity = 1;
            bars = 16;
            lower_cutoff_freq = 50;
            higher_cutoff_freq = 10000;
            method = "pulse";
            source = "auto";
            stereo = true;
            reverse = false;
            bar_delimiter = 0;
            monstercat = false;
            waves = false;
            noise_reduction = 0.77;
            input_delay = 1;
            format-icons = [
              " "
              "▁"
              "▂"
              "▃"
              "▄"
              "▅"
              "▆"
              "▇"
              "█"
            ];
            actions = {
              on-click-right = "mode";
            };
          };

          "tray" = {
            spacing = 8;
          };

          "clock" = {
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format = " {:%H:%M}";
            format-alt = " {:%A, %B %d, %Y}";
          };

          "cpu" = {
            format = " {usage}%";
            tooltip = false;
          };

          "memory" = {
            format = " {}%";
          };

          "backlight" = {
            format = "{icon}{percent}%";
            format-icons = [
              "󰃞 "
              "󰃟 "
              "󰃠 "
            ];
            on-scroll-up = "${lib.getExe pkgs.brightnessctl} set +5%";
            on-scroll-down = "${lib.getExe pkgs.brightnessctl} set 5%-";
            tooltip = false;
          };

          "battery" = {
            states = {
              warning = "30";
              critical = "15";
              full = "100";
            };
            format = "{icon}{capacity}%";
            tooltip-format = "{timeTo} {capacity}%";
            format-charging = "󱐋{capacity}%";
            format-full = "";
            format-plugged = " ";
            format-alt = "{time} {icon}";
            format-icons = [
              "  "
              "  "
              "  "
              "  "
              "  "
            ];
          };

          "network" = {
            format-wifi = " {signalStrength}%";
            format-ethernet = "{ifname}: {ipaddr}/{cidr} 󰈀 ";
            format-linked = "{ifname} (No IP) 󰈀 ";
            format-disconnected = "󰤮 Disconnected";
            on-click = "";
            on-click-release = "sleep 0";
            tooltip-format = "{essid} {signalStrength}%";
          };

          "pulseaudio" = {
            format = "{icon}{volume}% {format_source}";
            format-bluetooth = "{icon} {volume}%";
            format-bluetooth-muted = "   {volume}%";
            format-source = "";
            format-source-muted = "";
            format-muted = "  {format_source}";
            format-icons = {
              headphone = " ";
              hands-free = " ";
              headset = " ";
              phone = " ";
              portable = " ";
              car = " ";
              default = [
                " "
                " "
                " "
              ];
            };
            tooltip-format = "{desc} {volume}%";
            on-click = "${lib.getBin pkgs.pulseaudio}/pactl set-sink-mute @DEFAULT_SINK@ toggle";
            on-click-right = "${lib.getBin pkgs.pulseaudio}/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
            on-click-middle = "${lib.getExe pkgs.pavucontrol}";
            on-click-release = "sleep 0";
            on-click-middle-release = "sleep 0";
          };

          "mpris" = {
            interval = 1;
            format = "<span foreground='#B4BEFE'>{player_icon}</span> {title} ";
            format-paused = " {status_icon} {title}";
            max-length = 46;
            player-icons = {
              default = "󰏤";
              mpv = "";
            };
            status-icons = {
              paused = "";
            };
            on-scroll-up = "${pkgs.playerctl}/bin/playerctl next";
            on-scroll-down = "${pkgs.playerctl}/bin/playerctl previous";
            dynamic-order = [
              "player"
              "title"
              "artist"
              "album"
              "position"
              "length"
            ];
            dynamic-importance-order = [
              "position"
              "length"
              "title"
              "artist"
              "album"
            ];
            dynamic-separator = " > ";
          };
        };
      in
      {
        eDP-1 = shared // {
          output = "eDP-1";
          modules-left = [
            "custom/mode"
            "niri/workspaces"
            "mpris"
          ];
          modules-center = [ "niri/window" ];
          modules-right = [
            "cpu"
            "memory"
            "backlight"
            "pulseaudio"
            "network"
            "tray"
            "clock"
          ];

        };
        HDMI-A-2 = shared // {
          output = "HDMI-A-2";
          modules-left = [
            "custom/mode"
            "niri/workspaces"
          ];
          modules-center = [ "niri/window" ];
          modules-right = [
            "pulseaudio"
            "clock"
          ];
        };
      };
  };
}

# Redacted Section

#    systemd.enable = true;
 # programs.waybar = {
 #   enable = true;
 #   systemd = {
 #     enable = true;
#      target = lib.mkDefault "graphical-session.target";
#    };
 #   package = inputs.waybar.packages.${pkgs.system}.waybar.overrideAttrs (oa: {
  #    mesonFlags = (oa.mesonFlags or [ ]) ++ [ "-Dexperimental=true" ];
   # });

# This section above is redacted, due to niri itself starting waybar. And if using the systemd.enable = true; it will cause a conflict with niri where on the second launch of niri-session two bars will appear.