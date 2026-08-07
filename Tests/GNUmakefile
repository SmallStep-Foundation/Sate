#
# SmallAdvancedTextEditor unit tests
# Build from SmallAdvancedTextEditor: make -f Tests/GNUmakefile
# Run: ./Tests/obj/test_SmallAdvancedTextEditor
#

include $(GNUSTEP_MAKEFILES)/common.make

# SmallStep framework (shared discovery - SmallStepLib/GNUmakefile.include)
-include ../../SmallStepLib/GNUmakefile.include

TOOL_NAME = test_SmallAdvancedTextEditor
test_SmallAdvancedTextEditor_OBJC_FILES = SmallAdvancedTextEditorTests.m ../App/TEAppDelegate.m ../Core/SATETheme.m ../Core/SATEThemeManager.m ../Core/SyntaxHighlighterTextStorage.m ../UI/TEMainWindow.m ../UI/TEThemePanel.m
test_SmallAdvancedTextEditor_INCLUDE_DIRS = -I.. -I../App -I../Core -I../UI
test_SmallAdvancedTextEditor_INCLUDE_DIRS += $(SMALLSTEP_INCLUDE_DIRS) -I../../SmallStepLib/Tests
test_SmallAdvancedTextEditor_TOOL_LIBS = -lSmallStep -lgnustep-gui -lgnustep-base -lobjc
test_SmallAdvancedTextEditor_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -Wl,--allow-shlib-undefined

before-all::
	$(MAKE) -C ../../SmallStepLib
	$(MAKE) -C ..

include $(GNUSTEP_MAKEFILES)/tool.make
