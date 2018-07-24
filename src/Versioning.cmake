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

IF(NOT DEFINED SharemindVersioning_INCLUDED)
SET(SharemindVersioning_INCLUDED TRUE)


INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Arguments.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Lists.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Variables.cmake")
INCLUDE(CMakeParseArguments)

MACRO(SharemindCheckNumericVersionSyntax v)
    IF(NOT("${v}" MATCHES "^[0-9]+(\\.[0-9]+)*$"))
        MESSAGE(FATAL_ERROR "Numeric version has invalid syntax: ${v}")
    ENDIF()
ENDMACRO()

MACRO(SharemindNumericVersionToList v out)
    SharemindCheckNumericVersionSyntax("${v}")
    STRING(REPLACE "." ";" "${out}" "${v}")
ENDMACRO()

FUNCTION(SharemindSetProjectVersion)
    SharemindCheckUndefined(CPACK_PACKAGE_VERSION_MAJOR)
    SharemindCheckUndefined(CPACK_PACKAGE_VERSION_MINOR)
    SharemindCheckUndefined(CPACK_PACKAGE_VERSION_PATCH)

    SET(flags NO_OUTPUT)
    SET(opts1 VERSION OUTPUT_VARIABLE)
    SharemindNewList(optsn)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments(CPA)

    # Use ${PROJECT_VERSION} by default for VERSION:
    IF("${CPA_VERSION}" STREQUAL "")
        SET(CPA_VERSION "${PROJECT_VERSION}")
    ENDIF()

    SharemindCheckNumericVersionSyntax("${CPA_VERSION}")

    # Normalize version to at least three components:
    WHILE(NOT ("${CPA_VERSION}" MATCHES "^[0-9]+.[0-9]+(.[0-9]+)+$"))
        SET(CPA_VERSION "${CPA_VERSION}.0")
    ENDWHILE()

    # Extract version components and populate CPACK_PACKAGE_VERSION* variables:
    SharemindNumericVersionToList("${CPA_VERSION}" vl)
    SharemindListExtractFromHead("${vl}" v1 v2 v3)
    SET(CPACK_PACKAGE_VERSION_MAJOR "${v1}" PARENT_SCOPE)
    SET(CPACK_PACKAGE_VERSION_MINOR "${v2}" PARENT_SCOPE)
    SET(CPACK_PACKAGE_VERSION_PATCH "${v3}" PARENT_SCOPE)

    # Handle NO_OUTPUT:
    IF(NOT CPA_NO_OUTPUT)
        # Use "${CMAKE_PROJECT_NAME}_VERSION" by default for OUTPUT_VARIABLE:
        IF("${CPA_OUTPUT_VARIABLE}" STREQUAL "")
            SET(CPA_OUTPUT_VARIABLE "${CMAKE_PROJECT_NAME}_VERSION")
        ENDIF()

        # Set ${OUTPUT_VARIABLE} in parent scope to the normalized version:
        SET("${CPA_OUTPUT_VARIABLE}" "${CPA_VERSION}" PARENT_SCOPE)
    ENDIF()
ENDFUNCTION()


ENDIF() # SharemindVersioning_INCLUDED
