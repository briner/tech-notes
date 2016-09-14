# INSTALLATION OF "OBSERVATORY BY MOZILLA" ON A DEBIAN JESSIE
This document describes the steps done to install the "Observatory by Mozilla" on a Debian Jessie without docker and provides some information on how the differents pieces of software are tied together.

# INTRODUCTION
## tlsobs-api port 8083 (access: web & db)
This is the webservice. It does not scan the host itself. It is only a portal to the database.

## tlsobs-scanner (access: db & host to be scanned)
This is the scanner itself. It reads from the database what should be done and report the result to the database.

## cipherscan (needed by tlsobs-scan)
This the scanner itself.

# PREREQUESITE
## ENV
```bash
export TLSOBS_DIR=/opt/tls-observatory
export HTTPOBS_DIR=/opt/http-observatory
export HTTPOBSWEB_DIR=/opt/http-observatory-website
export CIPHERSCAN_DIR=/opt/cipherscan
export GOPATH=/opt/gotls
if [[ ! -d $HTTPOBS_DIR ]]; then mkdir -p $HTTPOBS_DIR; fi
git clone https://github.com/mozilla/http-observatory $HTTPOBS_DIR
```

## USER
Create user to run the tools
```bash
useradd -d $HTTPOBS_DIR -m httpobs
```

## DB
install postgres
```bash
apt install postgresql
```


## python
install tools to use venv
```bash
apt install python3-venv python3-wheel
```

install postgres & python3 development to be used by the python wrapper
```bash
dpkg -l | grep postgresql- | grep -i server
  # ii  postgresql-9.4                 9.4.9-0+deb8u1                    amd64        object-relational SQL database, version 9.4 server

# so let's install
apt install postgresql-server-dev-9.4 python3-dev
```


## BACKPORT
The *GO* language must not be at version 1.3. Which is the default version of
Debian:Jessie. To have a newer version we install it from backport
```bash
echo "deb http://ftp.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/backport.list
apt update
apt -t jessie-backports install golang-go
```

# CIPHERSCAN
* install it
```bash
git clone https://github.com/mozilla/cipherscan $CIPHERSCAN_DIR
```
* test it
```bash
cipherscan www.google.com
# .......................
# Target: www.google.com:443
#
# prio  ciphersuite                      protocols              pfs                 curves
# 1     ECDHE-RSA-CHACHA20-POLY1305-OLD  TLSv1.2                ECDH,P-256,256bits  prime256v1
# 2     ECDHE-RSA-AES128-GCM-SHA256      TLSv1.2                ECDH,P-256,256bits  prime256v1
# 3     ECDHE-RSA-AES128-SHA             TLSv1,TLSv1.1,TLSv1.2  ECDH,P-256,256bits  prime256v1
# 4     AES128-GCM-SHA256                TLSv1.2                None                None
# 5     AES128-SHA                       TLSv1,TLSv1.1,TLSv1.2  None                None
# 6     AES128-SHA256                    TLSv1.2                None                None
# 7     DES-CBC3-SHA                     TLSv1,TLSv1.1,TLSv1.2  None                None
# 8     ECDHE-RSA-AES256-GCM-SHA384      TLSv1.2                ECDH,P-256,256bits  prime256v1
# 9     ECDHE-RSA-AES128-SHA256          TLSv1.2                ECDH,P-256,256bits  prime256v1
# 10    ECDHE-RSA-AES256-SHA             TLSv1,TLSv1.1,TLSv1.2  ECDH,P-256,256bits  prime256v1
# 11    ECDHE-RSA-AES256-SHA384          TLSv1.2                ECDH,P-256,256bits  prime256v1
# 12    AES256-GCM-SHA384                TLSv1.2                None                None
# 13    AES256-SHA                       TLSv1,TLSv1.1,TLSv1.2  None                None
# 14    AES256-SHA256                    TLSv1.2                None                None
#
# Certificate: trusted, 2048 bits, sha256WithRSAEncryption signature
# TLS ticket lifetime hint: 100800
# OCSP stapling: not supported
# Cipher ordering: server
# Curves ordering: server - fallback: no
# Server supports secure renegotiation
# Server supported compression methods: NONE
# TLS Tolerance: yes
```



# tls-observatory
## backport
Debian Jessie ships a golang-go not working with tls-observatory. Let's add
the debian backport and install the new version of golang-go

```bash
echo "deb http://ftp.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/backport.list
apt -t jessie-backports install golang-go
go version
  # go version go1.6.2 linux/amd64
```

## stuff about the config
* clone it
```bash
if [[ ! -d $TLSOBS_DIR ]]; then mkdir -p $TLSOBS_DIR; fi
git clone https://github.com/mozilla/tls-observatory $TLSOBS_DIR
```
* copy the config
```bash
if [[ ! -d /etc/tls-observatory ]]; then mkdir -p /etc/tls-observatory ; fi
cp -aT $TLSOBS_DIR/conf/ /etc/tls-observatory/
```

## database postgres
* install makepasswd: ```apt install makepasswd```
* Note: I found out that the database needed for this project was described on the [aws_create_env.sh](https://github.com/mozilla/tls-observatory/blob/master/tools/aws_create_env.sh#L77) with the lines:
* do it

```bash
# create user named: tlsobdamin
su - postgres -c "createuser tlsobsadmin -P"
  # Enter password for new role:
  # Enter it again:
# create the db named : observatory
su - postgres -c "createdb -O tlsobsadmin observatory"

# create database schema
su - postgres -c "psql -d observatory  -c '\i $TLSOBS_DIR/database/schema.sql'"
  # no errors should be written

# generate password for tlsobsapi
apipass=$(makepasswd --chars=20)
# generate password for tlsobsapi
scanpass=$(makepasswd --chars=20)

# set the password for the api & the scan daemons.
cat > /tmp/dbusercreate.sql << EOF
\c postgres
ALTER ROLE tlsobsapi LOGIN PASSWORD '$apipass';
ALTER ROLE tlsobsscanner LOGIN PASSWORD '$scanpass';
EOF
su - postgres -c "psql -d observatory -c '\i /tmp/dbusercreate.sql'"
rm /tmp/dbusercreate.sql

# add the password to the configuration file
sed -ri "s|^\s*PostgresPass\s*=\s*.*$|PostgresPass    = \"${apipass}\"|" /etc/tls-observatory/api.cfg
sed -ri "s|^\s*PostgresPass\s*=\s*.*$|PostgresPass    = \"${scanpass}\"|" /etc/tls-observatory/scanner.cfg

# echo it
echo "Observatory database created with users tlsobsapi:$apipass and tlsobsscanner:$scanpass"
```

* install binaries
```bash
# GOPATH
if [[ ! -d $GOPATH ]]; then mkdir -p $GOPATH ; fi
# tlsbos-api
go get github.com/mozilla/tls-observatory/tlsobs-api
# tlsobs-scanner
go get github.com/mozilla/tls-observatory/tlsobs-scanner
```

* test it:
 * on 3 terminals do
  * ```/opt/gotls/bin/tlsobs-api -debug```
  * ```/opt/gotls/bin/tlsobs-scanner -debug```
  * curl it
   * ```curl --data "target=www.unige.ch&rescan=False" http://127.0.0.1:8083/api/v1/scan```
   ```json
   {"scan_id":1}
   ```

   * ```curl http://127.0.0.1:8083/api/v1/results?id=1```
   ```json
    {"id":1,"timestamp":"2016-09-06T12:12:22.141468Z","target":"www.unige.ch",
     "replay":-1,"has_tls":true,"cert_id":411,"trust_id":1,"is_valid":true,
     "completion_perc":100,"connection_info":{"scanIP":"129.194.9.50"},
     "...":"..."}
    ```

# http-observatory-website
* clone it
```bash
if [[ ! -d $HTTPOBSWEB_DIR ]]; then mkdir -p $HTTPOBSWEB_DIR; fi
git clone https://github.com/mozilla/http-observatory-website $HTTPOBSWEB_DIR
```
* install make
```bash
apt install make
```

* modify ```$HTTPOBSWEB_DIR/js```

```diff
diff --git a/js/httpobs-third-party.js b/js/httpobs-third-party.js
index 39084f7..3b01243 100644
--- a/js/httpobs-third-party.js
+++ b/js/httpobs-third-party.js
@@ -622,9 +622,9 @@ function loadTLSObservatoryResults(rescan, initiateScanOnly) {
     var rescan = typeof rescan !== 'undefined' ? rescan : false;
     var initiateScanOnly = typeof initiateScanOnly !== 'undefined' ? initiateScanOnly : false;

-    var SCAN_URL = 'https://tls-observatory.services.mozilla.com/api/v1/scan';
-    var RESULTS_URL = 'https://tls-observatory.services.mozilla.com/api/v1/results';
-    var CERTIFICATE_URL = 'https://tls-observatory.services.mozilla.com/api/v1/certificate';
+    var SCAN_URL = 'http://http-observatory.unige.ch:8083/api/v1/scan';
+    var RESULTS_URL = 'http://http-observatory.unige.ch:8083/api/v1/results';
+    var CERTIFICATE_URL = 'http://http-observatory.unige.ch:8083/api/v1/certificate';

     // if it's the first scan through, we need to do a post
     if (Observatory.state.third_party.tlsobservatory.scan_id === undefined || rescan) {
@@ -698,4 +698,4 @@ function loadTLSObservatoryResults(rescan, initiateScanOnly) {
             url: CERTIFICATE_URL
         });
     }
-}
\ No newline at end of file
+}
diff --git a/js/httpobs.js b/js/httpobs.js
index d2dbcdb..84bd101 100644
--- a/js/httpobs.js
+++ b/js/httpobs.js
@@ -1,5 +1,5 @@
 var Observatory = {
-    api_url: 'https://http-observatory.security.mozilla.org/api/v1/',
+    api_url: 'http://http-observatory.unige.ch:57001/api/v1/',
     grades: ['A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'D-', 'F'],
     htbridge_api_url: 'https://www.htbridge.com/ssl/chssl/',
     safebrowsing: {
diff --git a/js/httpobs-third-party.js b/js/httpobs-third-party.js
index 39084f7..3b01243 100644
--- a/js/httpobs-third-party.js
+++ b/js/httpobs-third-party.js
@@ -622,9 +622,9 @@ function loadTLSObservatoryResults(rescan, initiateScanOnly) {
     var rescan = typeof rescan !== 'undefined' ? rescan : false;
     var initiateScanOnly = typeof initiateScanOnly !== 'undefined' ? initiateScanOnly : false;

-    var SCAN_URL = 'https://tls-observatory.services.mozilla.com/api/v1/scan';
-    var RESULTS_URL = 'https://tls-observatory.services.mozilla.com/api/v1/results';
-    var CERTIFICATE_URL = 'https://tls-observatory.services.mozilla.com/api/v1/certificate';
+    var SCAN_URL = 'http://http-observatory.unige.ch:8083/api/v1/scan';
+    var RESULTS_URL = 'http://http-observatory.unige.ch:8083/api/v1/results';
+    var CERTIFICATE_URL = 'http://http-observatory.unige.ch:8083/api/v1/certificate';

     // if it's the first scan through, we need to do a post
     if (Observatory.state.third_party.tlsobservatory.scan_id === undefined || rescan) {
@@ -698,4 +698,4 @@ function loadTLSObservatoryResults(rescan, initiateScanOnly) {
             url: CERTIFICATE_URL
         });
     }
-}
\ No newline at end of file
+}
diff --git a/js/httpobs.js b/js/httpobs.js
index d2dbcdb..84bd101 100644
--- a/js/httpobs.js
+++ b/js/httpobs.js
@@ -1,5 +1,5 @@
 var Observatory = {
-    api_url: 'https://http-observatory.security.mozilla.org/api/v1/',
+    api_url: 'http://http-observatory.unige.ch:57001/api/v1/',
     grades: ['A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'D-', 'F'],
     htbridge_api_url: 'https://www.htbridge.com/ssl/chssl/',
     safebrowsing: {
```

* once it is modified, publish it with
```bash
cd $HTTPOBSWEB_DIR
make publish
```

* configure apache
```
	ServerName http-observatory.example.com

	ServerAdmin webmaster@localhost
	DocumentRoot /opt/http-observatory-website/dist/


	<Directory /opt/http-observatory-website/dist/>
	       Options Indexes FollowSymLinks
	       AllowOverride None
	       Require all granted
	</Directory>

```


# http-observatory
* create a /etc/http-observatory and create the password
```bash
if [[ ! -d  /etc/http-observatory ]]; then mkdir -p /etc/http-observatory; fi
echo "httpobsapi $(makepasswd --chars=20)" > /etc/http-observatory/cesame
echo "httpobscanner $(makepasswd --chars=20)" >> /etc/http-observatory/cesame
chmod 600 /etc/http-observatory/cesame
```

* clone it
```bash
if [[ ! -d $HTTPOBS_DIR ]]; then mkdir -p $HTTPOBS_DIR; fi
git clone https://github.com/mozilla/http-observatory $HTTPOBS_DIR
```
* venv

```bash
cd $HTTPOBS_DIR
python3 -mvenv venv

# activate it
source venv/bin/activate

# now the prompt starts with "(venv)"
```

* install python requirement
```bash
# in the venv
pip install -r requirements.txt
```

* install the httpobs in pip
```bash
pip install .
```

* insall redis-server
```bash
apt install redis-server
```

* create the db

```bash
su - postgres -c "createdb http_observatory"
su - postgres -c "psql http_observatory < $HTTPOBS_DIR/httpobs/database/schema.sql"
  # CREATE TABLE
  # …
  # COMMENT
  # GRANT
  # ALTER MATERIALIZED VIEW

# set the password
cat /etc/http-observatory/cesame
su - postgres -c "psql http_observatory"
\password httpobsapi
  # Enter new password:
  # Enter it again:
\password httpobsscanner
  # Enter new password:
  # Enter it again:
^D
```
* modify postgres conf ```/etc/postgresql/9.4/main/postgresql.conf```
```
max_connections = 512
shared_buffers = 256MB
```
 * restart postgres```systemctl restart postgresql```

* create repertory accessible for httpobs
```bash
mkdir /var/{run,log}/httpobs
chown httpobs: /var/{run,log}/httpobs
```

* test it
 * open 2 consoles as preambule and one web browser
  * 1st
  ```bash
  cat /etc/http-observatory/cesame
  su - httpobs -s /bin/bash
  source /opt/http-observatory/venv/bin/activate
  cd /opt/http-observatory
  HTTPOBS_DATABASE_USER="httpobsscanner" HTTPOBS_DATABASE_PASS="scanner_pass" \
    /opt/http-observatory/httpobs/scripts/httpobs-scan-worker
  ```
  * 2nd
  ```bash
  cat /etc/http-observatory/cesame
  su - httpobs -s /bin/bash
  source /opt/http-observatory/venv/bin/activate
  cd /opt/http-observatory
  HTTPOBS_DATABASE_USER="httpobsapi" HTTPOBS_DATABASE_PASS="api_apss" \
  ```
  * web browser on http-observatory.example.com
