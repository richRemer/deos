Filesystem Layout
=================

Primary Index
-------------
The *primary index* is the root *allocation index* and always resides at LBA 0
of the file system.  The first few entries should point to the *primary index*
as well as secondary clones.

Secondary Index
---------------
A single *secondary index* cloned from the *primary index* resides at the end
of the file system.  Additional clones reside (depending on disk size) just
before
 * 512 KiB
 * 512 MiB
 * 512 GiB
 * 512 TiB

Allocations
-----------
Allocations are chunks of allocated disk space.

### Allocation Entry
An *allocation entry* is a data structure describing an allocation.
```
0x00  qword   LBA start
0x08  byte    left shift 3 for LBA length
0x09  byte    allocation type
0x0A  word    type flags
0x0C  dword   reserved
```

### Allocation Types
The *allocation type* indicates how the allocation should be used.
 * **0x00**: reserved space
 * **0x01**: allocation index
 * **0x02**: log
 * **0x03**: hash index (file, GUID, *etc.*)
 * **0xFF**: deallocation (for allocation stream)

### Allocation Index
An *allocation index* contains a list of *allocation entry* records.  Example
is for a 4 KiB allocation index
```
0x000000-0x00001f   Allocation Index Header
       ...          Allocation Entry List
0x3fffe0-0x3fffff   Allocation Index Footer
```

#### Allocation Index Header
The *allocation index header* marks and describes an *allocation index*.
```
0x0000  qword   signature "allocidx"
0x0008  dword   CRC32 of header (w/ CRC=0)
0x000C  dword   CRC32 of entry list
0x0010  qword   index size
0x0018  qword   index length
```

#### Allocation Index Footer
The *allocation index footer* marks the end of an *allocation index*.
```
0x0010  qword   index size
0x0018  qword   index length
0x0010  dword   CRC32 of entry list
0x0014  dword   CRC32 of footer (w/ CRC=0)
0x0018  qword   signature "xdicolla"
```
