DefinitionBlock ("", "SSDT", 2, "CXDSP", "HDA21", 0x00000000)
{
    External (_SB_.PC00.HDEF, DeviceObj)

    Scope (_SB.PC00.HDEF)
    {
        Method (_DSM, 4, NotSerialized)
        {
            If ((Arg2 == Zero))
            {
                Return (Buffer (One) { 0x03 })
            }

            Return (Package (0x02)
            {
                "layout-id",
                Buffer (0x04) { 0x15, 0x00, 0x00, 0x00 }
            })
        }
    }
}
