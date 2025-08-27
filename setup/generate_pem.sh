# this script will generate pem files for the openssh-server
# it will saved keys in keys folder and also add in authorized_keys
# I am using it to access my home server using keys instead of passwords 

#!/bin/bash
OUTPUT_DIR="keys"
COUNT=${1:-1}    # Number of PEM files (default = 1)
BITS=4096        # RSA key size
AUTH_KEYS="$HOME/.ssh/authorized_keys"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$HOME/.ssh"
touch "$AUTH_KEYS"
chmod 600 "$AUTH_KEYS"

for i in $(seq 1 $COUNT); do
    KEY_FILE="$OUTPUT_DIR/key-$i.pem"
    PUB_FILE="$KEY_FILE.pub"

    echo "[*] Generating $KEY_FILE ..."

    # Generate private key in PEM format
    ssh-keygen -t rsa -b $BITS -m PEM -f "$KEY_FILE" -N "" >/dev/null

    # Append public key to authorized_keys if not already present
    if ! grep -q -f "$PUB_FILE" "$AUTH_KEYS"; then
        cat "$PUB_FILE" >> "$AUTH_KEYS"
        echo "    → Public key appended to $AUTH_KEYS"
    else
        echo "    → Public key already exists in $AUTH_KEYS"
    fi

    echo "    - Private key: $KEY_FILE"
    echo "    - Public key : $PUB_FILE"
    echo
done

chmod 700 "$HOME/.ssh"
chmod 600 "$AUTH_KEYS"

echo "[✔] $COUNT PEM key(s) generated in $OUTPUT_DIR/ and added to $AUTH_KEYS"
