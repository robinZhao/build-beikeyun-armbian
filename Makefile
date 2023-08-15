DTB_NAME := rk3328-beikeyun-1296mhz.dtb
DTB_DIR := flippy/dtbs/5.15.83

DL := input
WGET := wget -nv -P $(DL)
AXEL := axel -a -n4 -o $(DL)

OUTPUT := output
TARGETS := armbian

.PHONY: help build clean

help:
	@echo "Usage: make build_[system1]=y build_[system2]=y build"
	@echo "available system: $(TARGETS)"

build: $(TARGETS)

clean: $(TARGETS:%=%_clean)
	rm -f $(OUTPUT)/*.img $(OUTPUT)/*.xz

ARMBIAN_PKG_UBUNTU := Armbian_23.5.1_Rock64_jammy_current_6.1.30_gnome_desktop.img.xz
ARMBIAN_PKG_DEBIAN := Armbian_23.5.1_Rock64_bookworm_current_6.1.30.img.xz
ARMBIAN_PKG_DEBIAN_MINI := Armbian_23.5.1_Rock64_bookworm_current_6.1.30_minimal.img.xz

#ifneq ($(TRAVIS_TAG),)
ARMBIAN_URL_BASE := https://armbian.tnahosting.net/dl/rock64/archive
#else
#ARMBIAN_URL_BASE := https://mirrors.tuna.tsinghua.edu.cn/armbian-releases/rock64/archive
#endif

ARMBIAN_PKG_%:
	@( if [ ! -f "$(DL)/$($(@))" ]; then \
		$(WGET) $(ARMBIAN_URL_BASE)/$($(@)) ; \
	fi )

ARMBIAN_PKG_%_CLEAN:
	rm -f $(DL)/$($(@:_CLEAN=))

ifeq ($(build_armbian),y)
ARMBIAN_TARGETS := ARMBIAN_PKG_DEBIAN ARMBIAN_PKG_DEBIAN_MINI ARMBIAN_PKG_UBUNTU
ARMBIAN_UBOOT_MINILOADER := izumiko/loader
ARMBIAN_UBOOT_ALL := flippy/loader/btld-rk3328.bin

armbian: $(ARMBIAN_TARGETS)
	( for pkg in $(foreach n,$^,$($(n))); do \
		sudo ./build-armbian.sh repack $(DL)/$$pkg $(DTB_NAME) ${DTB_DIR} $(ARMBIAN_UBOOT_ALL) ; \
	done )

armbian_clean: $(ARMBIAN_TARGETS:%=%_CLEAN)

else
armbian:
armbian_clean:
endif
