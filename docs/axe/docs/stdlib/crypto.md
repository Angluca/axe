# .\crypto.axec

## model SHA256Digest

SHA256 digest size in bytesSHA1 digest size in bytes  
MD5 digest size in bytes
Represents a SHA256 hash digest


## def rotr(x: i32, n: i32): i32

Right rotate a 32-bit unsigned integer

## def shr(x: i32, n: i32): i32

Right shift with proper unsigned handling

## def ch(x: i32, y: i32, z: i32): i32

SHA-256 Ch function: (x AND y) XOR (NOT x AND z)

## def maj(x: i32, y: i32, z: i32): i32

SHA-256 Maj function: (x AND y) XOR (x AND z) XOR (y AND z)

## def sigma0(x: i32): i32

SHA-256 Σ0 function

## def sigma1(x: i32): i32

SHA-256 Σ1 function

## def sigma_lower0(x: i32): i32

SHA-256 σ0 function (lowercase sigma)

## def sigma_lower1(x: i32): i32

SHA-256 σ1 function (lowercase sigma)

## def xor_op(a: i32, b: i32): i32

SHA-256 round constants (first 32 bits of the fractional parts of the cube roots of the first 64 primes)SHA-256 initial hash values (first 32 bits of the fractional parts of the square roots of the first 8 primes)
XOR operation


## def and_op(a: i32, b: i32): i32

AND operation

## def or_op(a: i32, b: i32): i32

OR operation

## def not_op(a: i32): i32

NOT operation

## def add_wrap(a: i32, b: i32): i32

Add with wrapping

## def bytes_to_u32(b0: i32, b1: i32, b2: i32, b3: i32): i32

Convert 4 bytes to i32 (big-endian)

## def u32_byte(value: i32, pos: i32): i32

Extract byte from i32 at position (0-3, big-endian)

## def sha256_digest_empty(): SHA256Digest

Create an empty SHA256Digest with all bytes initialized to zero

## def sha256_process_block(block: i32*, h: i32*)

Process a single 512-bit block of data

## def sha256(data: char*, len: i32): SHA256Digest

Compute SHA-256 hash of input data

## def simple_hash(data: char*, len: i32): SHA256Digest

Simple hash function for demonstration (NOT cryptographically secure - use sha256 instead)

## def byte_to_hex(byte_val: i32, arena: ref Arena): string

Converts a single byte to a two-character hex string

## def sha256_to_hex(digest: SHA256Digest, arena: ref Arena): string

Converts a SHA256 digest to a lowercase hex string (64 characters)

## def constant_time_compare(buf1: i32*, buf2: i32*, len: i32): bool

Constant-time memory comparison for cryptographic purposesReturns true if buffers are equal. Prevents timing attacks.


## def sha256_equals(digest1: SHA256Digest, digest2: SHA256Digest): bool

Constant-time comparison of two SHA256 digests

## def sha256_zero(digest: ref SHA256Digest)

Securely zero out a digest (for clearing sensitive data)

## def sha256_validate(digest: SHA256Digest): bool

Validate that a digest has valid byte values (0-255)
