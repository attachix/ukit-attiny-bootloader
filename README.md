## Introduction

This is the source code of the boot loader used in the Attiny microcontroller that is part of the [U:Kit sensor kit](https://github.com/attachix/ukit) project.
It is a slight modification of the [TinySafeBoot](http://jtxp.org/tech/tinysafeboot_en.htm) aka TSB boot loader by Julien Thomas.
And as such it is [licensed](LICENSE) under the same terms as the original TSB boot loader.

## Modifications

The source code is based on the work done by [Masami Yamakawa](https://github.com/monoxit/tsb1634) that contains modifications
for better compatibility with Attiny1634.

You will find also small modifications for the need of U:Kit.

## Requirements
### Software

In order to compile and flash the source code and do some modifications to it you will need
* AVR Assembler. Our recommendation is to use the assembler compiler coming with AVR Studio 6 or later
* AVR binutils. In Ubuntu 16.04 you can install them with the following command `sudo apt install binutils-avr`.
* AVR Dude. In Ubuntu 16.04 you can install it with the following command `sudo apt install avrdude`.

### Hardware
* AVR programmer. A cheap [USBasp](http://www.fischl.de/usbasp/) or similar will be perfectly enough. Make sure that you have the latest firmware flashed on the programmer.

## License
All files in this repository are licensed under GPLv3. See the [LICENSE](LICENSE) file details.
