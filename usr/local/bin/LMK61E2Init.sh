#!/bin/bash

i2cset -y 2 0x59 0x15 0x02 #set LVDS output
i2cset -y 2 0x59 0x16 0x00 #set out div to 63
i2cset -y 2 0x59 0x17 0xBD #set out div to 63
i2cset -y 2 0x59 0x19 0x00 #set integer div to 46
i2cset -y 2 0x59 0x1A 0x2E #set integer div to 46
i2cset -y 2 0x59 0x1B 0x1B #set fractional num to 1794560
i2cset -y 2 0x59 0x1C 0x62 #set fractional num to 1794560
i2cset -y 2 0x59 0x1D 0x00 #set fractional num to 1794560
i2cset -y 2 0x59 0x1E 0x3D #set fractional den to 4000000 
i2cset -y 2 0x59 0x1F 0x09 #set fractional den to 4000000 
i2cset -y 2 0x59 0x20 0x00 #set fractional den to 4000000 
i2cset -y 2 0x59 0x21 0x03 #config delta-sigma mod fractional
i2cset -y 2 0x59 0x22 0x24 #config pll doubler and frac pll charge pump
i2cset -y 2 0x59 0x23 0x23 #config phase shift and loop filter
i2cset -y 2 0x59 0x24 0x08 #config R2 loop filter value 
i2cset -y 2 0x59 0x25 0x00 #config C1 loop filter value 
i2cset -y 2 0x59 0x26 0x00 #config R3 loop filter value 
i2cset -y 2 0x59 0x27 0x00 #config C3 loop filter value 
i2cset -y 2 0x59 0x48 0x02 #Software reset PLL  
