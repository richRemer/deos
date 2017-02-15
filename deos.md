DeOS
====

Process Streams
---------------
 * posix+
 * stdin

Architectural Notes
-------------------
 * resources
   * kernel
     * entire
   * processes
     * proc 0 - kernel/init or whatever
       * granted full access to process/memory/disk
     * proc 1 - disk
   * disk chunks by user and process/app
 * boot process
   * bootloader maps memory and switches to 64 bit
   * kernel remaps memory (probably)
   * 

**program**: executable  
**application**: role of program  
**user app**: applications tied together

#### Practical Example
 * acme_doohicky **program** with file_select **application**
 * cyberdyne_foo **program** with editor **application**
 * user creates MyEditor **program** by tying the two applications together
