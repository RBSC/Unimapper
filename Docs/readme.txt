--------------------------------------------------------------------------------
MSX Unimapper Cartridge v2.0 and v3.0
Copyright (c) 2021-2022 RBSC
Developer: Pyhesty
--------------------------------------------------------------------------------

About the project
-----------------

The MSX Unimapper is a cartridge platform for MSX computers that separately supports 4 different mappers and allows to launch software and game
ROMs up to 512kb on any compatible MSX system. The mapper is emulated by 2 or 3 programmable logic (PLD) GAL22V10 chips. Each mapper requires its own
firmware to be programmed into the PLDs. The cartridge platform includes 2 different variants of the same cartridge.

All files of the MSX Unimapper project are available in the RBSC's Github repository: 

 - https://github.com/RBSC/Unimapper

A detailed description of the cartridge is available here:

 - https://sysadminmosaic.ru/msx/unimapper/unimapper (in Russian)
 - https://sysadminmosaic-ru.translate.goog/msx/unimapper/unimapper?_x_tr_sl=auto&_x_tr_tl=en&_x_tr_hl=en&_x_tr_pto=wapp (translated)


Background
----------

The need to develop a universal mapper solution for the most common MSX mappers arose due to the fact that the existing single or multi-mapper
cartridges had the following disadvantages:

 - did not provide a reset of the mapper's state by the Reset signal
 - did not provide flexibility and were not interchangeable
 - contained a fairly large number of electronic components or rare chips
 - contained errors in their circuits, which would complicate their usage

In order to eliminate these shortcomings, it was decided to develop a mapper based on PLD chips of GAL22V10D type, which are quite common, inexpensive
and have the necessary functionality. In particular, they have:

 - 11 inputs
 - 10 outputs
 - allow to implement any function for the input signals
 - allow to use the data for the output signals
 - contain 10 registers, that allow to store up to 10 bits of data

The function of the mapper in MSX cartridges is to provide addressing of a relatively large ROM chip of 128kB or more to a limited address space of Z80
CPU (64kB). In the MSX standard, the 64kB address space can be divided into 16kB used by different devices located in so-called slots. By default, the
cartridge is given a slot of 32kB starting from address 0x4000 to address 0xBFFF. Further, a cartridge itself must determine the use for this address
space. If a cartridge is small and its ROM less than 64kB, it has no need to use the mapper, but in the case of a larger ROM, it is forced to use a
mapper to map various segments of a large ROM into a limited address space. How exactly the ROM segments will be mapped is determined by the cartridge's
developer on a hardware level.

The most common division of 32kB into four 8kB pages is very convenient for games, since you can store different sets of scene/level data for various
scenes/levels and switch them as needed. When accessing a specific address space (one of 4 pages), the address of the desired page should be selected.
For a 128kB cartridge, sixteen 8kB segments are required. Addressing 8kB requires 13 address bits (2^13), these addresses are connected to a ROM chip
chip directly, and the upper four bits of the address (16 pages require 4 address bits) are connected through the mapper circuit.

The address of the desired page should be poked into the specific location in the address space that is monitored by the mapper and when this happens,
the mapper switches the page in the address space to the desired page number stored in the ROM chip.


Supported mappers
-----------------

The Unimapper cartridge v2.0 supports the following MSX mappers in the combination with 256kb or 512kb FlashROMs:

 - ASCII8  (32 page 8kB,  max 256kB FlashROM)
 - ASCII16 (32 page 16kB, max 512kB FlashROM)
 - Konami4  (64 page 8kB,  max 512kB FlashROM)

The Unimapper cartridge v3.0 supports Konami SCC mapper in the combination with 256kb or 512kb FlashROMs. This makes it ideal to be used with the ROMs
that were created using the DSK2ROM tool from floppy disk images.


Hardware
--------
 
The MSX Unimapper cartridge is based on GAL22V10 PLD (programmable logic) chips that add support for various MSX mappers. The circuit also contains a
FlashROM chip where a software or a game ROM is stored. The boards are designed to use 256kb or 512kb FlashROM chips. See the partslist document for
more info about the cartridge's components.

The MSX Unimapper cartridge may be assembled in 2 different variants that require 2 different circuit boards:

 - version 2.0 with 2 GAL chips (separately supports 3 mappers)
 - version 3.0 with 3 GAL chips (supports only Konami SCC mapper so far)

Unlike version 2.0, the version 3.0 allows, by adding one more PLD chip, to implement the Konami SCC mapper. As said above, this can be especially
important when using a ROM generated by the DSK2ROM utility that converts floppy disk images to ROM images that could be used in cartridges.


PLD firmware uploading
----------------------

The freshly-assembled MSX Unimapper cartridge needs the firmware to be uploaded into all GAL PLD chips. For updating/uploading the firmware into the
cartridge and writing ROM images into the FlashROM chip, you will need a TL866 or similar EEPROM/PLD programming device that supports GAL22V10 PLD chips,
as well as specific FlashROM chips.

Before programming the PLD chips should be marked with a sticker or a marker "1","2" or "1","2","3" and the corresponding JED files (there are separate
firmwares for each chip number) have to be uploaded into them.

IMPORTANT! The PLD firmware is not universal! Each mapper requires different firmware files!


Assembling notes
----------------

When installing GAL chips onto a circuit board, please make sure that you install them according to their designated numbers. The FlashROM chip has to
be put into the socket so that its contents could be changed at any time. It's also recommended to put all GAL chips into sockets so that the firmware
could be changed too, for example in case you want to write a ROM that needs a different mapper.

If you solder all chips onto the circuit board, you will not be able to reprogram the contents of the FlashROM or GAL PLD chips until you desolder them.

The version 2.0 of the cartridge requires a bridge or a 0 Ohm resistor to be soldered at position R8, R9 or R10 in order to select the mapper. Do NOT
solder more than one resistor/bridge at those locations!


Cartridge case
--------------

If you solder all chips onto a circuit board (not recommended), then any factory-made MSX cartridge could be suitable for this circuit board, but if you
installed all chips into sockets, you need the specially designed cartridge case that has more space in the front for the chips in sockets. The 3D models
of the case could be found in the "Case" folder of the cartridge's repository.


IMPORTANT!
----------

The RBSC provides all the files and information for free, without any liability (see the disclaimer.txt file). The provided information,
software or hardware must not be used for commercial purposes unless permitted by the RBSC. Producing a small amount of bare boards for
personal projects and selling the rest of the batch is allowed without the permission of RBSC.

When the sources of the tools are used to create alternative projects, please always mention the original source and the copyright!

If you would like to commercially produce this cartridge, please contact the administrator of the RBSC (see info below).


Contact information
-------------------

The members of RBSC group Tnt23, Wierzbowsky, Pyhesty, Ptero, GreyWolf, SuperMax ? DJS3000 can be contacted via the group's e-mail
address:

info@rbsc.su

The group's coordinator could be reached via this e-mail address:

admin@rbsc.su

The group's website can be found here:

https://rbsc.su/
https://rbsc.su/ru

The RBSC's hardware repository can be found here:

https://github.com/rbsc

The RBSC's 3D model repository can be found here:

https://www.thingiverse.com/groups/rbsc/things

-= ! MSX FOREVER ! =-

