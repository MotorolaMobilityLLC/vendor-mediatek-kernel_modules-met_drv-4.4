LOCAL_PATH := $(call my-dir)

ifneq (,$(filter $(word 2,$(subst -, ,$(LINUX_KERNEL_VERSION))),$(subst /, ,$(LOCAL_PATH))))

MY_KERNEL_ROOT_DIR := $(PWD)
MY_KERNEL_CONFIG_FILE := $(MY_KERNEL_ROOT_DIR)/kernel-4.4/arch/$(TARGET_ARCH)/configs/$(KERNEL_DEFCONFIG)
MY_KERNEL_CONFIG_MODULES := $(shell grep ^CONFIG_MODULES=y $(MY_KERNEL_CONFIG_FILE))

MY_KERNEL_DEFAULT_CONFIG_FILE := $(MY_KERNEL_ROOT_DIR)/kernel-4.4/drivers/misc/mediatek/Kconfig.default
MY_KERNEL_DEFAULT_CONFIG_MODULES := $(shell grep "select MODULES" $(MY_KERNEL_DEFAULT_CONFIG_FILE))

CONFIG_MODULES_EXIST = n
ifneq ($(MY_KERNEL_CONFIG_MODULES), "")
	CONFIG_MODULES_EXIST := y
else ifneq ($(MY_KERNEL_DEFAULT_CONFIG_MODULES), "")
	CONFIG_MODULES_EXIST := y
endif

# we should not build ko for some project without define CONFIG_MODULES
ifeq ($(CONFIG_MODULES_EXIST), y)

include $(CLEAR_VARS)
LOCAL_MODULE := met.ko

ifeq (user,$(TARGET_BUILD_VARIANT))
   MET_INTERNAL_USE := $(shell test -f $(MY_KERNEL_ROOT_DIR)/vendor/mediatek/kernel_modules/met_drv_secure/4.4/init.met.rc && echo yes)
   ifeq ($(MET_INTERNAL_USE),yes)
      LOCAL_INIT_RC := ../../met_drv_secure/4.4/init.met.rc
   endif
endif

include $(MTK_KERNEL_MODULE)
else
$(warning Not building met.ko due to CONFIG_MODULES is not set)
$(warning Please check following config files whether CONFIG_MODULES is set)
$(warning 1. $(MY_KERNEL_CONFIG_FILE))
$(warning 2. $(MY_KERNEL_DEFAULT_CONFIG_FILE))
endif # $(CONFIG_MODULES_EXIST == y)
endif # Kernel version matches current path
