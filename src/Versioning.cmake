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
INCLUDE(CMakeParseArguments)

FUNCTION(SharemindCheckNumericVersionSyntax v)
    IF(NOT("${v}" MATCHES "^(0|[1-9][0-9]*)(\\.(0|[1-9][0-9]*))*$"))
        MESSAGE(FATAL_ERROR "Numeric version has invalid syntax: ${v}")
    ENDIF()
    IF("${v}" MATCHES "^0(\\.0)*$")
        MESSAGE(FATAL_ERROR "Zero numeric version ${v} not allowed!")
    ENDIF()
ENDFUNCTION()

FUNCTION(SharemindNormalizeVersion)
    SharemindNewList(flags)
    SET(opts1 VERSION OUTPUT_VARIABLE NUM_COMPONENTS)
    SharemindNewList(optsn)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments(CPA)
    SharemindCheckArgument(CPA VERSION REQUIRED NON_EMPTY)
    SharemindCheckArgument(CPA OUTPUT_VARIABLE REQUIRED NON_EMPTY)

    # Check for valid VERSION argument:
    SharemindCheckNumericVersionSyntax("${CPA_VERSION}")

    # Check for valid NUM_COMPONENTS argument:
    IF(NOT ("${CPA_NUM_COMPONENTS}" MATCHES "^([1-9][0-9]*)?$"))
        MESSAGE(FATAL_ERROR "Invalid NUM_COMPONENTS argument given!")
    ENDIF()

    # Use 3 by default for NUM_COMPONENTS:
    IF("${CPA_NUM_COMPONENTS}" STREQUAL "")
        SET(CPA_NUM_COMPONENTS "3")
    ENDIF()

    # Construct regular expression for normalization:
    SET(regex "^[0-9]+")
    WHILE("${CPA_NUM_COMPONENTS}" GREATER "1")
        STRING(APPEND regex ".[0-9]+")
        MATH(EXPR CPA_NUM_COMPONENTS "${CPA_NUM_COMPONENTS} - 1")
    ENDWHILE()

    # Normalize version to at least three components:
    WHILE(NOT ("${CPA_VERSION}" MATCHES "${regex}"))
        SET(CPA_VERSION "${CPA_VERSION}.0")
    ENDWHILE()

    # Write result to the OUTPUT_VARIABLE:
    SET("${CPA_OUTPUT_VARIABLE}" "${CPA_VERSION}" PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(SharemindNumericVersionToList v out)
    SharemindCheckNumericVersionSyntax("${v}")
    STRING(REPLACE "." ";" v "${v}")
    SET("${out}" "${v}" PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(SharemindSetProjectVersion)
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
