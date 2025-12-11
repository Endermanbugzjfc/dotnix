# NixOS Configuration for Local SSL-Terminating Favicon Proxy with nftables
# Certificates are generated as derivations during nixos-rebuild
# User-specific traffic redirection via nftables (no /etc/hosts needed)

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.favicon-proxy;
  
  # List of domains to proxy
  domains = [
    "youtube.com"
    "www.youtube.com"
    "github.com"
    "www.github.com"
    "moodle.telt.unsw.edu.au"
    "www.moodle.telt.unsw.edu.au"
  ];
  
  # Runtime directory for resolved IPs
  runtimeDir = "/run/FaviconReplacement";
  
  # Script to resolve domain IPs and update iptables
  resolveDomainsScript = pkgs.writeShellScript "resolve-domains" ''
    set -euo pipefail
    
    mkdir -p ${runtimeDir}
    
    # Create IP list file
    IP_FILE="${runtimeDir}/upstream-ips.txt"
    TEMP_FILE="$IP_FILE.tmp"
    
    echo "# Auto-generated upstream IPs - $(date)" > "$TEMP_FILE"
    
    ${concatMapStringsSep "\n    " (domain: ''
      echo "Resolving ${domain}..." >&2
      IP=$(${pkgs.host}/bin/host -t A ${domain} 8.8.8.8 | ${pkgs.gnugrep}/bin/grep "has address" | ${pkgs.gnugrep}/bin/grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "")
      if [ -n "$IP" ]; then
        echo "$IP" >> "$TEMP_FILE"
        echo "${domain} -> $IP" >&2
      else
        echo "Failed to resolve ${domain}" >&2
      fi
    '') domains}
    
    # Atomic move
    mv "$TEMP_FILE" "$IP_FILE"
    
    echo "IP resolution complete. IP file updated at $IP_FILE" >&2
    
    # Trigger iptables reload
    ${pkgs.systemd}/bin/systemctl restart firewall.service || true
  '';

  # Generate CA certificate as a derivation
  proxyCA = pkgs.stdenvNoCC.mkDerivation {
    name = "proxy-ca";
    nativeBuildInputs = [ pkgs.openssl ];
    
    unpackPhase = "true";
    
    buildPhase = ''
      # Generate CA private key
      openssl genrsa -out ca.key 4096
      
      # Generate CA certificate (valid for 10 years)
      openssl req -x509 -new -nodes -key ca.key \
        -sha256 -days 3650 -out ca.crt \
        -subj "/C=AU/ST=NSW/L=Sydney/O=Local Favicon Proxy/CN=Local Favicon Proxy CA"
    '';
    
    installPhase = ''
      mkdir -p $out
      cp ca.key ca.crt $out/
      chmod 600 $out/ca.key
      chmod 644 $out/ca.crt
    '';
  };

  # Generate domain certificate derivation
  mkDomainCert = domain: pkgs.stdenvNoCC.mkDerivation {
    name = "proxy-cert-${domain}";
    nativeBuildInputs = [ pkgs.openssl ];
    
    # Pass CA as a build input so it's accessible
    ca_crt = "${proxyCA}/ca.crt";
    ca_key = "${proxyCA}/ca.key";
    
    unpackPhase = "true";
    
    buildPhase = ''
      # Copy CA files to build directory
      cp $ca_crt ./ca.crt
      cp $ca_key ./ca.key
      
      # Generate private key
      openssl genrsa -out ${domain}.key 2048
      
      # Create certificate signing request
      openssl req -new -key ${domain}.key \
        -out ${domain}.csr \
        -subj "/C=AU/ST=NSW/L=Sydney/O=Local Favicon Proxy/CN=${domain}"
      
      # Create SAN extension file
      cat > ${domain}.ext << EOF
      authorityKeyIdentifier=keyid,issuer
      basicConstraints=CA:FALSE
      keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
      subjectAltName = @alt_names
      
      [alt_names]
      DNS.1 = ${domain}
      EOF
      
      # Sign certificate with CA
      openssl x509 -req -in ${domain}.csr \
        -CA ./ca.crt \
        -CAkey ./ca.key \
        -CAcreateserial \
        -out ${domain}.crt \
        -days 3650 -sha256 \
        -extfile ${domain}.ext
    '';
    
    installPhase = ''
      mkdir -p $out
      cp ${domain}.key ${domain}.crt $out/
      chmod 600 $out/${domain}.key
      chmod 644 $out/${domain}.crt
    '';
  };

  # Generate all domain certificates (including localhost for debug)
  domainCerts = builtins.listToAttrs (map (domain: {
    name = domain;
    value = mkDomainCert domain;
  }) (domains ++ [ "localhost" "127.0.0.1" ]));

  # Map domains to replacement favicons
  faviconReplacements = {
    "youtube.com" = "https://www.google.com/favicon.ico";
    "www.youtube.com" = "https://www.google.com/favicon.ico";
    "github.com" = "https://gitlab.com/favicon.ico";
    "www.github.com" = "https://gitlab.com/favicon.ico";
    "moodle.telt.unsw.edu.au" = "https://www.unsw.edu.au/favicon.ico";
    "www.moodle.telt.unsw.edu.au" = "https://www.unsw.edu.au/favicon.ico";
  };

in {
  options.services.favicon-proxy = {
    enable = mkEnableOption "favicon replacement proxy with per-user nftables redirection";
    
    users = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "alice" ];
      description = "List of usernames whose traffic should be redirected through the proxy";
    };
    
    ipResolutionInterval = mkOption {
      type = types.str;
      default = "6h";
      example = "1h";
      description = "How often to resolve upstream IPs (systemd time format)";
    };
  };

  config = mkIf cfg.enable {
    # Enable systemd-networkd-wait-online to ensure network is truly ready
    systemd.services.systemd-networkd-wait-online.enable = mkDefault true;
    
    # Systemd service to resolve domain IPs periodically
    systemd.services.favicon-proxy-resolve = {
      description = "Resolve upstream IPs for favicon proxy";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" "nss-lookup.target" ];
      wants = [ "network-online.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${resolveDomainsScript}";
        RuntimeDirectory = "FaviconReplacement";
        RuntimeDirectoryPreserve = "yes";
        RemainAfterExit = true;
        # Retry if network isn't ready
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
    
    # Timer to run resolution periodically
    systemd.timers.favicon-proxy-resolve = {
      description = "Timer for favicon proxy IP resolution";
      wantedBy = [ "timers.target" ];
      
      timerConfig = {
        OnBootSec = "0";
        OnUnitActiveSec = cfg.ipResolutionInterval;
        Unit = "favicon-proxy-resolve.service";
      };
    };

    # Trust the CA certificate system-wide
    security.pki.certificateFiles = [ "${proxyCA}/ca.crt" ];

    # Configure iptables to redirect user traffic
    networking.firewall = {
      enable = true;
      
      extraCommands = ''
        # Favicon proxy redirection rules
        echo "Setting up favicon proxy iptables rules..." >&2
        
        if [ ! -f ${runtimeDir}/upstream-ips.txt ]; then
          echo "Warning: IP file not found at ${runtimeDir}/upstream-ips.txt" >&2
          echo "Skipping favicon proxy rules - will be added when IPs are resolved" >&2
          exit 0  # Don't fail, just skip proxy rules
        fi
        
        # Count non-comment lines
        IP_COUNT=$(grep -v '^#' ${runtimeDir}/upstream-ips.txt | grep -v '^$' | wc -l)
        if [ "$IP_COUNT" -eq 0 ]; then
          echo "Warning: IP file exists but contains no IPs" >&2
          echo "Skipping favicon proxy rules" >&2
          exit 0
        fi
        
        echo "Found $IP_COUNT resolved IPs, applying rules..." >&2
        
        # Read resolved IPs and create redirect rules for specified users
        RULE_COUNT=0
        while IFS= read -r ip || [ -n "$ip" ]; do
          # Skip comments and empty lines
          [[ "$ip" =~ ^#.*$ ]] && continue
          [[ -z "$ip" ]] && continue
          
          echo "  Adding rules for IP: $ip" >&2
          
          ${concatMapStringsSep "\n          " (username: 
            ''
              # Redirect user ${username}
              iptables -t nat -A OUTPUT -m owner --uid-owner ${username} -p tcp -d "$ip" --dport 443 -j REDIRECT --to-ports 443
              echo "    -> Redirecting UID ${username} to $ip:443" >&2
              RULE_COUNT=$((RULE_COUNT + 1))
            ''
          ) cfg.users}
        done < ${runtimeDir}/upstream-ips.txt
        
        echo "Favicon proxy: Applied $RULE_COUNT iptables rules successfully" >&2
      '';
      
      extraStopCommands = ''
        # Clean up favicon proxy rules
        iptables -t nat -F OUTPUT 2>/dev/null || true
      '';
    };

    # Configure nginx with SSL termination
    services.nginx = {
      enable = true;
      logError = "stderr debug";
      
      # Increase worker connections to handle proxy traffic
      eventsConfig = ''
        worker_connections 4096;
      '';
      
      commonHttpConfig = ''
        resolver 8.8.8.8 8.8.4.4 1.1.1.1 valid=300s;
        resolver_timeout 5s;
        
        # Map for favicon replacements
        map $host $favicon_replacement {
          default "";
          ${concatStringsSep "\n      " 
            (mapAttrsToList (domain: url: ''"${domain}" "${url}";'') 
            faviconReplacements)}
        }
      '';
      
      # Create virtual host for each domain
      virtualHosts = builtins.listToAttrs (map (domain: 
        let
          domainCert = domainCerts.${domain};
        in {
        name = domain;
        value = {
          listen = [
            { addr = "127.0.0.1"; port = 443; ssl = true; }
          ];
          
          extraConfig = ''
            ssl_certificate ${domainCert}/${domain}.crt;
            ssl_certificate_key ${domainCert}/${domain}.key;
            
            access_log /var/log/nginx/${domain}-access.log;
            error_log /var/log/nginx/${domain}-error.log debug;
          '';
          
          locations = {
            # Debug endpoint
            "= /debug" = {
              extraConfig = ''
                add_header Content-Type text/html;
                return 200 '
                  <html>
                  <body>
                    <h1>Debug Info</h1>
                    <p>Host: $host</p>
                    <p>Request URI: $request_uri</p>
                    <p>Favicon Replacement: $favicon_replacement</p>
                    <p>SSL: $ssl_protocol $ssl_cipher</p>
                    <p>CA Path: ${proxyCA}/ca.crt</p>
                    <p>Proxy Port: 443</p>
                  </body>
                  </html>
                ';
              '';
            };
            
            # Favicon replacement
            "= /favicon.ico" = {
              extraConfig = ''
                # If we have a replacement, redirect to it
                if ($favicon_replacement != "") {
                  return 302 $favicon_replacement;
                }
                
                # Otherwise proxy to actual site
                proxy_pass https://${domain}/favicon.ico;
                proxy_set_header Host ${domain};
                proxy_ssl_server_name on;
                proxy_ssl_protocols TLSv1.2 TLSv1.3;
              '';
            };
            
            # Proxy everything else
            "/" = {
              extraConfig = ''
                proxy_pass https://${domain}$request_uri;
                proxy_set_header Host ${domain};
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_ssl_server_name on;
                proxy_ssl_protocols TLSv1.2 TLSv1.3;
              '';
            };
          };
        };
      }) domains) // {
        # Add localhost debug endpoint
        "localhost" = {
          listen = [
            { addr = "127.0.0.1"; port = 8443; ssl = true; }
          ];
          
          extraConfig = ''
            ssl_certificate ${domainCerts."localhost"}/localhost.crt;
            ssl_certificate_key ${domainCerts."localhost"}/localhost.key;
          '';
          
          locations."/" = {
            extraConfig = ''
              add_header Content-Type text/html;
              return 200 '
                <html>
                <body>
                  <h1>Favicon Proxy Debug</h1>
                  <p>CA Certificate: ${proxyCA}/ca.crt</p>
                  <p>Import this into your browser to trust the proxy</p>
                  <p>Listening on port: 443</p>
                  <h2>Proxied Domains:</h2>
                  <ul>
                    ${concatStringsSep "\n            " 
                      (map (d: "<li><a href=\"https://${d}/debug\">${d}</a></li>") domains)}
                  </ul>
                  <h2>Affected Users:</h2>
                  <ul>
                    ${concatStringsSep "\n            "
                      (map (u: "<li>${u} (UID ${toString config.users.users.${u}.uid})</li>") cfg.users)}
                  </ul>
                </body>
                </html>
              ';
            '';
          };
        };
      };
    };

    # Ensure nginx is not exposed through firewall
    networking.firewall.allowedTCPPorts = [];
  };
}

# =============================================================================
# USAGE INSTRUCTIONS
# =============================================================================
# 
# Add this to your configuration.nix:
# 
# services.favicon-proxy = {
#   enable = true;
#   users = [ "rickastley" ];  # Add your username(s) here
#   ipResolutionInterval = "6h";  # Optional, defaults to 6h
# };
# 
# Then: sudo nixos-rebuild switch
# =============================================================================
# SETUP STEPS
# =============================================================================
# 
# 1. Enable the service with your username in configuration.nix
# 
# 2. Rebuild: sudo nixos-rebuild switch
# 
# 3. Import CA certificate into your browser:
#    Find the CA path in the debug page or check system logs
#    
#    Firefox:
#    - Settings > Privacy & Security > Certificates > View Certificates
#    - Authorities tab > Import > Select the ca.crt
#    - Check "Trust this CA to identify websites"
#    
#    Chrome/Chromium:
#    - Settings > Privacy and security > Security > Manage certificates
#    - Authorities tab > Import > Select the ca.crt
#    - Check "Trust this certificate for identifying websites"
# 
# 4. Test by visiting: https://localhost:8443/
# 
# 5. Visit https://youtube.com - should be proxied with replaced favicon!
# 
# =============================================================================
# TROUBLESHOOTING
# =============================================================================
# 
# Check resolved IPs:
# cat /run/FaviconReplacement/upstream-ips.txt
# 
# Check nftables rules:
# sudo nft list ruleset | grep -A 20 favicon-proxy
# 
# Test IP resolution:
# sudo systemctl start favicon-proxy-resolve.service
# sudo journalctl -u favicon-proxy-resolve -n 50
# 
# Check nginx logs:
# sudo journalctl -u nginx -f
# 
# View timer status:
# systemctl status favicon-proxy-resolve.timer
# 
# =============================================================================
