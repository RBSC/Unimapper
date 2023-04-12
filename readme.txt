--------------------------------------------------------------------------------
MSX Unimapper cartridge v3.5
Copyright (c) 2021-2023 RBSC
Developer: Pyhesty [RBSC]
--------------------------------------------------------------------------------

!*!  Please note that the files for the older versions of the MSX Unimapper cartridge v2.0  !*!
!*!  and v3.0 have been moved into the "_OldVersions" folder. The latest version is v3.5.   !*!


About the project
-----------------

The MSX Unimapper is a cartridge platform for MSX computers that separately supports 4 different mappers and allows to launch software and game
ROMs up to 512kb on any compatible MSX system. The mapper is emulated by 2 or 3 programmable logic (PLD) GAL22V10 chips. Each mapper requires its own
firmware to be programmed into the PLDs. The cartridge platform includes 3 different variants of the same cartridge.

The main difference between v3.0 and v3.5 of the cartridge is that v3.5 is supporting all 4 mappers and also the ability to program the FlashROM
chip from MSX-DOS on any MSX computer with the special utility. The cartridge v3.0 can be converted into v3.5 (see below).

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

The older Unimapper cartridge v2.0 supports the following MSX mappers in the combination with 256kb or 512kb FlashROMs:

 - ASCII8  (32 page 8kB,  max 256kB FlashROM)
 - ASCII16 (32 page 16kB, max 512kB FlashROM)
 - Konami4  (64 page 8kB,  max 512kB FlashROM)

The Unimapper cartridge v3.0 and later supports Konami SCC mapper in the combination with 256kb or 512kb FlashROMs. This makes it ideal to be used
with the ROMs that were created using the DSK2ROM tool from floppy disk images.

The v3.5 of the cartridge allows to program the FlashROM chip from MSX-DOS on MSX computer. The programming mode is enabled by the special switch
or a simple jumper. The v3.5 cartridge supports the following mappers:

 - ASCII8
 - ASCII16
 - Konami4
 - KonamiSCC

Please note that certain KonamiSCC games with delayed start (for example Metal Gear 2) may not work correctly on Yamaha YIS-503IIIR MSX2 (KYBT2)
computers with a built-in CP/M ROM. To be able to run these games please either remove the CP/M ROM from the Subrom's chip or patch the CP/M's ROM
to work correctly with such games. The patched ROM can be downloaded from here:

https://podrezov.com/cpm/subrom_patched_cpm_yis503.rom

Please be aware that certain SCC games expect the SCC chip to be in the same slot with the game, so they will not play SCC sound even if there is
an SCC cartridge (Carnivore2 or similar) in a different slot. To be able to have SCC sound for such games, they need to be pached. If you want to
use Carnivore2 as SCC+ cartridge together with the Unimapper, please create a configuration entry and apply the SCCPLUS.RCP configuration file to
this entry with C2MAN utility. Then start this enty from the Boot Menu to make Carnivore2 emulate SCC+ cartridge, then Unimapper will start the game
and it will be able to find the SCC+ cartridge and use it.


Hardware
--------
 
The MSX Unimapper cartridge is based on GAL22V10 PLD (programmable logic) chips that add support for various MSX mappers. The circuit also contains a
FlashROM chip where a software or a game ROM is stored. The boards are designed to use 256kb or 512kb FlashROM chips. See the partslist document for
more info about the cartridge's components.

The MSX Unimapper cartridge may be assembled in 2 different variants that require 2 different circuit boards:

 - older version 2.0 with 2 GAL chips (separately supports 3 mappers)
 - older version 3.0 with 3 GAL chips (supports only Konami SCC mapper so far)
 - version 3.5 with 2 GAL chips (256kb EEPROM) or 3 GAL chips (512kb EEPROM) - supports all 4 mappers

Unlike version 2.0, the version 3.0 allows, by adding one more PLD chip, to implement the Konami SCC mapper. As said above, this can be especially
important when using a ROM generated by the DSK2ROM utility that converts floppy disk images to ROM images that could be used in cartridges.

The v3.0 of the cartridge can be converted into v3.5 by changing the firmware in all 3 GAL chips and by installing the switch or a jumper onto the
board. The instructions are below in the Assembling notes section.

The cartridge v3.5 has the placeholder for 3-pin jumper header. The board also has instructions on how to set the jumper for normal and programming
modes.


PLD firmware uploading
----------------------

The freshly-assembled MSX Unimapper cartridge needs the firmware to be uploaded into all GAL PLD chips. For updating/uploading the firmware into the
cartridge and writing ROM images into the FlashROM chip, you will need a TL866 or similar EEPROM/PLD programming device that supports GAL22V10 PLD chips,
as well as specific FlashROM chips.

Before programming the PLD chips should be marked with a sticker or a marker as "1","2" or "1","2","3" and the corresponding JED files (there are
separate firmwares for each chip number) have to be uploaded into them.

IMPORTANT! The PLD firmware is not universal! Each mapper requires a different set of firmware files!


Programming of FlashROM
-----------------------

The cartridge v3.5 or the cartridge converted from v3.0 to v3.5 can be programmed from MSX-DOS on a real MSX computer. The utility called UM.COM is
able to write any ROM file into the FlashROM chip when the programming mode is enabled. The procedure is very simple:

 - Set the jumper to enable the "Programming mode"
 - Boot from an MSX-DOS diskette or from a multi-functional cartridge into MSX-DOS2
 - Run the UM.COM utility
 - Select the desired mapper
 - Input the desired ROM file's name without the .ROM extension and press Enter
 - After flashing is complete, power down a computer and set the jumper to the "Normal mode"

If the tool outputs the "Wrong FlashROM ID" message and exits, then either the cartridge is not in the programmable mode or the FlashROM chip is bad
or missing. Please mitigate the problem and try again.

If for some reason the cartridge doesn't allow a computer to boot even when the "Programming mode" is selected, please remove the FlashROM chip from
the cartridge's socket and erase it in the EEPROM programmer.


Assembling notes
----------------

When installing GAL chips onto a circuit board, please make sure that you install them according to their designated numbers. The FlashROM chip may be
put into a socket so that its contents could be manually erased if this becomes necessary. It's also recommended to put all GAL chips into sockets so
that the firmware could be changed too, for example in case you want to write a ROM that needs a different mapper. If you are assembling a cartridge
for one specific mapper, you can solder all 4 chips onto the board after programming the firmware.

The older v2.0 of the cartridge requires a bridge or a 0 Ohm resistor to be soldered at position R8, R9 or R10 in order to select the mapper. Do NOT
solder more than one resistor/bridge at those locations!

The v3.0 of the cartridge can be converted into v3.5 with the following instructions:

 - Install a switch or a 3-pin jumper header (angled) onto the board
 - Cut A14 trace from the slot pad as shown on the image in the Pics folder
 - Solder a wire between the central pin of the pin header and pin 6 of any GAL chip
 - Solder a wire between the left pin of the pin header and the positive terminal of C5 capacitor
 - Solder a 10k resistor between the right pin of the pin header and the ground

This way, when the jumper is set on the 2 leftmost pins of the pin header, the cartridge can be programmed, when the jumper is set on the 2 rightmost
pins of the pin header, the FlashROM's contents will be started.

See the UniMapper_v3.0_top_fix.jpg and UniMapper_v3.0_bottom_fix.jpg images in the Pics folder for reference.


Cartridge case
--------------

If you solder all chips onto a circuit board (not recommended if you plan to change the mapper), then any factory-made MSX cartridge could be suitable
for this circuit board, but if you installed all chips into sockets, you need the specially designed cartridge case that has more space in the front
for the chips in sockets. The 3D models of the case could be found in the "Case" folder of the cartridge's repository.


IMPORTANT!
----------

The RBSC provides all the files and information for free, without any liability (see the disclaimer.txt file). The provided information,
software or hardware must not be used for commercial purposes unless permitted by the RBSC. Producing a small amount of bare boards for
personal projects and selling the rest of the batch is allowed without the permission of RBSC.

When the sources of the tools are used to create alternative projects, please always mention the original source and the copyright!

If you would like to commercially produce this cartridge, please contact the administrator of the RBSC (see info below).


Contact information
-------------------

The members of RBSC group Tnt23, Wierzbowsky, Pyhesty, Ptero, GreyWolf, SuperMax, VWarlock and DJS3000 can be contacted via the group's e-mail
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

