#!/bin/bash
#Setup attenuation control, format (24bit rj), De-Emphasis (off), Mute off
i2cset -y 0 0x4f 0x12 0xA0
i2cget -y 0 0x4f 0x12
