# fpga-noise
### An FPGA implementation of a LFSR noise generator with VGA output for the Elbert V2 FPGA demo board

This implements a 32-bit linear feedback shift register noise generator to produce a 'TV static'-like effect on a VGA monitor.

The VGA output is 640x480 60Hz with a pixel clock of 25MHz. The LFSR is clocked at 192MHz, 8 times the pixel clock, in order to generate the 8bpp 'colour' noise effect.

The 32-bit LFSR has a period of 2^32 bits (4294967296) which repeats about every 22 seconds at 192MHz.

The noise display can be 'paused' by toggling DIP switch 1. This reloads the LFSR seed value on each VSYNC causing the same random sequence to be produced each frame.

DIP switch 2 switches between colour/monochrome noise output:

![Monochrome noise](https://raw.githubusercontent.com/frisnit/fpga-noise/master/images/mono-noise.jpg)
Monochrome noise

![Colour noise](https://raw.githubusercontent.com/frisnit/fpga-noise/master/images/colour-noise.jpg)
Colour noise

DIP switch 3 switches between noise mode and test mode:

![Monochrome test](https://raw.githubusercontent.com/frisnit/fpga-noise/master/images/mono-test.jpg)
Monochrome test

![Colour test](https://raw.githubusercontent.com/frisnit/fpga-noise/master/images/colour-test.jpg)
Colour test

This was built around the Elbert V2 demo code, some of which is still in this demo.