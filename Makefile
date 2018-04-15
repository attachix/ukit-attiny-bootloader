###############################################
#
#  Automation script for AVRASM and Linux
#
###############################################
AS=avrasm
NAME=tsb_tinymega
APP ?= ../ukit-firmware/build/main.hex
APPNTSB=build/app-n-tsb.hex
AVR_PROGRAMMER ?= usbasp

V ?= $(VERBOSE)
ifeq ("$(V)","1")
Q :=
vecho := @true
else
Q := @
vecho := @echo
endif

WRITE_OPTS = 
ifdef ERASE
	WRITE_OPTS += -e	
endif

build/$(NAME).hex: $(NAME).asm
	$(Q) $(AS) $(NAME)

compile: build/$(NAME).hex


build/$(NAME).elf: build/$(NAME).hex
	$(Q) avr-objcopy -I ihex -O elf32-avr $< $@


elf: build/$(NAME).elf
	
flash: build/$(NAME).hex
	$(Q) sudo avrdude -c $(AVR_PROGRAMMER) -p t1634 -B 12 $(WRITE_OPTS) -U flash:w:build/$(NAME).hex:i

patch:
	$(Q) export TEMP_DIR=`mktemp -d`
	
# 3. Copy the final code from the device:
	sudo avrdude -c $(AVR_PROGRAMMER) -p t1634 -B 11 -U flash:r:"${TEMP_DIR}/flash-mem-tsb.bin":r

#  Convert the BIN file to HEX
	$(Q) bin2hex.py $(TEMP_DIR)/flash-mem-tsb.bin ${TEMP_DIR}/flash-mem-tsb.hex

# Find the address where the RESET label is located
	avr-objdump -m avr -l -w  -S -j .sec1 -D ${TEMP_DIR}/flash-mem-tsb.hex | less

# Calculate the address using that example:
# Address = 0x3d00 = 15616 /2  ->  7808 -> 1E80 -> 80 1E

# python: hex( 0x3d00 / 2  ) -> swap bytes
	$(Q) echo -en "\x0c\x94\x80\x1E" > ${TEMP_DIR}/data.bin

# 7. Edit the BIN file and replace the first four bytes the right jump opcode
	$(Q) cp  ${TEMP_DIR}/flash-mem-tsb.bin ${TEMP_DIR}/flash-mem-tsb-with-reset.bin
	$(Q) dd if=${TEMP_DIR}/data.bin of=${TEMP_DIR}/flash-mem-tsb-with-reset.bin bs=1 count=5 conv=notrunc
	
# 8. Burn the new firmware to the device
	sudo avrdude -c $(AVR_PROGRAMMER) -p t1634 -B 12 -U flash:w:${TEMP_DIR}/flash-mem-tsb-with-reset.bin:r

	$(Q) rm -rf ${TEMP_DIR}

$(APPNTSB): build/$(NAME).hex $(APP)
# 	Merge files and remove their end markers
	$(Q) cat $(APP) build/$(NAME).hex | grep -v ':00000001FF' > $(APPNTSB)
#	Modify the reset vector
#	python: hex( 0x3d00 / 2  ) -> swap bytes
#	replace 0C940401 with 0C94D01E / 1EC9
	$(Q) sed -i -- 's/100000000C9404010C9439000C9448000C943800B2/100000000C941EC90C9439000C9448000C943800D0/g' $(APPNTSB)
	
# 	Modify the APP JUMP address on the last page
	$(Q) echo -n ":103FE0000401FFFFFFFFFFFFFFFFFFFFFFFFFFFFDA\r\n" >> $(APPNTSB)
	
#	Add final reset vector
	$(Q) echo ':00000001FF' >> $(APPNTSB)

merge: $(APPNTSB) 

flash-app: $(APPNTSB)
	$(Q) sudo avrdude -c $(AVR_PROGRAMMER) -p t1634 -B 12 -U flash:w:build/$(APPNTSB):i

all: compile

.PHONY: all compile flash merge elf 
