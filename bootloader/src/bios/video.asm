;; Author: Richard Remer

;; constants describing video BIOS services (INT 10h)

%ifndef _VIDEO_ASM
%define _VIDEO_ASM

BIOS_VIDEO          equ 0x10
BIOS_VIDEO_MODE     equ 0x00
BIOS_VIDEO_CURSOR   equ 0x01
BIOS_VIDEO_SETPOS   equ 0x02
BIOS_VIDEO_GETCUR   equ 0x03
BIOS_VIDEO_LIGHTPEN equ 0x04
BIOS_VIDEO_PAGE     equ 0x05
BIOS_VIDEO_SCRUP    equ 0x06
BIOS_VIDEO_SCRDOWN  equ 0x07
BIOS_VIDEO_RD       equ 0x08
BIOS_VIDEO_WR       equ 0x09
BIOS_VIDEO_WRCH     equ 0x0a
BIOS_VIDEO_BGPAL    equ 0x0b
BIOS_VIDEO_WRPX     equ 0x0c
BIOS_VIDEO_RDPC     equ 0x0d
BIOS_VIDEO_TTYOUT   equ 0x0e
BIOS_VIDEO_GETMODE  equ 0x0f
BIOS_VIDEO_OUT      equ 0x13

%endif
