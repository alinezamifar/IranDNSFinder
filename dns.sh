#!/bin/bash
# =================================================
# IranDNSFinder
# Developed by Ali Nezamifar | Powered by Bia2Host.Com
# =================================================

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
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

# Check for root privileges
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo -e "${RED}[ERROR] This script requires root privileges to modify /etc/resolv.conf.${NC}"
  echo -e "Please run with sudo: ${CYAN}sudo bash $0${NC}\n"
  exit 1
fi

# Ensure 'dig' is installed, or try to install it
ensure_dig() {
  if command -v dig &>/dev/null; then
    return 0
  fi

  echo -e "${YELLOW}[!] 'dig' command not found. Attempting to install required packages...${NC}"

  if command -v apt-get &>/dev/null; then
    DEBIAN_FRONTEND=noninteractive apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y dnsutils
  elif command -v dnf &>/dev/null; then
    dnf install -y bind-utils
  elif command -v yum &>/dev/null; then
    yum install -y bind-utils
  elif command -v pacman &>/dev/null; then
    pacman -Sy --noconfirm bind
  elif command -v zypper &>/dev/null; then
    zypper --non-interactive install bind-utils
  elif command -v apk &>/dev/null; then
    apk add --no-cache bind-tools
  else
    echo -e "${RED}[ERROR] Package manager not recognized.${NC}"
  fi

  if ! command -v dig &>/dev/null; then
    echo -e "\n${RED}===================================================================${NC}"
    echo -e "${RED}[ERROR] 'dig' is not installed and could not be installed automatically.${NC}"
    echo -e "${RED}Please install 'dnsutils' (Debian/Ubuntu) or 'bind-utils' (CentOS/RHEL) manually.${NC}"
    echo -e "${YELLOW}Safety Notice: /etc/resolv.conf was NOT modified.${NC}"
    echo -e "${RED}===================================================================${NC}\n"
    exit 1
  fi

  echo -e "${GREEN}[OK] 'dig' installed successfully.${NC}\n"
}

ensure_dig

# Configuration
TEST_DOMAIN="${TEST_DOMAIN:-google.com}"
MAX_SERVERS=4

# Comprehensive DNS list (International & Iranian)
DNS_SERVERS=(
  # International / Global DNS
  "1.1.1.1:Cloudflare"
  "1.0.0.1:Cloudflare"
  "8.8.8.8:Google"
  "8.8.4.4:Google"
  "9.9.9.9:Quad9"
  "149.112.112.112:Quad9"
  "208.67.222.222:OpenDNS"
  "208.67.220.220:OpenDNS"
  "94.140.14.14:AdGuard"
  "94.140.15.15:AdGuard"
  "76.76.2.0:ControlD"
  "76.76.10.0:ControlD"
  "84.200.69.80:DNS.WATCH"
  "84.200.70.40:DNS.WATCH"
  "4.2.2.1:Level3"
  "4.2.2.2:Level3"
  "4.2.2.4:Level3"
  "8.26.56.26:Comodo"

  # Iranian Anti-Sanction & Public DNS
  "178.22.122.100:Shecan"
  "185.51.200.2:Shecan"
  "185.55.226.26:Begzar"
  "185.55.225.25:Begzar"
  "78.157.42.100:Electro"
  "78.157.42.101:Electro"
  "10.202.10.202:403.online"
  "10.202.10.102:403.online"
  "10.202.10.10:RadarGame"
  "10.202.10.11:RadarGame"

  # Iranian Infrastructure & Datacenters / ISPs
  "217.218.155.155:IR-TIC"
  "217.218.127.127:IR-TIC"
  "217.219.132.88:IR-TIC"
  "185.20.163.4:IR-ISP"
  "185.20.163.2:IR-ISP"
  "31.24.234.37:IR-ISP"
  "31.24.200.4:IR-ISP"
  "2.189.44.44:IR-ISP"
  "194.60.210.66:IR-ISP"
  "2.188.21.130:IR-ISP"
  "2.188.21.131:IR-ISP"
  "2.188.21.132:IR-ISP"
  "2.185.239.138:IR-ISP"
  "5.145.112.39:IR-ISP"
  "85.185.85.6:IR-ISP"
  "194.36.174.1:IR-ISP"
  "185.53.143.3:IR-ISP"
  "80.191.209.105:IR-ISP"
  "213.176.123.5:IR-ISP"
  "185.161.112.38:IR-ISP"
  "194.225.152.10:IR-ISP"
  "46.224.1.42:IR-ISP"
)

TOTAL_COUNT="${#DNS_SERVERS[@]}"
echo -e "${CYAN}🔍 Testing ${TOTAL_COUNT} DNS servers (Domestic & International) against '${TEST_DOMAIN}'...${NC}\n"

TMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'dnscheck')
trap 'rm -rf "$TMP_DIR"' EXIT

# Test single DNS server in background
test_single_dns() {
  local ip="$1"
  local label="$2"
  local outfile="$3"

  local dig_output
  dig_output=$(dig @"$ip" "$TEST_DOMAIN" +time=1 +tries=1 +stats 2>&1)
  local exit_code=$?

  if [ $exit_code -eq 0 ] && echo "$dig_output" | grep -q "status: NOERROR"; then
    local lat
    lat=$(echo "$dig_output" | sed -n 's/.*Query time: \([0-9]\+\) msec.*/\1/p')
    if [ -n "$lat" ]; then
      echo "OK:$lat:$ip:$label" > "$outfile"
      return 0
    fi
  fi

  echo "FAIL:999999:$ip:$label" > "$outfile"
  return 1
}

# Run tests in parallel
pids=()
idx=0
for entry in "${DNS_SERVERS[@]}"; do
  ip="${entry%%:*}"
  label="${entry#*:}"
  res_file="$TMP_DIR/res_${idx}"
  test_single_dns "$ip" "$label" "$res_file" &
  pids+=($!)
  ((idx++))
done

# Wait for all background tests to finish
for pid in "${pids[@]}"; do
  wait "$pid" 2>/dev/null
done

# Collect and display individual results
OK_RESULTS=()
idx=0
for entry in "${DNS_SERVERS[@]}"; do
  res_file="$TMP_DIR/res_${idx}"
  ((idx++))
  [ ! -f "$res_file" ] && continue

  line=$(cat "$res_file")
  status=$(echo "$line" | cut -d: -f1)
  latency=$(echo "$line" | cut -d: -f2)
  ip=$(echo "$line" | cut -d: -f3)
  label=$(echo "$line" | cut -d: -f4)

  if [ "$status" = "OK" ]; then
    printf "${GREEN}[OK]${NC}   %-16s (%4s ms)  [%s]\n" "$ip" "$latency" "$label"
    OK_RESULTS+=("${latency}:${ip}:${label}")
  else
    printf "${RED}[FAIL]${NC} %-16s             [%s]\n" "$ip" "$label"
  fi
done

# Validate results
if [ "${#OK_RESULTS[@]}" -eq 0 ]; then
  echo -e "\n${RED}===================================================================${NC}"
  echo -e "${RED}⚠️  No working DNS servers found!${NC}"
  echo -e "${YELLOW}Safety Notice: /etc/resolv.conf was NOT modified to prevent breaking DNS.${NC}"
  echo -e "${YELLOW}Please check your network connection and try again.${NC}"
  echo -e "${RED}===================================================================${NC}\n"
  exit 1
fi

# Sort by latency (lowest first)
IFS=$'\n' sorted=($(sort -t: -k1,1n <<<"${OK_RESULTS[*]}"))
unset IFS

# Display top selected DNS servers
echo -e "\n${BOLD}${CYAN}=================================================${NC}"
echo -e "${BOLD}${CYAN}          Top Fastest Working DNS Servers        ${NC}"
echo -e "${BOLD}${CYAN}=================================================${NC}"

SELECTED_IPS=()
count=0
for entry in "${sorted[@]}"; do
  [ "$count" -ge "$MAX_SERVERS" ] && break
  lat=$(echo "$entry" | cut -d: -f1)
  ip=$(echo "$entry" | cut -d: -f2)
  label=$(echo "$entry" | cut -d: -f3)
  count=$((count + 1))
  printf "${BOLD}%d.${NC} %-16s (%4s ms)  [%s]\n" "$count" "$ip" "$lat" "$label"
  SELECTED_IPS+=("$ip")
done
echo -e "${BOLD}${CYAN}=================================================${NC}\n"

# Backup existing resolv.conf
if [ -f /etc/resolv.conf ]; then
  BACKUP_FILE="/etc/resolv.conf.bak-$(date +%Y%m%d%H%M%S)"
  cp -L /etc/resolv.conf "$BACKUP_FILE" 2>/dev/null || true
  echo -e "${CYAN}📁 Backup of current config saved to: ${BACKUP_FILE}${NC}"
fi

# Safely write new resolv.conf
RESOLV_TMP=$(mktemp)
cat << 'HEADER' > "$RESOLV_TMP"
# =================================================
# Generated by IranDNSFinder
# Developed by Ali Nezamifar | Powered by Bia2Host.Com
# =================================================
options timeout:2 attempts:2
HEADER

for ip in "${SELECTED_IPS[@]}"; do
  echo "nameserver $ip" >> "$RESOLV_TMP"
done

cat "$RESOLV_TMP" > /etc/resolv.conf
rm -f "$RESOLV_TMP"

echo -e "${GREEN}✅ Updated /etc/resolv.conf with ${#SELECTED_IPS[@]} fastest working nameservers.${NC}\n"
