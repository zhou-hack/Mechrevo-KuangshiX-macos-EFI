/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20250404 (32-bit version)
 * Copyright (c) 2000 - 2025 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of D:/EFI/OC/ACPI/SSDT-HPET-CXDSP.aml
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x0000013E (318)
 *     Revision         0x02
 *     Checksum         0xF3
 *     OEM ID           "CXDSP"
 *     OEM Table ID     "HPET"
 *     OEM Revision     0x00000000 (0)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20250404 (539296772)
 */
DefinitionBlock ("", "SSDT", 2, "CXDSP", "HPET", 0x00000000)
{
    External (_SB_.PC00.LPCB.HPET, DeviceObj)
    External (_SB_.PC00.LPCB.HPET.XCRS, MethodObj)    // 0 Arguments
    External (_SB_.PC00.LPCB.HPET.XSTA, MethodObj)    // 0 Arguments

    Scope (\_SB.PC00.LPCB.HPET)
    {
        Name (BUFX, ResourceTemplate ()
        {
            IRQNoFlags ()
                {0,8}
            Memory32Fixed (ReadWrite,
                0xFED00000,         // Address Base
                0x00000400,         // Address Length
                )
        })
        Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
        {
            If ((_OSI ("Darwin") || !CondRefOf (\_SB.PC00.LPCB.HPET.XCRS)))
            {
                Return (BUFX) /* \_SB_.PC00.LPCB.HPET.BUFX */
            }

            Return (\_SB.PC00.LPCB.HPET.XCRS ())
        }

        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            If ((_OSI ("Darwin") || !CondRefOf (\_SB.PC00.LPCB.HPET.XSTA)))
            {
                Return (0x0F)
            }

            Return (\_SB.PC00.LPCB.HPET.XSTA ())
        }
    }
}

