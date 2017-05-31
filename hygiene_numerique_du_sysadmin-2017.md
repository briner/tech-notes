
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
