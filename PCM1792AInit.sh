#!/bin/bash
#Setup left volume
i2cset -y 2 0x4f 0x10 0xff
#Setup Right volume
i2cset -y 2 0x4f 0x11 0xff
#Setup attenuation control, format (24bit rj), De-Emphasis (off), Mute off
i2cset -y 2 0x4f 0x12 0xA0
i2cget -y 2 0x4f 0x12
