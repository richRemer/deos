;; Author: Richard Remer

;; constants for working with CPUID instruction

%ifndef _CPUID_ASM
%define _CPUID_ASM

CPUIDFN_HIFN    equ 0x00
CPUIDFN_CPU     equ 0x01
CPUIDFN_HIEXTFN equ 0x80000000
CPUIDFN_EXTCPU  equ 0x80000001

CPUID_LM_BIT    equ 29

%endif
