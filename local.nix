{ config, lib, pkgs, ... }:

{
  services = {
    tor = {
      enable = true;
      client.enable = true;
      settings = {
        UseBridges = true;
        ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";
        Bridge = "obfs4 212.236.8.35:993 7933E224A4343AF464164D3F39017F94DFB8B921 cert=U6dV3vCY6MDpqMrLwMNn978uLqljUC3eLqJQcrv/FHMNAPrHoIHVGAzfIlSdKuvrDZXUag iat-mode=0";
      };
    };
  };
}
