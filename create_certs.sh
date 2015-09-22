echo "G�n�ration de certificats par Simon Hallay"
echo "Nom pour le r�pertoire ?"
read repetoire
mkdir $repertoire
cd $repertoire

echo "[ ca ]
default_ca      = CA_default

[ CA_default ]
dir             = .
certs           = $dir/ca/certs
new_certs_dir   = $dir/ca/newcerts
database        = $dir/ca/index.txt
certificate     = $dir/ca/ca.pem
serial          = $dir/ca/serial
private_key     = $dir/ca/ca.key
default_days    = 365
default_md      = sha1
preserve        = no
policy          = policy_match

[ CA_ssl_default ]
dir             = .
certs           = $dir/cassl/certs
new_certs_dir   = $dir/cassl/newcerts
database        = $dir/cassl/index.txt
certificate     = $dir/cassl/cassl.pem
serial          = $dir/cassl/serial
private_key     = $dir/cassl/cassl.key
default_days    = 365
default_md      = sha1
preserve        = no
policy          = policy_match

[ policy_match ]
countryName             = match
stateOrProvinceName     = match
localityName		= match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
distinguished_name      = req_distinguished_name

[ req_distinguished_name ]
countryName                     = Pays
countryName_default             = FR
stateOrProvinceName             = Departement
stateOrProvinceName_default     = Ile-de-France
localityName                    = Ville
localityName_default            = Levallois-Perret
organizationName        	= Organisation
organizationName_default        = Herve Schauer Consultants
commonName                      = Nom ou URL
commonName_max                  = 64
emailAddress                    = Adresse Email
emailAddress_max                = 40

[CA_ROOT]
nsComment                       = \"CA Racine\"
subjectKeyIdentifier            = hash
authorityKeyIdentifier          = keyid,issuer:always
basicConstraints                = critical,CA:TRUE,pathlen:1
keyUsage                        = keyCertSign, cRLSign

[CA_SSL]
nsComment                       = \"CA SSL\"
basicConstraints                = critical,CA:TRUE,pathlen:0
subjectKeyIdentifier            = hash
authorityKeyIdentifier          = keyid,issuer:always
issuerAltName                   = issuer:copy
keyUsage                        = keyCertSign, cRLSign
nsCertType                      = sslCA

[SERVER_RSA_SSL]
nsComment                       = \"Certificat Serveur SSL\"
subjectKeyIdentifier            = hash
authorityKeyIdentifier          = keyid,issuer:always
issuerAltName                   = issuer:copy
subjectAltName                  = DNS:www.webserver.com, DNS:www.webserver-bis.com
basicConstraints                = critical,CA:FALSE
keyUsage                        = digitalSignature, nonRepudiation, keyEncipherment
nsCertType                      = server
extendedKeyUsage                = serverAuth

[CLIENT_RSA_SSL]
nsComment                       = \"Certificat Client SSL\"
subjectKeyIdentifier            = hash
authorityKeyIdentifier          = keyid,issuer:always
issuerAltName                   = issuer:copy
subjectAltName                  = critical,email:copy,email:user-bis@domain.com,email:user-ter@domain.com
basicConstraints                = critical,CA:FALSE
keyUsage                        = digitalSignature, nonRepudiation
nsCertType                      = client
extendedKeyUsage                = clientAuth" > openssl.cnf

mkdir -p ca/newcerts
touch ca/index.txt
echo '01' ca/serial
mkdir -p cassl/newcerts
touch cassl/index.txt
echo '01' > cassl/serial
openssl genrsa -out ca/ca.key -des3 2048
openssl req -new -x509 -key ca/ca.key -out ca/ca.pem -config ./openssl.cnf -extensions CA_ROOT
openssl x509 -in ca/ca.pem -text -noout

openssl genrsa -out cassl/cassl.key -des3 2048
openssl req -new -key cassl/cassl.key -out cassl/cassl.crs -config ./openssl.cnf
openssl ca -out cassl/cassl.pem -config ./openssl.cnf -extensions CA_SSL -infiles cassl/cassl.crs

openssl x509 -in cassl/cassl.pem -text -noout

openssl genrsa -out cassl/serverssl.key -des3 1024
openssl req -new -key cassl/serverssl.key -out cassl/serverssl.crs -config ./openssl.cnf
openssl ca -out cassl/serverssl.pem -name CA_ssl_default -config ./openssl.cnf -extensions SERVER_RSA_SSL -infiles cassl/serverssl.crs

openssl genrsa -out cassl/serverssl.key -des3 1024
openssl ca -out cassl/clientssl.pem -name CA_ssl_default -config ./openssl.cnf -extensions CLIENT_RSA_SSL -infiles cassl/clientssl.crs
openssl pkcs12 -export -inkey cassl/clientssl.key -in cassl/clientssl.pem -out clientssl.p12 -name "Certificat client"





