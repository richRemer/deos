Status of Project
=================
This project hasn't been updated in a while, but I still imagine it in my head
as simply being on hold.  I lost some steam when I discovered my Bochs-based
debugging couldn't handle the transition between 32-bit and 64-bit code and
after having trouble implementing DMA for second-stage loading.

When life finds time, I expect to get back into this, but if you had any good
resources for debugging this sort of low-level bootloader code, including
64-bit support, I'd like to hear about it.

deos - De' Operating System
===========================

Building
--------

```sh
./configure
make
```

This will create a file called `build/os.img` which you can use to launch a VM.
