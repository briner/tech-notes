
# Installation de l'OS
* passer en minimal ([p.16](https://confs.imirhil.fr/20170513_root66_securite-admin-sys/#16))
  * desactiver les suggests et recommends
```
/etc/apt/apt.conf.d/60recommends
APT::Install-Recommends "0";
APT::Install-Suggests "0";
```

* Activez les mises-à-jour de sécurité et de publication ([p.18](https://confs.imirhil.fr/20170513_root66_securite-admin-sys/#18))
```
/etc/apt/sources.list.d/debian.list
deb http://deb.debian.org/debian/ jessie main
deb http://deb.debian.org/debian/ jessie-updates main
deb http://deb.debian.org/debian-security/ jessie/updates main
```

* seulement connexion par clef ssh ([p.23](https://confs.imirhil.fr/20170513_root66_securite-admin-sys/#23))
  * Suffisamment robuste (RSA > 3072 bits ou ED25519 ❤️)
```
/etc/ssh/sshd_config
Port XXXX
#HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_dsa_key
#HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
PermitRootLogin prohibit-password
PasswordAuthentication no
Ciphers chacha20-poly1305@openssh.com
KexAlgorithms curve25519-sha256@libssh.org
MACs umac-128-etm@openssh.com
```

* mise en place de fail2ban ([p.26](https://confs.imirhil.fr/20170513_root66_securite-admin-sys/#26))
  * attention à ne pas s'auto-bannir
  * ssh

* Réseau ([p.28](https://confs.imirhil.fr/20170513_root66_securite-admin-sys/#28))
  * Vérifier la source (UDP spoofing)
```
sysctl -w net.ipv4.conf.default.rp_filter = 1
`
  * Activer les SYN cookies (limite le SYN flooding)
```
sysctl -w net.ipv4.tcp_syncookies = 1
```
  * Rejeter les redirections ICMP (limite les MitM)
```
sysctl -w net.ipv4.conf.all.accept_redirects = 0
sysctl -w net.ipv4.conf.all.secure_redirects = 0
```
  * Désactiver le source routing
```
sysctl -w net.ipv4.conf.default.accept_source_route = 0``
```

* TLS ([p.35](https://confs.imirhil.fr/20170513_root66_securite-admin-sys/#35))
  * taille de la clef > 3072

* HTTPD ([p.36](https://confs.imirhil.fr/20170513_root66_securite-admin-sys/#36))
  * masquer le n° de version, l'OS
```
# apache
ServerTokens Prod
ServerSignature Off
# nginx
server_tokens off;
```
  * déscativer mod_status
  * désactiver le listing des répertoires
```
# apache
Options -Indexes
# nginx
# Par défaut (autoindex on;)
```
  * activer le HSTS
    * (hsts preload)[https://hstspreload.org/]
```
Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
```
  * activer le Content Security Policy
```
Content-Security-Policy "default-src 'none'; style-src 'self';
			script-src 'self'; img-src 'self';"
```
  * autres en-têtes de sécurité
```
X-Content-Type-Options "nosniff"
X-Frame-Options "DENY"
X-XSS-Protection "1; mode=block"
```

* smtp ([p.38](https://confs.imirhil.fr/20170513_root66_securite-admin-sys/#38))
  * utilisation de submission(587)


* HPKP pour le web([p.61](https://confs.imirhil.fr/20170513_root66_securite-admin-sys/#61))
  * pour éviter des problèmes de C.A.



