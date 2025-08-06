{ pkgs, hyprland-plugins, split-monitor-workspaces, ... }:

let
  gamescoped-steam-script = pkgs.writeScriptBin "gamescoped-steam" (builtins.readFile ./gs.sh);
in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "outergod";
    homeDirectory = "/home/outergod";
    stateVersion = "25.05"; # Please read the comment before changing.
    packages = [];
    file = {};
    sessionVariables = {
      GTK_THEME = "Adwaita:dark";
    };

    pointerCursor = {
      gtk.enable = true;
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
      size = 18;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    plugins = [
      split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    ];

    settings = {
      "debug:disable_logs" = false;
      "debug:full_cm_proto" = true;
      monitor = [
        "desc:LG Display 0x058B, preferred, auto, 1.6"
        "desc:BNQ BenQ PD3200U V5H01247019, preferred, auto, 2"
        "desc:BNQ BenQ PD3200U M9H01833019, preferred, auto, 2"
      ];

      "$terminal" = "alacritty";
      "$menu" = "rofi -show-icons -theme nord-oneline -show combi -modes combi -combi-modes window,drun,run";
      "$powerMenu" = "rofi -theme nord-oneline -show power-menu -modi power-menu:rofi-power-menu";
      "$emacs" = "emacsclient --create-frame";

      exec-once = [
        "systemctl --user import-environment NIX_PATH"
        "systemctl --user start emacs.service"
        "systemctl --user start hypridle.service"
        "systemctl --user start hyprpaper.service"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "dunst"
        "udiskie --tray"
        "waybar"
        "synology-drive"
      ];

      env = [
        "GTK_THEME, Adwaita:dark"
      ];

      general = {
        gaps_in = 0;
        gaps_out = 0;

        border_size = 2;

        "col.active_border" = "rgba(ebcb8bff)";
        resize_on_border = false;
        allow_tearing = true;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;

        active_opacity = 1.0;
        inactive_opacity = 1.0;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = true;
          size = 3;
          passes = 1;

          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = true;

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = false;
      };

      input = {
        kb_layout = "us,us";
        kb_variant = ",dvorak";
        kb_model = "";
        kb_options = "compose:menu";
        kb_rules = "";

        follow_mouse = 1;

        sensitivity = 0;

        natural_scroll = true;

        touchpad = {
          natural_scroll = true;
        };
      };

      gestures = {
        workspace_swipe = false;
      };

      xwayland = {
        create_abstract_socket = true;
      };

      "$mainMod" = "SUPER";

      bind = [
        "$mainMod, Q, exec, $powerMenu"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $emacs"
        "$mainMod, V, togglefloating,"
        "$mainMod, space, exec, $menu"
        "$mainMod, P, pseudo, # dwindle"
        "$mainMod, J, togglesplit, # dwindle"
        "$mainMod, F, fullscreen, 1"
        "$mainMod SHIFT, F, fullscreen, 0"

        "$mainMod, left, split-workspace, -1"
        "$mainMod, right, split-workspace, +1"
        "$mainMod, up, split-workspace, u"
        "$mainMod, down, split-workspace, d"

        "$mainMod, 1, split-workspace, 1"
        "$mainMod, 2, split-workspace, 2"
        "$mainMod, 3, split-workspace, 3"
        "$mainMod, 4, split-workspace, 4"
        "$mainMod, 5, split-workspace, 5"
        "$mainMod, 6, split-workspace, 6"
        "$mainMod, 7, split-workspace, 7"
        "$mainMod, 8, split-workspace, 8"
        "$mainMod, 9, split-workspace, 9"
        "$mainMod, 0, split-workspace, 10"

        "$mainMod SHIFT, 1, split-movetoworkspace, 1"
        "$mainMod SHIFT, 2, split-movetoworkspace, 2"
        "$mainMod SHIFT, 3, split-movetoworkspace, 3"
        "$mainMod SHIFT, 4, split-movetoworkspace, 4"
        "$mainMod SHIFT, 5, split-movetoworkspace, 5"
        "$mainMod SHIFT, 6, split-movetoworkspace, 6"
        "$mainMod SHIFT, 7, split-movetoworkspace, 7"
        "$mainMod SHIFT, 8, split-movetoworkspace, 8"
        "$mainMod SHIFT, 9, split-movetoworkspace, 9"
        "$mainMod SHIFT, 0, split-movetoworkspace, 10"

        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        "$mainMod, grave, exec, ${pkgs.pyprland}/bin/pypr expose"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "immediate, class:Strangest Aeon"
      ];
    };
  };

  programs = {
    home-manager.enable = true;

    waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          margin = "0 0";
          modules-left = ["image#nixos" "hyprland/window"];
          modules-right = ["tray" "pulseaudio" "battery" "network" "hyprland/language" "clock"];
          network = {
            format = "{icon}";
            format-icons = {
              wifi = ["󰤟" "󰤥" "󰤨"];
              ethernet = [""];
              disconnected = ["󰌙"];
            };
            tooltip = false;
          };
          battery = {
            format = "{icon}";
            format-icons = ["" "" "" "" ""];
          };
          "image#nixos" = {
            path = ./waybar/nix-snowflake-colours.svg;
            size = 18;
          };
          "hyprland/window" = {
            icon = true;
            "icon-size"= 18;
          };
          tray = {
            spacing = 5;
          };
          "hyprland/language" = {
            on-click = "hyprctl switchxkblayout splitkb.com-kyria-rev3 next";
          };
          clock = {
            format = "{:%F %H:%M}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            today-format = "<b>{}</b>";
            on-click = "gnome-calendar";
          };
          pulseaudio = {
            scroll-step = 3;
            format = "{icon}  {format_source}";
            format-bluetooth = "{icon}  {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" "" ""];
            };
            on-click = "pavucontrol";
            on-click-right = "wpctl set-mute @DEFAULT_SOURCE@ toggle";
          };
        };
      };

      style = ./waybar/style.css;
    };

    hyprlock = {
      enable = true;

      settings = {
        background = {
          path = toString ./simon-heath-swamp7.jpg;
        };

        input-field = [
          {
            size = "300, 30";
            halign = "center";
            valign = "bottom";
            position = "0, 20";
            dots_center = true;
            font_color = "rgb(d8dee9)";
            inner_color = "rgba(0, 0, 0, 0)";
            outer_color = "rgba(0, 0, 0, 0)";
            check_color = "rgba(0, 0, 0, 0)";
            fail_color = "rgba(0, 0, 0, 0)";
            placeholder_text = "";
          }
        ];
      };
    };
  };

  services = {
    hypridle = {
      enable = true;

      settings = {
        general = {
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    hyprpaper = {
      enable = true;

      settings = {
        ipc = "on";
        splash = false;
        splash_offset = 2.0;

        preload = [
          ("" + ./cryo-chamber-doom.jpg)
        ];

        wallpaper = [
          ("," + ./cryo-chamber-doom.jpg)
        ];
      };
    };

    dunst = {
      enable = true;
      settings = {
        global = {
          monitor = 0;
          follow = "mouse";
          width = 300;
          height = "(0,300)";
          origin = "top-right";
          offset = "30x30";
          notification_limit = 5;
          progress_bar = true;
          progress_bar_height = 1;
          progress_bar_frame_width = 0;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;
          indicate_hidden = "yes";
          transparency = 30;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          text_icon_padding = 0;
          frame_width = 1;
          frame_color = "#ffffff";
          gap_size = 0;
          separator_color = "frame";
          sort = "yes";
          idle_threshold = 120;
          font = "Noto Sans 10";
          line_height = 1;
          markup = "full";
          format = "<b>%s</b>\n%b";
          alignment = "left";
          vertical_alignment = "center";
          show_age_threshold = 60;
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "yes";
          icon_position = "left";
          min_icon_size = 0;
          max_icon_size = 64;
          sticky_history = "yes";
          history_length = 20;
          browser = "xdg-open";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          corner_radius = 10;
          ignore_dbusclose = false;
          force_xwayland = false;
          force_xinerama = false;
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";
        };

        urgency_low = {
          background = "#000000CC";
          foreground = "#888888";
          highlight = "#888888";
          timeout = 10;
        };

        urgency_normal = {
          background = "#000000CC";
          foreground = "#ffffff";
          highlight = "#ffffff";
          timeout = 10;
        };

        urgency_critical = {
          background = "#900000CC";
          foreground = "#ffffff";
          highlight = "#ffffff";
          frame_color = "#ffffff";
          timeout = 0;
        };
      };
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  gtk = {
    enable = true;

    theme = {
      name = "Adwaita";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };

    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
    gtk4 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };

  xdg = {
    enable = true;

    desktopEntries = {
      gamescoped-steam = {
        name = "Gamescoped Steam";
        exec = "${gamescoped-steam-script}/bin/gamescoped-steam";
        terminal = false;
        type = "Application";
        categories = ["Game"];
        icon = "steam";
      };
    };
    dataFile."rofi/themes/nord-oneline.rasi".source = ./nord-oneline.rasi;
  };
}
