#!/bin/bash
#Setup attenuation control, format (24bit rj), De-Emphasis (off), Mute off
i2cset -y 2 0x4f 0x12 0xA1
i2cget -y 2 0x4f 0x12
