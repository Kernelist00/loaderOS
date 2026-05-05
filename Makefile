ASM=nasm
SRC_DIR=src
BUILD_DIR=build
QEMU=qemu-system-i386

all: $(BUILD_DIR)/os_image.bin

$(BUILD_DIR)/boot.bin: $(SRC_DIR)/boot/boot.asm
	$(ASM) -f bin $< -o $@

$(BUILD_DIR)/kernel.bin:
	$(ASM) -f elf $(SRC_DIR)/kernel/kernel.asm -o $(BUILD_DIR)/kernel.o
	$(ASM) -f elf $(SRC_DIR)/kernel/print/print.asm -o $(BUILD_DIR)/print.o
	$(ASM) -f elf $(SRC_DIR)/kernel/userspace/userspace.asm -o $(BUILD_DIR)/userspace.o
	$(ASM) -f elf $(SRC_DIR)/kernel/userspace/apps/print.asm -o $(BUILD_DIR)/u_print.o
	$(ASM) -f elf $(SRC_DIR)/kernel/userspace/apps/shell.asm -o $(BUILD_DIR)/shell.o
	$(ASM) -f elf $(SRC_DIR)/kernel/userspace/apps/notepad.asm -o $(BUILD_DIR)/notepad.o
	ld -m elf_i386 -Ttext 0x1000 --oformat binary -o $@ $(BUILD_DIR)/kernel.o $(BUILD_DIR)/print.o $(BUILD_DIR)/userspace.o $(BUILD_DIR)/u_print.o $(BUILD_DIR)/shell.o $(BUILD_DIR)/notepad.o

$(BUILD_DIR)/os_image.bin: $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin
	cat $^ > $@

run: all
	$(QEMU) -drive format=raw,file=$(BUILD_DIR)/os_image.bin

clean:
	rm -rf $(BUILD_DIR)/*.bin $(BUILD_DIR)/*.o