:local hostname [ /system identity get name ]
/tool fetch mode=http address="certs.foxden.network" src-path="/certs/$hostname.foxden.network.crt" dst-path="/hostname_crt.pem"
:delay 2
/certificate remove [ find common-name="$hostname.foxden.network" ]
/certificate import file-name="hostname_crt.pem" passphrase=""
/certificate import file-name="flash/hostname_key.pem" passphrase=""
:delay 5
/ip service set www-ssl certificate=hostname_crt.pem_0
/ip service set api-ssl certificate=hostname_crt.pem_0
/file remove hostname_crt.pem
