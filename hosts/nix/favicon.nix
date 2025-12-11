# NixOS Configuration for Local SSL-Terminating Favicon Proxy
# Certificates are generated as derivations during nixos-rebuild

{ config, pkgs, lib, ... }:

let
  # List of domains to proxy
  domains = [
    "youtube.com"
    "www.youtube.com"
    "github.com"
    "www.github.com"
    "moodle.telt.unsw.edu.au"
    "www.moodle.telt.unsw.edu.au"
  ];
  
  # Real upstream IPs (to avoid DNS resolution loops)
  upstreamHosts = {
    "youtube.com" = "142.250.70.174";  # Google IP
    "www.youtube.com" = "142.250.70.174";
    "github.com" = "140.82.121.4";  # GitHub IP
    "www.github.com" = "140.82.121.4";
    "moodle.telt.unsw.edu.au" = "149.28.11.230";  # UNSW IP
    "www.moodle.telt.unsw.edu.au" = "149.28.11.230";
  };
  
  # Map domains to replacement favicons
  faviconReplacements = let
    youtube = "https://rule34.xxx/favicon.ico";
    moodle = "https://onlyfans.com/favicon.ico";
    github = "https://pornhub.com/favicon.ico";
  in {
    "youtube.com" = youtube;
    "www.youtube.com" = youtube;
    "github.com" = github;
    "www.github.com" = github;
    "moodle.telt.unsw.edu.au" = moodle;
    "www.moodle.telt.unsw.edu.au" = moodle;
  };

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

  # Generate all domain certificates
  domainCerts = builtins.listToAttrs (map (domain: {
    name = domain;
    value = mkDomainCert domain;
  }) domains);

in {
  # Trust the CA certificate system-wide
  security.pki.certificateFiles = [ "${proxyCA}/ca.crt" ];

  # Configure nginx with SSL termination
  services.nginx = {
    enable = true;
    logError = "stderr debug";
    
    commonHttpConfig = ''
      resolver 8.8.8.8 8.8.4.4 1.1.1.1 valid=300s;
      resolver_timeout 5s;
      
      # Map for favicon replacements
      map $host $favicon_replacement {
        default "";
        ${lib.concatStringsSep "\n    " 
          (lib.mapAttrsToList (domain: url: ''"${domain}" "${url}";'') 
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
    }) domains);
  };

  # Ensure nginx is not exposed through firewall
  networking.firewall.allowedTCPPorts = [];
  
  # Redirect domains to localhost
  networking.hosts = {
    "127.0.0.1" = domains;
  };
}

# =============================================================================
# SETUP INSTRUCTIONS
# =============================================================================
# 
# 1. Add this configuration to your /etc/nixos/configuration.nix
# 
# 2. Run: sudo nixos-rebuild switch
#    (Certificates are generated during build as Nix derivations)
# 
# 3. Find the CA certificate path in the debug page or run:
#    nix-store -q --references /run/current-system | grep proxy-ca
#    
# 4. The CA is automatically trusted system-wide via security.pki.certificateFiles
#    
# 5. For browsers, import the CA certificate:
#    
#    Find CA path:
#    ls -la /nix/store/*-proxy-ca/ca.crt
#    
#    Firefox:
#    - Settings > Privacy & Security > Certificates > View Certificates
#    - Authorities tab > Import > Select the ca.crt from /nix/store
#    - Check "Trust this CA to identify websites"
#    
#    Chrome/Chromium:
#    - Settings > Privacy and security > Security > Manage certificates
#    - Authorities tab > Import > Select the ca.crt from /nix/store
#    - Check "Trust this certificate for identifying websites"
# 
# 6. Test by visiting: https://youtube.com/debug
# 
# 7. Visit https://youtube.com and check if favicon is replaced!
# 
# =============================================================================
# BENEFITS OF THIS APPROACH
# =============================================================================
# 
# - Certificates are pure Nix derivations (reproducible, cached)
# - Regenerated only when you change the config and rebuild
# - No runtime certificate generation services needed
# - CA is automatically trusted system-wide for system applications
# - The CA path is shown in the debug page for easy browser import
# 
# =============================================================================
# TO ADD MORE DOMAINS
# =============================================================================
# 
# Just add to the domains list and faviconReplacements map:
# 
# domains = [
#   "youtube.com"
#   "reddit.com"     # Add new domain
#   # ...
# ];
# 
# faviconReplacements = {
#   "youtube.com" = "https://www.google.com/favicon.ico";
#   "reddit.com" = "https://example.com/custom-icon.png";  # Add replacement
#   # ...
# };
# 
# Then: sudo nixos-rebuild switch
# 
# =============================================================================
