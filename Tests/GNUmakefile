#
# SmallAdvancedTextEditor unit tests
# Build from SmallAdvancedTextEditor: make -f Tests/GNUmakefile
# Run: ./Tests/obj/test_SmallAdvancedTextEditor
#

include $(GNUSTEP_MAKEFILES)/common.make

SMALLSTEP_FRAMEWORK := $(shell find ../../SmallStepLib -name "SmallStep.framework" -type d 2>/dev/null | head -1)
ifneq ($(SMALLSTEP_FRAMEWORK),)
  SMALLSTEP_LIB_DIR := $(shell cd $(SMALLSTEP_FRAMEWORK)/Versions/0 2>/dev/null && pwd)
  SMALLSTEP_LIB_PATH := -L$(SMALLSTEP_LIB_DIR)
  SMALLSTEP_LDFLAGS := -Wl,-rpath,$(SMALLSTEP_LIB_DIR)
else
  SMALLSTEP_LIB_PATH :=
  SMALLSTEP_LDFLAGS :=
endif

TOOL_NAME = test_SmallAdvancedTextEditor
test_SmallAdvancedTextEditor_OBJC_FILES = SmallAdvancedTextEditorTests.m ../App/TEAppDelegate.m ../Core/SATETheme.m ../Core/SATEThemeManager.m ../Core/SyntaxHighlighterTextStorage.m ../UI/TEMainWindow.m ../UI/TEThemePanel.m
test_SmallAdvancedTextEditor_INCLUDE_DIRS = -I.. -I../App -I../Core -I../UI
test_SmallAdvancedTextEditor_INCLUDE_DIRS += -I../../SmallStepLib/SmallStep/Core -I../../SmallStepLib/SmallStep/Platform/Linux -I../../SmallStepLib/Tests
test_SmallAdvancedTextEditor_TOOL_LIBS = -lSmallStep -lgnustep-gui -lgnustep-base -lobjc
test_SmallAdvancedTextEditor_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -Wl,--allow-shlib-undefined

before-all::
	$(MAKE) -C ../../SmallStepLib
	$(MAKE) -C ..

include $(GNUSTEP_MAKEFILES)/tool.make
