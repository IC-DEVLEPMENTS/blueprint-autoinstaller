#!/bin/bash
# Blueprint Installation Script for Pterodactyl Panel
# Usage: sudo bash install_blueprint.sh  /var/www/pterodactyl/

set -e

# --- IC Developments Animated Credit ---
IC_ASCII=$(cat <<'EOF'
\033[1;36m
   _____ _____     _           _           _   _                 _       _            
  |_   _|_   _|_ _| |__   ___ | | ___  ___| |_(_) ___  _ __  ___| | __ _| |_ ___  _ __ 
    | |   | |/ _` | '_ \ / _ \| |/ _ \/ __| __| |/ _ \| '_ \/ __| |/ _` | __/ _ \| '__|
    | |   | | (_| | |_) | (_) | |  __/ (__| |_| | (_) | | | \__ \ | (_| | || (_) | |   
    |_|   |_|\__,_|_.__/ \___/|_|\___|\___|\__|_|\___/|_| |_|___/_|\__,_|\__\___/|_|   
\033[0m
EOF
)

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ -d /proc/$pid ]; do
        local temp=${spinstr#?}
        printf "  [\033[1;33m%c\033[0m] IC Developments initializing...\r" "$spinstr"
        spinstr=$temp${spinstr%$temp}
        sleep $delay
    done
    printf "    \r"
}

# Show ASCII art
clear
printf "%b\n" "$IC_ASCII"
(sleep 2) & spinner $!
echo "\033[1;32mPowered by IC Developments\033[0m"
sleep 1


# Set default Pterodactyl path
PTERODACTYL_DIR="/var/www/pterodactyl/"
if [ -n "$1" ]; then
  PTERODACTYL_DIR="$1"
fi

echo "Using Pterodactyl directory: $PTERODACTYL_DIR"

# 1. Install Node.js v20+
echo "Installing Node.js v20+..."
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update
sudo apt-get install -y nodejs

# 2. Install Yarn
echo "Installing Yarn..."
sudo npm i -g yarn

# 3. Install additional dependencies
echo "Installing additional dependencies..."
sudo apt install -y zip unzip git curl wget

# 4. Initialize dependencies in Pterodactyl directory
echo "Running yarn in $PTERODACTYL_DIR..."
cd "$PTERODACTYL_DIR"
yarn

# 5. Download latest Blueprint release
echo "Downloading Blueprint release..."
wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip

# 6. Unarchive release
unzip -o release.zip

# 7. Create .blueprintrc file
echo "Creating .blueprintrc..."
touch "$PTERODACTYL_DIR/.blueprintrc"
echo 'WEBUSER="www-data";
OWNERSHIP="www-data:www-data";
USERSHELL="/bin/bash";' > "$PTERODACTYL_DIR/.blueprintrc"

# 8. Make blueprint.sh executable and run it
echo "Running blueprint.sh..."
chmod +x "$PTERODACTYL_DIR/blueprint.sh"
bash "$PTERODACTYL_DIR/blueprint.sh"

echo "Blueprint installation complete! To verify, run: blueprint -help"
