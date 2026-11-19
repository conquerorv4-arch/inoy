TARGET = iphone:clang:latest:18.0
ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = M7MD

M7MD_FRAMEWORKS = IOKit UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController JRMemory
M7MD_CFLAGS = -I/opt/theos/include -I. -F. -w -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value
M7MD_CCFLAGS = -w -std=gnu++14 -fno-rtti -fno-exceptions -DNDEBUG -Wno-module-import-in-extern-c -I. -F.
M7MD_LDFLAGS = -F. -framework JRMemory

M7MD_FILES = \
	$(wildcard *.mm) \
	$(wildcard *.cpp) \
	$(wildcard Menux/*.mm) \
	$(wildcard 菜单/*.mm) \
	$(wildcard View/*.mm) \
	$(wildcard View/*.m) \
	$(wildcard CustomView/*.m) \
	$(wildcard utils/*.cpp) \
	$(wildcard utils/*.m) \
	$(wildcard imgui/*.mm) \
	$(wildcard imgui/*.cpp) \
	$(wildcard ESP/*.mm) \
	$(wildcard ESP/*.cpp) \
	$(wildcard SDK/*.cpp) \
	$(wildcard NSURL+hook/*.m) \
	$(wildcard MBProgressHUD/*.m) \
	$(wildcard FCFileManager/*.m) \
	$(wildcard NSEtcHosts/*.m) \
	$(wildcard DBLOCKRASHID/*.m) \
	$(wildcard ZXURLProtocol/*.m) \
	$(wildcard EtcHostsURLProtocol/*.m) \
	$(wildcard NSObject+URL/*.m) \
	$(wildcard ViewController/*.m) \
	$(wildcard ZXHttpIPGet/*.m) \
	$(wildcard NSURLSession+ZXHttpProxy/*.m) \
	$(wildcard main/*.m) \
	$(wildcard 旁路/*.mm)

include $(THEOS_MAKE_PATH)/tweak.mk
