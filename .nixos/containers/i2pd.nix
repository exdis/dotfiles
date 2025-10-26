{ ... }: {
  containers.i2pd = {
    autoStart = false;
    config = { ... }: {

      system.stateVersion = "25.05";

      networking.firewall.allowedTCPPorts = [
        7656 # default sam port
        7070 # default web interface port
        4447 # default socks proxy port
        4444 # default http proxy port
      ];

      services.i2pd = {
        enable = true;
        address = "0.0.0.0";
        proto = {
          http.enable = true;
          socksProxy.enable = true;
          httpProxy.enable = true;
          sam.enable = true;
        };
      };
    };
  };
}
