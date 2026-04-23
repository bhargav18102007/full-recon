#!/bin/bash

# 🔍 ADVANCED BUG BOUNTY RECONNAISSANCE SCRIPT
# Enhanced for ethical web application security testing

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
    echo "Usage: $0 <domain or IP>"
    echo "Example: $0 example.com"
    exit 1
fi

# Setup logging
LOG_DIR="/root/Desktop/${TARGET}_bugbounty_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOG_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_msg() {
    echo -e "${GREEN}[+]${NC} $1"
}

error_msg() {
    echo -e "${RED}[-]${NC} $1"
}

warn_msg() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_msg "Starting Advanced Bug Bounty Scan for: $TARGET"
log_msg "Output Directory: $LOG_DIR"

# ============================================
# 1️⃣ SUBDOMAIN ENUMERATION
# ============================================
log_msg "Starting Subdomain Enumeration..."

# Create subdomain directory
mkdir -p "$LOG_DIR/subdomains"

# Using subfinder
if command -v subfinder &> /dev/null; then
    log_msg "Running subfinder..."
    subfinder -d "$TARGET" -o "$LOG_DIR/subdomains/subfinder.txt" -silent 2>/dev/null
    cat "$LOG_DIR/subdomains/subfinder.txt" 2>/dev/null >> "$LOG_DIR/subdomains/all_subdomains.txt"
else
    warn_msg "subfinder not installed. Install: go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
fi

# Using assetfinder
if command -v assetfinder &> /dev/null; then
    log_msg "Running assetfinder..."
    assetfinder --subs-only "$TARGET" > "$LOG_DIR/subdomains/assetfinder.txt" 2>/dev/null
    cat "$LOG_DIR/subdomains/assetfinder.txt" >> "$LOG_DIR/subdomains/all_subdomains.txt" 2>/dev/null
else
    warn_msg "assetfinder not installed"
fi

# Remove duplicates
if [ -f "$LOG_DIR/subdomains/all_subdomains.txt" ]; then
    sort -u "$LOG_DIR/subdomains/all_subdomains.txt" > "$LOG_DIR/subdomains/unique_subdomains.txt"
    log_msg "Found $(wc -l < $LOG_DIR/subdomains/unique_subdomains.txt) unique subdomains"
else
    echo "$TARGET" > "$LOG_DIR/subdomains/unique_subdomains.txt"
fi

# ============================================
# 2️⃣ LIVE HOST DETECTION
# ============================================
log_msg "Detecting Live Hosts..."
mkdir -p "$LOG_DIR/hosts"

if command -v httpx &> /dev/null; then
    log_msg "Running httpx for live host detection..."
    cat "$LOG_DIR/subdomains/unique_subdomains.txt" | httpx -status-code -title -o "$LOG_DIR/hosts/live_hosts.txt" -rate-limit 50 2>/dev/null
    log_msg "Live hosts found: $(wc -l < $LOG_DIR/hosts/live_hosts.txt)"
else
    warn_msg "httpx not installed. Install: go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
    # Fallback to curl
    while IFS= read -r domain; do
        curl -s -o /dev/null -w "$domain - %{http_code}\n" "http://$domain" >> "$LOG_DIR/hosts/live_hosts.txt" 2>/dev/null &
        sleep 0.2
    done < "$LOG_DIR/subdomains/unique_subdomains.txt"
fi

# ============================================
# 3️⃣ PORT SCANNING
# ============================================
log_msg "Running Port Scans..."
mkdir -p "$LOG_DIR/ports"

# Get unique IPs for port scanning
if [ -f "$LOG_DIR/hosts/live_hosts.txt" ]; then
    cat "$LOG_DIR/hosts/live_hosts.txt" | cut -d' ' -f1 | sort -u > "$LOG_DIR/ports/targets_for_nmap.txt"
    
    if command -v nmap &> /dev/null; then
        log_msg "Running nmap on live hosts..."
        nmap -sV -sC -p 80,443,8080,8443,3000,5000,9000 --min-rate 1000 -iL "$LOG_DIR/ports/targets_for_nmap.txt" -oA "$LOG_DIR/ports/nmap_scan" 2>/dev/null
    fi
fi

# ============================================
# 4️⃣ DIRECTORY BRUTEFORCE
# ============================================
log_msg "Starting Directory Bruteforce..."
mkdir -p "$LOG_DIR/directories"

if [ -f "$LOG_DIR/hosts/live_hosts.txt" ]; then
    while IFS= read -r line; do
        url=$(echo "$line" | awk '{print $1}')
        if command -v dirsearch &> /dev/null; then
            log_msg "Bruteforcing directories on $url"
            dirsearch -u "$url" -o "$LOG_DIR/directories/$(echo $url | tr ':/' '_').txt" --format txt -q --rate-limit 50 2>/dev/null &
        fi
    done < "$LOG_DIR/hosts/live_hosts.txt"
fi

wait

# ============================================
# 5️⃣ JAVASCRIPT FILE ANALYSIS
# ============================================
log_msg "Analyzing JavaScript Files..."
mkdir -p "$LOG_DIR/javascript"

if [ -f "$LOG_DIR/hosts/live_hosts.txt" ]; then
    while IFS= read -r line; do
        url=$(echo "$line" | awk '{print $1}')
        if command -v getJS &> /dev/null; then
            log_msg "Extracting JS from $url"
            echo "$url" | getJS --complete 2>/dev/null > "$LOG_DIR/javascript/$(echo $url | tr ':/' '_')_js.txt"
        else
            # Fallback with curl
            curl -s "$url" | grep -oP '(?:src=|href=)["\']?[^"\''>\s]+\.js["\''>\s]?' >> "$LOG_DIR/javascript/$(echo $url | tr ':/' '_')_js.txt" 2>/dev/null
        fi
    done < "$LOG_DIR/hosts/live_hosts.txt"
fi

# ============================================
# 6️⃣ URL COLLECTION (for XSS, SQLi, etc.)
# ============================================
log_msg "Collecting URLs for Vulnerability Testing..."
mkdir -p "$LOG_DIR/urls"

if [ -f "$LOG_DIR/hosts/live_hosts.txt" ]; then
    while IFS= read -r line; do
        url=$(echo "$line" | awk '{print $1}')
        if command -v waybackurls &> /dev/null; then
            log_msg "Collecting URLs from Wayback Machine for $url"
            echo "$url" | waybackurls 2>/dev/null > "$LOG_DIR/urls/$(echo $url | tr ':/' '_')_wayback.txt"
        fi
    done < "$LOG_DIR/hosts/live_hosts.txt"
fi

# ============================================
# 7️⃣ SSL/TLS CERTIFICATE ANALYSIS
# ============================================
log_msg "Analyzing SSL/TLS Certificates..."
mkdir -p "$LOG_DIR/ssl"

if [ -f "$LOG_DIR/hosts/live_hosts.txt" ]; then
    while IFS= read -r line; do
        domain=$(echo "$line" | awk '{print $1}' | cut -d':' -f1)
        echo "=== Certificate for $domain ===" >> "$LOG_DIR/ssl/certificates.txt"
        echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | openssl x509 -noout -text 2>/dev/null >> "$LOG_DIR/ssl/certificates.txt"
        echo -e "\n" >> "$LOG_DIR/ssl/certificates.txt"
    done < "$LOG_DIR/hosts/live_hosts.txt"
fi

# ============================================
# 8️⃣ HTTP SECURITY HEADERS CHECK
# ============================================
log_msg "Checking HTTP Security Headers..."
mkdir -p "$LOG_DIR/security_headers"

if [ -f "$LOG_DIR/hosts/live_hosts.txt" ]; then
    while IFS= read -r line; do
        url=$(echo "$line" | awk '{print $1}')
        echo "=== Security Headers for $url ===" >> "$LOG_DIR/security_headers/headers.txt"
        curl -s -I "$url" | grep -iE "(Content-Security-Policy|X-Frame-Options|X-Content-Type-Options|Strict-Transport-Security|X-XSS-Protection)" >> "$LOG_DIR/security_headers/headers.txt" 2>/dev/null || echo "Missing security headers" >> "$LOG_DIR/security_headers/headers.txt"
        echo -e "\n" >> "$LOG_DIR/security_headers/headers.txt"
    done < "$LOG_DIR/hosts/live_hosts.txt"
fi

# ============================================
# 9️⃣ NUCLEI VULNERABILITY SCANNING (⭐ MOST IMPORTANT)
# ============================================
log_msg "Running Nuclei Templates (Advanced Vulnerability Scanning)..."
mkdir -p "$LOG_DIR/nuclei"

if command -v nuclei &> /dev/null; then
    if [ -f "$LOG_DIR/hosts/live_hosts.txt" ]; then
        cat "$LOG_DIR/hosts/live_hosts.txt" | awk '{print $1}' > "$LOG_DIR/nuclei/targets.txt"
        log_msg "Running Nuclei with rate limiting..."
        nuclei -l "$LOG_DIR/nuclei/targets.txt" -o "$LOG_DIR/nuclei/vulnerabilities.txt" -rate-limit 50 -c 10 -silent 2>/dev/null
        log_msg "Vulnerabilities found: $(wc -l < $LOG_DIR/nuclei/vulnerabilities.txt 2>/dev/null || echo 0)"
    fi
else
    error_msg "nuclei not installed. Install: go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
fi

# ============================================
# 🔟 TECHNOLOGY DETECTION
# ============================================
log_msg "Detecting Web Technologies..."
mkdir -p "$LOG_DIR/technologies"

if [ -f "$LOG_DIR/hosts/live_hosts.txt" ]; then
    while IFS= read -r line; do
        url=$(echo "$line" | awk '{print $1}')
        if command -v whatweb &> /dev/null; then
            log_msg "Analyzing $url"
            whatweb "$url" >> "$LOG_DIR/technologies/technologies.txt" 2>/dev/null
        fi
    done < "$LOG_DIR/hosts/live_hosts.txt"
fi

# ============================================
# SUMMARY REPORT
# ============================================
log_msg "Generating Summary Report..."

cat > "$LOG_DIR/REPORT_SUMMARY.txt" << EOF
╔════════════════════════════════════════════════════════════╗
║        BUG BOUNTY RECONNAISSANCE REPORT                    ║
╚════════════════════════════════════════════════════════════╝

Target: $TARGET
Scan Date: $(date)
Output Directory: $LOG_DIR

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 SCAN RESULTS:

✓ Subdomains Found: $([ -f "$LOG_DIR/subdomains/unique_subdomains.txt" ] && wc -l < "$LOG_DIR/subdomains/unique_subdomains.txt" || echo "0")
✓ Live Hosts: $([ -f "$LOG_DIR/hosts/live_hosts.txt" ] && wc -l < "$LOG_DIR/hosts/live_hosts.txt" || echo "0")
✓ Directories Found: $(find "$LOG_DIR/directories" -type f -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
✓ Nuclei Vulnerabilities: $([ -f "$LOG_DIR/nuclei/vulnerabilities.txt" ] && wc -l < "$LOG_DIR/nuclei/vulnerabilities.txt" || echo "0")

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 OUTPUT FILES:

📂 subdomains/
   - unique_subdomains.txt        (All unique subdomains)
   
📂 hosts/
   - live_hosts.txt               (Live web hosts)
   
📂 ports/
   - nmap_scan.xml/.txt           (Open ports)
   
📂 directories/
   - *_directories.txt            (Bruteforced directories)
   
📂 javascript/
   - *_js.txt                     (JavaScript files)
   
📂 urls/
   - *_wayback.txt                (URLs for testing)
   
📂 nuclei/
   - vulnerabilities.txt          (⭐ VULNERABILITIES FOUND)
   
📂 security_headers/
   - headers.txt                  (Missing security headers)
   
📂 ssl/
   - certificates.txt             (SSL/TLS details)
   
📂 technologies/
   - technologies.txt             (Tech stack detected)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔐 RECOMMENDATIONS:

1. Review NUCLEI vulnerabilities first (most_accurate)
2. Check missing security headers
3. Test URLs from wayback for XSS/SQLi
4. Analyze JavaScript for exposed credentials/endpoints
5. Test discovered directories for hidden functionality
6. Check SSL certificate for expiration/misconfiguration

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

log_msg "=========================================="
log_msg "✅ SCAN COMPLETE!"
log_msg "📁 Results saved in: $LOG_DIR"
log_msg "📄 Summary: $LOG_DIR/REPORT_SUMMARY.txt"
log_msg "=========================================="

# Display summary
cat "$LOG_DIR/REPORT_SUMMARY.txt"
