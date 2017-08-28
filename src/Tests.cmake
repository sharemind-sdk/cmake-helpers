#
# Copyright (C) Cybernetica
#
# Research/Commercial License Usage
# Licensees holding a valid Research License or Commercial License
# for the Software may use this file according to the written
# agreement between you and Cybernetica.
#
# GNU General Public License Usage
# Alternatively, this file may be used under the terms of the GNU
# General Public License version 3.0 as published by the Free Software
# Foundation and appearing in the file LICENSE.GPL included in the
# packaging of this file.  Please review the following information to
# ensure the GNU General Public License version 3.0 requirements will be
# met: http://www.gnu.org/copyleft/gpl-3.0.html.
#
# For further information, please contact us at sharemind@cyber.ee.
#

IF(NOT DEFINED SharemindTests_INCLUDED)
SET(SharemindTests_INCLUDED TRUE)


INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Arguments.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Targets.cmake")
INCLUDE(CMakeParseArguments)

MACRO(SharemindEnableTests)
    ENABLE_TESTING()
    IF(NOT (TARGET "check"))
        ADD_CUSTOM_TARGET("check" COMMAND "${CMAKE_CTEST_COMMAND}")
    ENDIF()
ENDMACRO()

FUNCTION(SharemindAddTest name)
    SharemindEnableTests()
    SharemindNewList(flags)
    SharemindNewList(opts1)
    SET(optsn SOURCES INCLUDE_DIRECTORIES COMPILE_DEFINITIONS COMPILE_FLAGS
                      LINK_LIBRARIES LEGACY_DEFINITIONS)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments(CPA)

    # Handle SOURCES:
    IF("${CPA_SOURCES}" STREQUAL "")
        MESSAGE(FATAL_ERROR "No valid SOURCES given!")
    ENDIF()

    ADD_EXECUTABLE("testImpl_${name}" EXCLUDE_FROM_ALL ${CPA_SOURCES})

    SharemindTargetSetCommonProperties("testImpl_${name}"
                                       "${CPA_INCLUDE_DIRECTORIES}"
                                       "${CPA_COMPILE_DEFINITIONS}"
                                       "${CPA_COMPILE_FLAGS}"
                                       "${CPA_LINK_LIBRARIES}"
                                       "${CPA_LEGACY_DEFINITIONS}")

    ADD_DEPENDENCIES("check" "testImpl_${name}")
    ADD_TEST(NAME "test_${name}" COMMAND "testImpl_${name}")
ENDFUNCTION()

FUNCTION(SharemindAddSimpleTest sourceFileName)
    SharemindNewList(flags)
    SharemindNewList(opts1)
    SET(optsn INCLUDE_DIRECTORIES COMPILE_DEFINITIONS COMPILE_FLAGS
              LINK_LIBRARIES LEGACY_DEFINITIONS)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments(CPA)

    GET_FILENAME_COMPONENT(testName "${sourceFileName}" NAME_WE)
    SharemindAddTest("${testName}" SOURCES "${sourceFileName}" ${ARGN})
ENDFUNCTION()


ENDIF() # SharemindLists_INCLUDED
