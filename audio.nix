{ config, pkgs, ... }:

let pulse = pkgs.pulseaudioFull;
in
{
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true; # This might be needed for Steam games
    package = pulse;
  };

  boot.kernelModules = [ "snd-seq" "snd-rawmidi" "snd-virmidi" ];
      
  environment.systemPackages = with pkgs; [
    jack2Full qjackctl swh_lv2 rkrlv2 metersLv2 mda_lv2 lv2 ams-lv2 ardour pavucontrol
    hydrogen audacity ffmpeg calf
  ];

  security.pam.loginLimits = [
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
    { domain = "@audio"; item = "nofile"; type = "soft"; value = "99999"; }
    { domain = "@audio"; item = "nofile"; type = "hard"; value = "99999"; }
  ];

  systemd.user.services = {
    jackdbus = {
      description = "Runs jack, and points pulseaudio at it";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeScript "start_jack.sh" ''
          #! ${pkgs.bash}/bin/bash
          . ${config.system.build.setEnvironment}

          ${pkgs.jack2Full}/bin/jack_control start
          sleep 3 # give some time for sources/sinks to be created

          ${pulse}/bin/pacmd set-default-sink jack_out
          ${pulse}/bin/pacmd set-default-source jack_in
        '';
        ExecStop = pkgs.writeScript "stop_jack.sh" ''
          #! ${pkgs.bash}/bin/bash
          . ${config.system.build.setEnvironment}

          ${pkgs.jack2Full}/bin/jack_control stop
        '';
        RemainAfterExit = true;
      };
      wantedBy = [ "default.target" ];
      requires = [ "pulseaudio.service" ];
      after = [ "pulseaudio.service" ];
    };

    supercollider = {
      description = "Supercollider Server";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.supercollider}/bin/scsynth -u 57110";
      };
      requires = [ "jackdbus.service" ];
      after = [ "jackdbus.service" ];
    };
  };

  environment.shellInit = ''
    export VST_PATH=$NIX_USER_PROFILE_DIR/profile/lib/vst:/var/run/current-system/sw/lib/vst:~/.vst
    export LXVST_PATH=$NIX_USER_PROFILE_DIR/profile/lib/lxvst:/var/run/current-system/sw/lib/lxvst:~/.lxvst
    export LADSPA_PATH=$NIX_USER_PROFILE_DIR/profile/lib/ladspa:/var/run/current-system/sw/lib/ladspa:~/.ladspa
    export LV2_PATH=$NIX_USER_PROFILE_DIR/profile/lib/lv2:/var/run/current-system/sw/lib/lv2:~/.lv2
    export DSSI_PATH=$NIX_USER_PROFILE_DIR/profile/lib/dssi:/var/run/current-system/sw/lib/dssi:~/.dssi
  '';
}
