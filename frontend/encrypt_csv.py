#!/usr/bin/env python3
"""
HulyPay - Selective Column CSV Encryptor / Decryptor
====================================================
Uses AES-256-GCM (via Python's built-in standard library or 'cryptography')
to encrypt specific sensitive columns in CSV files before merging/importing into Supabase.

Columns considered sensitive (PII / Financial identifiers):
- upi_id (e.g. user@okhdfcbank)
- upi_transaction_id / transaction_reference
- description / notes
- user_phone / account_number (if present)

Columns kept in plain text (Needed for SQL WHERE, aggregate charts, and joins):
- id (UUID)
- user_id (UUID needed for RLS / auth filtering)
- amount (Decimal needed for SUM, AVG, and totals)
- currency (INR, USD)
- category (e.g., Food, Travel, Cloud)
- status (SETTLED, COMPLETED, PENDING)
- transaction_time / created_at (ISO timestamp for timeline sorting)
"""

import os
import sys
import csv
import base64
import argparse
import hashlib
import secrets

# Try using 'cryptography' library if installed, otherwise fallback to built-in hashlib + AES or pure Python
try:
    from cryptography.hazmat.primitives.ciphers.aead import AESGCM
    HAS_CRYPTOGRAPHY = True
except ImportError:
    HAS_CRYPTOGRAPHY = False


# Default sensitive columns to encrypt
DEFAULT_SENSITIVE_COLUMNS = {
    "upi_id",
    "upi_transaction_id",
    "transaction_reference",
    "description",
    "phone_number",
    "bank_account",
}


def derive_key(secret_passphrase: str, salt: bytes = b"hulypay_salt_v1") -> bytes:
    """Derive a 256-bit (32 bytes) key using PBKDF2 HMAC-SHA256."""
    return hashlib.pbkdf2_hmac("sha256", secret_passphrase.encode("utf-8"), salt, 100000, dklen=32)


def encrypt_value_gcm(value: str, key: bytes) -> str:
    """Encrypt a string value using AES-256-GCM, returning base64 string."""
    if not value or value.strip() == "":
        return value

    data = value.encode("utf-8")

    if HAS_CRYPTOGRAPHY:
        aesgcm = AESGCM(key)
        nonce = secrets.token_bytes(12)  # 96-bit nonce for GCM
        ciphertext = aesgcm.encrypt(nonce, data, None)
        # Store as base64: nonce + ciphertext
        return "enc:" + base64.b64encode(nonce + ciphertext).decode("ascii")
    else:
        # Fallback pure-standard-library XOR stream cipher + HMAC if cryptography is not installed
        nonce = secrets.token_bytes(16)
        # Derive keystream with SHA256 blocks
        keystream = b""
        block_idx = 0
        while len(keystream) < len(data):
            keystream += hashlib.sha256(key + nonce + block_idx.to_bytes(4, "big")).digest()
            block_idx += 1
        cipher_bytes = bytes(b ^ k for b, k in zip(data, keystream[:len(data)]))
        tag = hashlib.sha256(key + nonce + cipher_bytes).digest()[:16]
        return "enc:" + base64.b64encode(nonce + tag + cipher_bytes).decode("ascii")


def decrypt_value_gcm(encrypted_str: str, key: bytes) -> str:
    """Decrypt a base64 string back to original plain text."""
    if not encrypted_str or not encrypted_str.startswith("enc:"):
        return encrypted_str

    raw = base64.b64decode(encrypted_str[4:].encode("ascii"))

    if HAS_CRYPTOGRAPHY:
        nonce = raw[:12]
        ciphertext = raw[12:]
        aesgcm = AESGCM(key)
        decrypted = aesgcm.decrypt(nonce, ciphertext, None)
        return decrypted.decode("utf-8")
    else:
        nonce = raw[:16]
        tag = raw[16:32]
        cipher_bytes = raw[32:]
        expected_tag = hashlib.sha256(key + nonce + cipher_bytes).digest()[:16]
        if not secrets.compare_digest(tag, expected_tag):
            raise ValueError("Integrity check failed: corrupted or wrong key")
        keystream = b""
        block_idx = 0
        while len(keystream) < len(cipher_bytes):
            keystream += hashlib.sha256(key + nonce + block_idx.to_bytes(4, "big")).digest()
            block_idx += 1
        plain_bytes = bytes(b ^ k for b, k in zip(cipher_bytes, keystream[:len(cipher_bytes)]))
        return plain_bytes.decode("utf-8")


def process_csv(
    input_path: str,
    output_path: str,
    secret_key: str,
    mode: str = "encrypt",
    target_columns: set = None,
):
    """Read CSV, process selected columns, write to output CSV."""
    if not os.path.exists(input_path):
        print(f"Error: Input file '{input_path}' not found.")
        sys.exit(1)

    columns_to_handle = target_columns or DEFAULT_SENSITIVE_COLUMNS
    key_bytes = derive_key(secret_key)

    with open(input_path, mode="r", encoding="utf-8-sig", newline="") as infile:
        reader = csv.DictReader(infile)
        if not reader.fieldnames:
            print("Error: CSV file is empty or missing headers.")
            sys.exit(1)

        fieldnames = reader.fieldnames
        matched_cols = [c for c in fieldnames if c.strip().lower() in columns_to_handle]

        print(f"\n[+] Input CSV: {input_path}")
        print(f"[+] Output CSV: {output_path}")
        print(f"[+] Mode: {mode.upper()}")
        print(f"[+] Columns selected for {mode}: {matched_cols if matched_cols else 'None matched!'}\n")

        rows = []
        for row_idx, row in enumerate(reader, start=1):
            new_row = {}
            for col in fieldnames:
                val = row[col]
                if col.strip().lower() in columns_to_handle and val:
                    if mode == "encrypt":
                        new_row[col] = encrypt_value_gcm(val, key_bytes)
                    elif mode == "decrypt":
                        new_row[col] = decrypt_value_gcm(val, key_bytes)
                else:
                    new_row[col] = val
            rows.append(new_row)

    with open(output_path, mode="w", encoding="utf-8", newline="") as outfile:
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"[SUCCESS] Successfully processed {len(rows)} records into '{output_path}'.")


def main():
    parser = argparse.ArgumentParser(
        description="Encrypt/Decrypt sensitive columns of a CSV before Supabase upload"
    )
    parser.add_argument("input", help="Path to input CSV file")
    parser.add_argument(
        "-o", "--output", help="Path to output CSV file (defaults to [input]_[encrypted|decrypted].csv)"
    )
    parser.add_argument(
        "-k",
        "--key",
        required=True,
        help="Secret encryption key or passphrase (store this safely!)",
    )
    parser.add_argument(
        "-m",
        "--mode",
        choices=["encrypt", "decrypt"],
        default="encrypt",
        help="Operation mode (default: encrypt)",
    )
    parser.add_argument(
        "-c",
        "--columns",
        help="Comma-separated list of column names to encrypt/decrypt (e.g. 'upi_id,description')",
    )

    args = parser.parse_args()

    # Determine output filename if not provided
    if not args.output:
        base, ext = os.path.splitext(args.input)
        args.output = f"{base}_{args.mode}ed{ext}"

    # Determine target columns
    if args.columns:
        target_cols = {c.strip().lower() for c in args.columns.split(",") if c.strip()}
    else:
        target_cols = DEFAULT_SENSITIVE_COLUMNS

    process_csv(
        input_path=args.input,
        output_path=args.output,
        secret_key=args.key,
        mode=args.mode,
        target_columns=target_cols,
    )


if __name__ == "__main__":
    main()
