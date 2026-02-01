#!/bin/bash
# =================================================
# Developed by Ali Nezamifar | Powered by Bia2Host.Com
# =================================================

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# ASCII Art Banner
echo -e "${CYAN}"
cat << "EOF"
██████╗ ██╗ █████╗ ██████╗ ██╗  ██╗ ██████╗ ███████╗████████╗
██╔══██╗██║██╔══██╗╚════██╗██║  ██║██╔═══██╗██╔════╝╚══██╔══╝
██████╔╝██║███████║ █████╔╝███████║██║   ██║███████╗   ██║   
██╔══██╗██║██╔══██║██╔═══╝ ██╔══██║██║   ██║╚════██║   ██║   
██████╔╝██║██║  ██║███████╗██║  ██║╚██████╔╝███████║   ██║   
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   

   Developed by Ali Nezamifar
   Powered by Bia2Host.Com
EOF
echo -e "${NC}"

# DNS servers list
SERVERS="217.218.155.155 185.20.163.4 78.157.42.101 31.24.234.37 2.189.44.44 185.20.163.2 194.60.210.66 217.218.127.127 2.188.21.130 31.24.200.4 2.185.239.138 5.145.112.39 85.185.85.6 217.219.132.88 178.22.122.100 194.36.174.1 185.53.143.3 80.191.209.105 78.157.42.100 213.176.123.5 185.55.226.26 185.161.112.38 194.225.152.10 2.188.21.131 2.188.21.132 10.202.10.10 46.224.1.42 8.8.8.8 8.8.4.4 1.1.1.1 1.0.0.1 9.9.9.9 149.112.112.112"

TEST_DOMAIN="google.com"
OK_SERVERS=()
MAX_OK=5

# Clear existing resolv.conf
echo -n > /etc/resolv.conf

# Test DNS servers
for DNS in $SERVERS; do
  if dig @"$DNS" "$TEST_DOMAIN" +time=1 +short > /dev/null 2>&1; then
    echo -e "${GREEN}[OK]${NC} $DNS"
    OK_SERVERS+=("$DNS")
  else
    echo -e "${RED}[FAIL]${NC} $DNS"
  fi

  # Stop after finding enough working servers
  if [ "${#OK_SERVERS[@]}" -ge "$MAX_OK" ]; then
    break
  fi
done

# Write working DNS servers to resolv.conf
for DNS in "${OK_SERVERS[@]}"; do
  echo "nameserver $DNS" >> /etc/resolv.conf
done

echo -e "\n✅ Updated /etc/resolv.conf with ${#OK_SERVERS[@]} working nameservers."
