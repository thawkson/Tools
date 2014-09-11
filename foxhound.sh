#!/bin/bash

if [ ! $# == 1 ]; then
	echo "You Must Enter in at least 1 argument X.X.X"
	exit
fi

CLASS="$1"
PROPECIA="/usr/sbin/propecia2"
NIKTO="/usr/bin/nikto"
ONESIXTYONE="/usr/bin/onesixtyone"

echo "[+] Make the working directories..."
mkdir -p /tmp/customerAudit/$CLASS/internal/scan/services/
mkdir -p /tmp/customerAudit/$CLASS/internal/scan/active_hosts/
mkdir -p /tmp/customerAudit/$CLASS/internal/scan/targets/
mkdir -p /tmp/customerAudit/$CLASS/internal/scan/windows/
mkdir -p /tmp/customerAudit/$CLASS/internal/scan/SNMP/
mkdir -p /tmp/customerAudit/$CLASS/internal/scan/dns/
mkdir -p /tmp/customerAudit/$CLASS/internal/scan/ftp/
mkdir -p /tmp/customerAudit/$CLASS/internal/scan/http/
mkdir -p /tmp/customerAudit/$CLASS/internal/scan/smtp/
mkdir -p /tmp/customerAudit/$CLASS/internal/scan/sunrpc/
mkdir -p /tmp/customerAudit/$CLASS/internal/scan/telnet/
mkdir -p /tmp/customerAudit/$CLASS/internal/scan/printers/
mkdir -p /tmp/customerAudit/$CLASS/internal/scan/mssql_databases/
mkdir -p /tmp/customerAudit/$CLASS/internal/scan/oracle_databases/
mkdir -p /tmp/customerAudit/$CLASS/internal/scan/mysql_databases/


#Setup Directory VARS
MYSQL_DATABASE_DIR="/tmp/customerAudit/$CLASS/internal/scan/mysql_databases/"
ORACLE_DATABASE_DIR="/tmp/customerAudit/$CLASS/internal/scan/oracle_databases/"
MSSQL_DATABASE_DIR="/tmp/customerAudit/$CLASS/internal/scan/mssql_databases/"
PRINTERS_DIR="/tmp/customerAudit/$CLASS/internal/scan/printers/"
TELNET_DIR="/tmp/customerAudit/$CLASS/internal/scan/telnet/"
SUNRPC_DIR="/tmp/customerAudit/$CLASS/internal/scan/sunrpc/"
WINDOWS_DIR="/tmp/customerAudit/$CLASS/internal/scan/windows/"
TARGETS_DIR="/tmp/customerAudit/$CLASS/internal/scan/targets/"
ACTIVE_HOSTS_DIR="/tmp/customerAudit/$CLASS/internal/scan/active_hosts/"
SERVICES_DIR="/tmp/customerAudit/$CLASS/internal/scan/services"

echo "[*] Scanning for active hosts using ping..."
for ip in $(seq 200 254); do ping -c 1 $CLASS.$ip | grep "bytes from" | cut -d" " -f 4 | cut -d":" -f 1; done >> $ACTIVE_HOSTS_DIR$CLASS


echo "[+] Initiating Preliminary Scan to find Interesting Targets.."


######################
# Find Windows Hosts #
######################
echo "[+] Scanning for windows hosts.."
             	$PROPECIA $CLASS 445 >> $SERVICES_DIR/SMB
		$PROPECIA $CLASS 135 >> $SERVICES_DIR/RPC
		$PROPECIA $CLASS 139 >> $SERVICES_DIR/NETBIOS-Session
		$PROPECIA $CLASS 137 >> $SERVICES_DIR/NETBIOS-Name
		$PROPECIA $CLASS 3389 >> $SERVICES_DIR/RDP
		$PROPECIA $CLASS 389 >> $SERVICES_DIR/AD_unsecure
		$PROPECIA $CLASS 636 >> $SERVICES_DIR/AD_secure
echo "Done scanning for windows hosts."

#######
# DNS #
#######
echo "[+] Scanning for DNS Servers..."
		$PROPECIA $CLASS 53 >> $SERVICES_DIR/DNS
echo "[-] Done Scanning for DNS Servers.."

########
# DHCP #
########
echo "[+] Scanning for DHCP Servers.."
		$PROPECIA $CLASS 67 >> $SERVICES_DIR/DHCP
echo "[-] Done Scanning for DHCP Servers.."

#######
# NTP #
######
echo "[+] Scanning for NTP Servers..."
		$PROPECIA $CLASS 123 >> $SERVICES_DIR/NTP
echo "[-] Done Scanning for NTP Servers.."

########
# SNMP #
########
echo "[+] Scanning for SNMP Hosts..."
		$PROPECIA $CLASS 161 >> $SERVICES_DIR/SNMP
echo "[-] Done Scanning for SNMP Servers..."

##################
# Find FTP Hosts #
##################
echo "[+] Scanning for FTP hosts.."
             $PROPECIA $CLASS 21 >> $SERVICES_DIR/ftp_hosts
echo "[-] Done scanning for FTP hosts. SunRPC is next."

########
# Mail #
########
echo "[+] Scanning for SMTP hosts..."
		$PROPECIA $CLASS 25 >> $SERVICES_DIR/smtp_hosts
echo "[+] Scanning for POP3 hosts..."
		$PROPECIA $CLASS 110 >> $SERVICES_DIR/pop3_hosts
echo "[+] Scanning for IMAP hosts...."
		$PROPECIA $CLASS 143 >> $SERVICES_DIR/imap_hosts
echo "[-] Done Scanning for Mail Servers"

###################
# Find WebServers #
###################
echo "[+] Scanning for HTTP service..."
		$PROPECIA $CLASS 80 >> $SERVICES_DIR/HTTP_webservers
echo "[+] Scanning for HTTPS service.."
		$PROPECIA $CLASS 443 >> $SERVICES_DIR/HTTPS_webservers
echo "[+] Scanning for Proxy Servers..."
		$PROPECIA $CLASS 8080 >> $SERVICES_DIR/Proxys
echo "[-] Done scanning for Web Servers."

#####################
# Find SunRPC Hosts #
#####################
echo "[+] Scanning for SunRPC hosts.."
             $PROPECIA $CLASS 111 >> $SERVICES_DIR/sunrpc_hosts
echo "[-] Done scanning for SunRPC hosts. Telnet is next."


#########################
# Find Telnet/ssh Hosts #
#########################
echo "[+] Scanning For Telnet Hosts.."
             $PROPECIA $CLASS 23 >> $SERVICES_DIR/telnet_hosts
echo "[+] Scanning for SSH Hosts.."
             $PROPECIA $CLASS 22 >> $SERVICES_DIR/ssh_hosts
echo "[-] Done scanning for Telnet and SSH hosts. Printers are next."


#################
# Find Printers #
#################
echo "[+] Scanning for Printers.." 
	    $PROPECIA $CLASS 9100 >> $SERVICES_DIR/printserver_hosts 
echo "[-] Done scanning for Printers. Databases are next."

#######
# VNC #
#######
echo "[+] Scanning for VNC..."
		$PROPECIA $CLASS 5900 >> $SERVICES_DIR/vnc
echo "[-] Done Scanning for VNC..."

##################
# Find Databases #
##################
echo "[+] Scanning for MSSQL Databases.."
             $PROPECIA $CLASS 1433 >> $SERVICES_DIR/mssql_hosts
echo "[+] Scanning for Oracle Databases.."
             $PROPECIA $CLASS 1521 >> $SERVICES_DIR/oracle_hosts
echo "[+] Scanning for MySQL Databases.."
             $PROPECIA $CLASS 3306 >> $SERVICES_DIR/mysql_hosts
echo "[-] Done doing the Prelimiary host discovery." 

#######################
# Create Targets List #
#######################
echo "[+] Creating TargetList..."
	for x in `ls $SERVICES_DIR` ; do cat $SERVICES_DIR/$x >> $TARGETS_DIR/tmptargetlist ; done
echo "[+] Sorting Targetlist and removing duplicates..."
	cat $TARGETS_DIR/tmptargetlist | sort -u > $TARGETS_DIR/targetlist.txt
echo "[+] Removing tmptargetlist" 
	rm $TARGETS_DIR/tmptargetlist
echo "[-] Done creating Target List"

#################################
# Scan Targets List for SNMP	#
#################################
echo "[+] Scanning list for public SNMP communities..."
	$ONESIXTYONE -i $TARGETS_DIR/targetlist.txt | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' >> $SERVICES_DIR/SNMP
echo "[-] Done scanning public snmp communities"


###############################
# Ok, let's do the NMAP files #
###############################
echo "[+]  Performing nmap scan...."
	nmap -p445,135,139,139,137,3389,389,636,53,67,123,161,21,25,110,143,80,443,8080,111,23,22,9100,5900,1433,1521,3306 -PN -sSU -sV --script=exploit,external,vuln,auth,default -O -oG $TARGETS_DIR/scan.txt -iL $TARGETS_DIR/targetlist.txt >> $TARGETS_DIR/targetscanvuln.txt
echo "[+] Generating Report.txt...."

#Cleans up scan output
	grep -v ^# $TARGETS_DIR/scan.txt > $TARGETS_DIR/report.txt
echo "[+] Performing Nikto Scan from Greppable Nmap results..."
	$NIKTO -h $TARGETS_DIR/scan.txt -o $TARGETS_DIR/webapps -Format csv >> $TARGETS_DIR/niktoscan.txt
echo "[-] "
echo "[|] "
echo "[-] Done, now check your results."
