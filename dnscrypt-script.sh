#!/bin/bash
clear
echo "
█████╗ ███╗   ██╗██████╗ ██╗   ██╗
██╔══██╗████╗  ██║██╔══██╗╚██╗ ██╔╝
███████║██╔██╗ ██║██║  ██║ ╚████╔╝
██╔══██║██║╚██╗██║██║  ██║  ╚██╔╝
██║  ██║██║ ╚████║██████╔╝   ██║
╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝    ╚═╝
██████╗ ██████╗  ██████╗ ██████╗     ██╗ ██████╗ ███████╗
██╔══██╗██╔══██╗██╔═══██╗██╔══██╗    ██║██╔═══██╗██╔════╝
██████╔╝██████╔╝██║   ██║██████╔╝    ██║██║   ██║█████╗
██╔═══╝ ██╔══██╗██║   ██║██╔═══╝██   ██║██║   ██║██╔══╝
██║     ██║  ██║╚██████╔╝██║    ╚█████╔╝╚██████╔╝███████╗
╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚════╝  ╚═════╝ ╚══════╝
Installation de DNSCrypt.
"
sleep 2
echo "Ce script se base sur le postulat que votre interface de réseau local est eth0"
sleep 2
clear
echo "Installation et dépendances"
sleep 1

wget http://cdn-fastly.deb.debian.org/debian/pool/main/libt/libtool/libltdl7_2.4.6-2_amd64.deb && dpkg -i libltdl7_2.4.6-2_amd64.deb
wget http://cdn-fastly.deb.debian.org/debian/pool/main/libs/libsodium/libsodium18_1.0.11-1_amd64.deb && dpkg -i libsodium18_1.0.11-1_amd64.deb
wget http://cdn-fastly.deb.debian.org/debian/pool/main/d/dnscrypt-proxy/dnscrypt-proxy_1.9.4-1_amd64.deb && dpkg -i dnscrypt-proxy_1.9.4-1_amd64.deb

echo "Configuration de dnscrypt-proxy et du port d'écoute"
sleep 1
mv /lib/systemd/system/dnscrypt-proxy.socket /lib/systemd/system/dnscrypt-proxy.socket.bak
touch /lib/systemd/system/dnscrypt-proxy.socket

echo
"[Unit]
Description=dnscrypt-proxy listening socket
Documentation=man:dnscrypt-proxy(8)
Wants=dnscrypt-proxy-resolvconf.service

[Socket]
ListenStream=127.0.0.1:5353
ListenDatagram=127.0.0.1:5353

[Install]
WantedBy=sockets.target" | tee -a /lib/systemd/system/dnscrypt-proxy.socket

mv /etc/dnscrypt-proxy/dnscrypt-proxy.conf /etc/dnscrypt-proxy/dnscrypt-proxy.conf.bak
touch /etc/dnscrypt-proxy/dnscrypt-proxy.conf

echo
"ResolverName d0wn-random-ns2
ResolverName d0wn-random-ns2-ipv6
LocalAddress 127.0.0.1:5353" | tee -a /etc/dnscrypt-proxy/dnscrypt-proxy.conf

clear
sleep 1
echo "Installation et configuration réussie, redémarrage des services"

systemctl enable dnscrypt-proxy.service
systemctl enable dnscrypt-proxy.socket
systemctl start dnscrypt-proxy.service
systemctl start dnscrypt-proxy.socket

echo "Lecture du statut du service"
sleep 1
systemctl status dnscrypt-proxy.service
sleep 2
systemctl status dnscrypt-proxy.socket
sleep 2

clear

echo "Installation et configuration de DNSMasq"
sleep 2

mv /etc/resolv.conf /etc/resolv.conf.bak
touch /etc/resolv.conf

echo "nameserver 127.0.0.1" | tee -a /etc/resolv.conf

echo "Verrouillage du fichier /etc/resolv.conf"
sleep 1
chattr +i /etc/resolv.conf

apt-get update
apt-get install dnsmasq

mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
touch  /etc/dnsmasq.conf

echo "Entrez ici l'IP locale de votre serveur (ex: 192.168.1.22) : " | read IP

echo
"port=53
domain-needed
bogus-priv
dnssec
proxy-dnssec
no-resolv
server=127.0.0.1#5353
interface=eth0
listen-address=$IP
expand-hosts" | tee -a /etc/dnsmasq.conf

echo "Relancement de tous les services"
sleep 1
systemctl enable dnsmasq.service
systemctl restart dnscrypt-proxy.socket
systemctl restart dnscrypt-proxy.service
systemctl restart dnsmasq.service

clear
echo "
INSTALLATION TERMINEE AVEC SUCCES ! VOUS POUVEZ DESORMAIS AJOUTER
L'ADRESSE IP DE CE SEVEUR EN TEMPS QUE SERVEUR DE DNS.
RENDEZ VOUS ENSUITE SUR :
HTTPS://WWW.DNSLEAKTEST.COM POUR TESTER VOS DNS."
sleep 3
clear

echo
"
##################################################################
##   ATTENTION !!! LES FICHIERS DE CONFIGURATION SUIVANTS       ##
##   ONT ETE MODIFIES ET SAUVEGARDES :                          ##
##   /etc/dnscrypt-proxy/dnscrypt-proxy.conf.bak                ##
##   /lib/systemd/system/dnscrypt-proxy.socket.bak              ##
##   /etc/dnsmasq.conf.bak                                      ##
##                                                              ##
##   IL EST DONC POSSIBLE DE LES RESTAURER...                   ##
##################################################################
LE PORT D'ECOUTE DE DNSCRYPT EST : 5353
LE PORT DE DNSMASQ EST : 53.
___________________________________________________________
RENDEZ VOUS SUR CARMAGNOLE.OVH POUR CONFIGURER L'ENTROPIE !
MERCI A BIENTÔT ! ANDY & PROPJOE
"
