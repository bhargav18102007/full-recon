# 🔍 full-recon

**Advanced Bug Bounty Reconnaissance Script for Ethical Security Testing**

A comprehensive automation tool designed for security researchers and bug bounty hunters to conduct full-stack reconnaissance on target domains.

---

## ✨ Features

- 🔎 **Subdomain Enumeration** - Automated discovery using subfinder & assetfinder
- 🌐 **Live Host Detection** - Identify active web services with httpx
- 📂 **Directory Bruteforce** - Discover hidden directories and endpoints
- 🔤 **JavaScript Analysis** - Extract and analyze JS files for secrets/endpoints
- 📋 **URL Collection** - Gather URLs from Wayback Machine for testing
- 🔐 **SSL/TLS Certificate Analysis** - Certificate validity, issuer, key information
- 📊 **HTTP Security Headers Check** - Detect missing security headers
- ⭐ **Nuclei Vulnerability Scanning** - Advanced vulnerability detection (MOST IMPORTANT)
- 🛠️ **Technology Detection** - Identify web technologies and frameworks
- 🔌 **Port Scanning** - Comprehensive nmap scanning on live hosts
- 📈 **Comprehensive Reporting** - Auto-generated summary with organized outputs

---

## 🚀 Quick Start

### Basic Usage
```bash
./full-recon.sh example.com
```

### Output
Results are saved in:
```
/root/Desktop/{domain}_bugbounty_TIMESTAMP/
```

---

## 📋 Prerequisites

### Install Required Tools

#### Go-based Tools
```bash
# Install Go first (if not installed)
# Download from https://golang.org/dl/

# Then install:
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install -v github.com/tomnomnom/assetfinder@latest

# Add Go bin to PATH
export PATH=$PATH:~/go/bin
```

#### System Packages
```bash
sudo apt update
sudo apt install -y nmap dirsearch whatweb curl openssl git
```

#### Python Tools (Optional)
```bash
pip install waybackurls
```

---

## 📖 Installation

### Clone the Repository
```bash
git clone https://github.com/bhargav18102007/full-recon.git
cd full-recon
```

### Make Script Executable
```bash
chmod +x full-recon.sh
```

### Run the Script
```bash
./full-recon.sh example.com
```

---

## 🎯 Usage Examples

### Scan a Domain
```bash
./full-recon.sh google.com
```

### Scan a Specific Subdomain
```bash
./full-recon.sh api.example.com
```

### Scan Local IP (for authorized testing)
```bash
./full-recon.sh 192.168.1.1
```

---

## 📁 Output Structure

```
/root/Desktop/{domain}_bugbounty_TIMESTAMP/
├── REPORT_SUMMARY.txt          # 📄 Main summary report
├── subdomains/
│   ├── subfinder.txt
│   ├── assetfinder.txt
│   └── unique_subdomains.txt   # All unique subdomains
├── hosts/
│   └── live_hosts.txt          # Active web services
├── ports/
│   ├── nmap_scan.xml
│   ├── nmap_scan.txt
│   └── targets_for_nmap.txt
├── directories/
│   └── *_directories.txt       # Bruteforced paths
├── javascript/
│   └── *_js.txt                # JS files found
├── urls/
│   └── *_wayback.txt           # Historical URLs
├── nuclei/
│   ├── targets.txt
│   └── vulnerabilities.txt     # ⭐ VULNERABILITIES FOUND
├── security_headers/
│   └── headers.txt             # Missing security headers
├── ssl/
│   └── certificates.txt        # SSL/TLS certificate details
└── technologies/
    └── technologies.txt        # Detected tech stack
```

---

## 🔍 Workflow

1. **Subdomain Discovery** → Finds all subdomains
2. **Live Host Detection** → Identifies active services
3. **Port Scanning** → Maps open ports
4. **Directory Bruteforce** → Discovers hidden endpoints
5. **JS Analysis** → Extracts code & potential secrets
6. **URL Collection** → Gathers historical URLs
7. **SSL Analysis** → Checks certificates
8. **Security Headers** → Identifies missing protections
9. **Nuclei Scanning** → Detects vulnerabilities (⭐ MOST IMPORTANT)
10. **Tech Detection** → Identifies frameworks & libraries
11. **Report Generation** → Creates comprehensive summary

---

## ⚠️ Important Notes

### Rate Limiting
- Script includes rate limiting (50-100 req/sec) to avoid detection
- Adjust `--rate-limit` values in the script if needed
- **Always follow target's robots.txt and terms of service**

### Legal & Ethical
- ✅ Use only on authorized targets
- ✅ Follow bug bounty program scope
- ✅ Respect legal boundaries
- ❌ Do NOT scan without permission
- ❌ Do NOT perform attacks outside authorized testing

### Nuclei Templates
- Download latest templates for best results:
```bash
nuclei -update-templates
```

---

## 🛠️ Troubleshooting

### Command Not Found
```bash
export PATH=$PATH:~/go/bin
# Add to ~/.bashrc or ~/.zshrc for permanent fix
```

### Permission Denied
```bash
chmod +x full-recon.sh
```

### Tools Not Installing
```bash
# Check Go installation
go version

# Check PATH
echo $PATH

# Verify installation
which nuclei
which httpx
```

### Port Already in Use
- Script may need elevated privileges for certain scans
```bash
sudo ./full-recon.sh example.com
```

---

## 🎓 Learn More

- [Nuclei Documentation](https://docs.projectdiscovery.io/tools/nuclei/)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [HackerOne Bug Bounty](https://www.hackerone.com/)
- [Bug Bounty Tips](https://www.bugcrowd.com/)

---

## 📝 License

MIT License - See LICENSE file for details

---

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

---

## 👤 Author

**Bhargav** - [GitHub Profile](https://github.com/bhargav18102007/)

---

## ⭐ Support

If you found this tool helpful, please give it a star! ⭐

---

## 📧 Contact

For questions or feedback, feel free to reach out!

---

**Happy Hunting! 🎯**

*Remember: Always test ethically and with proper authorization.*
