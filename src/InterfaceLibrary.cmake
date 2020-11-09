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
INCLUDE(CMakeParseArguments)

FUNCTION(SharemindAddInterfaceLibrary name)
    IF("${name}" STREQUAL "")
        MESSAGE(FATAL_ERROR "Empty name given!")
    ENDIF()

    SharemindGenerateUniqueVariablePrefix(p)
    SharemindNewList(flags)
    SET(opts1 COMPONENT EXPOSE_FILES_TARGET)
    SET(optsn EXPOSE_FILES)
    CMAKE_PARSE_ARGUMENTS("${p}" "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments("${p}")

    # Handle COMPONENT:
    IF("${${p}_COMPONENT}" STREQUAL "")
       SET("${p}_COMPONENT" "lib")
    ENDIF()

    # Handle EXPOSE_FILES_TARGET:
    IF("${${p}_EXPOSE_FILES_TARGET}" STREQUAL "")
       SET("${p}_EXPOSE_FILES_TARGET" "${name}_EXPOSE_FILES")
    ENDIF()

    # Handle EXPOSE_FILES:
    IF(NOT("${${p}_EXPOSE_FILES}" STREQUAL ""))
        ADD_CUSTOM_TARGET("${${p}_EXPOSE_FILES_TARGET}"
            SOURCES ${${p}_EXPOSE_FILES})
    ENDIF()

    ADD_LIBRARY("${name}" INTERFACE)
    INSTALL(TARGETS "${name}"
            EXPORT "${name}-Export"
            COMPONENT "${${p}_COMPONENT}")
ENDFUNCTION()
