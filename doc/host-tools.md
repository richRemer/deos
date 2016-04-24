Host Tools
==========

GCC Cross Compiler
------------------
Instructions based on http://wiki.osdev.org/GCC_Cross-Compiler

### Preparation
 * download sources into /usr/local/osdev/src

### Configuring Build
```sh
export TARGET=amd64-elf
export PATH="/usr/local/osdev/bin:$PATH"
export PREFIX=/usr/local/osdev
./binutils-2.26/configure \
  --prefix="$PREFIX" \
  --target="$TARGET" \
  --disable-nls --disable-werror
./gcc-5.2.0/configure \
  --prefix="$PREFIX" \
  --target="$TARGET" \
  --disable-nls --disable-multilib --enable-languages=c,c++
```
