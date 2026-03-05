# GNUmakefile for SmallAdvancedTextEditor (Linux/GNUstep)
#
# Text editor with syntax highlighting for top languages plus Objective-C,
# Makefile, Scala, Swift, TypeScript, Raku, Lua, Godot Script, Assembly.
# Uses SmallStepLib for app lifecycle, menus, window style, and file dialogs.
#
# Build SmallStepLib first: cd ../SmallStepLib && make && make install
# Then: make

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = SmallAdvancedTextEditor

SmallAdvancedTextEditor_OBJC_FILES = \
	main.m \
	App/TEAppDelegate.m \
	Core/SATETheme.m \
	Core/SATEThemeManager.m \
	Core/SyntaxHighlighterTextStorage.m \
	UI/TEMainWindow.m \
	UI/TEThemePanel.m

SmallAdvancedTextEditor_HEADER_FILES = \
	App/TEAppDelegate.h \
	Core/SATETheme.h \
	Core/SATEThemeManager.h \
	Core/SyntaxHighlighterTextStorage.h \
	UI/TEMainWindow.h \
	UI/TEThemePanel.h

SmallAdvancedTextEditor_INCLUDE_DIRS = \
	-I. \
	-IApp \
	-ICore \
	-IUI \
	-I../SmallStepLib/SmallStep/Core \
	-I../SmallStepLib/SmallStep/Platform/Linux

SMALLSTEP_FRAMEWORK := $(shell find ../SmallStepLib -name "SmallStep.framework" -type d 2>/dev/null | head -1)
ifneq ($(SMALLSTEP_FRAMEWORK),)
  SMALLSTEP_LIB_DIR := $(shell cd $(SMALLSTEP_FRAMEWORK)/Versions/0 2>/dev/null && pwd)
  SMALLSTEP_LIB_PATH := -L$(SMALLSTEP_LIB_DIR)
  SMALLSTEP_LDFLAGS := -Wl,-rpath,$(SMALLSTEP_LIB_DIR)
else
  SMALLSTEP_LIB_PATH :=
  SMALLSTEP_LDFLAGS :=
endif

SmallAdvancedTextEditor_LIBRARIES_DEPEND_UPON = -lobjc -lgnustep-gui -lgnustep-base
SmallAdvancedTextEditor_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -Wl,--allow-shlib-undefined
SmallAdvancedTextEditor_ADDITIONAL_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -lSmallStep
SmallAdvancedTextEditor_TOOL_LIBS = -lSmallStep -lobjc

before-all::
	mkdir -p Resources && cp -f ../SmallStepLib/Resources/logo.png Resources/logo.png 2>/dev/null || true
SmallAdvancedTextEditor_RESOURCE_FILES = Resources/logo.png

include $(GNUSTEP_MAKEFILES)/application.make
