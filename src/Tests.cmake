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
# Foundation and appearing in the file LICENSE.GPLv3 included in the
# packaging of this file.  Please review the following information to
# ensure the GNU General Public License version 3.0 requirements will be
# met: http://www.gnu.org/copyleft/gpl-3.0.html.
#
# For further information, please contact us at sharemind@cyber.ee.
#

INCLUDE_GUARD()

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Arguments.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Lists.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Variables.cmake")


MACRO(SharemindEnableTests)
    ENABLE_TESTING()
    IF(NOT (TARGET "check"))
        ADD_CUSTOM_TARGET("check" COMMAND "${CMAKE_CTEST_COMMAND}")
    ENDIF()
ENDMACRO()

FUNCTION(SharemindAddTest_ name)
    SharemindGenerateUniqueVariablePrefix(p)
    SharemindNewList(flags)
    SharemindNewList(opts1)
    SET(optsn SOURCES)
    CMAKE_PARSE_ARGUMENTS("${p}" "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments("${p}")

    # Handle SOURCES:
    IF("${${p}_SOURCES}" STREQUAL "")
        MESSAGE(FATAL_ERROR "No valid SOURCES given!")
    ENDIF()

    ADD_EXECUTABLE("${name}" EXCLUDE_FROM_ALL ${${p}_SOURCES})
    ADD_DEPENDENCIES("check" "${name}")
    ADD_TEST(NAME "${name}" COMMAND "$<TARGET_FILE:${name}>")
ENDFUNCTION()
MACRO(SharemindAddTest)
    SharemindEnableTests()
    SharemindAddTest_(${ARGN})
ENDMACRO()
