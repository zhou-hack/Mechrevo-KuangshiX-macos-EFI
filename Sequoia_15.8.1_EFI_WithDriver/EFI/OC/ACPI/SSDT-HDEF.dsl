/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20260408 (32-bit version)
 * Copyright (c) 2000 - 2026 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of D:/EFI/OC/ACPI/SSDT-HDEF.aml
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x00000071 (113)
 *     Revision         0x02
 *     Checksum         0x12
 *     OEM ID           "CXDSP"
 *     OEM Table ID     "HDEF"
 *     OEM Revision     0x00000000 (0)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20260408 (539362312)
 */
DefinitionBlock ("", "SSDT", 2, "CXDSP", "HDEF", 0x00000000)
{
    External (_SB_.PC00.HDEF, DeviceObj)

    Scope (_SB.PC00.HDEF)
    {
        Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
        {
            If ((Arg2 == Zero))
            {
                Return (Buffer (One)
                {
                     0x03                                             // .
                })
            }

            Return (Package (0x02)
            {
                "layout-id", 
                Buffer (0x04)
                {
                     0x0F, 0x00, 0x00, 0x00                           // ....
                }
            })
        }
    }
}

