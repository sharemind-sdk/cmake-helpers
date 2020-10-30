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

FUNCTION(SharemindCheckNumericVersionSyntax v)
    IF(NOT("${v}" MATCHES "^(0|[1-9][0-9]*)(\\.(0|[1-9][0-9]*))*$"))
        MESSAGE(FATAL_ERROR "Numeric version has invalid syntax: ${v}")
    ENDIF()
    IF("${v}" MATCHES "^0(\\.0)*$")
        MESSAGE(FATAL_ERROR "Zero numeric version ${v} not allowed!")
    ENDIF()
ENDFUNCTION()

FUNCTION(SharemindNormalizeVersion)
    SharemindGenerateUniqueVariablePrefix(p)
    SharemindNewList(flags)
    SET(opts1 VERSION OUTPUT_VARIABLE NUM_COMPONENTS)
    SharemindNewList(optsn)
    CMAKE_PARSE_ARGUMENTS("${p}" "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments("${p}")
    SharemindCheckArgument("${p}" VERSION REQUIRED NON_EMPTY)
    SharemindCheckArgument("${p}" OUTPUT_VARIABLE REQUIRED NON_EMPTY)

    # Check for valid VERSION argument:
    SharemindCheckNumericVersionSyntax("${${p}_VERSION}")

    # Check for valid NUM_COMPONENTS argument:
    IF(NOT ("${${p}_NUM_COMPONENTS}" MATCHES "^([1-9][0-9]*)?$"))
        MESSAGE(FATAL_ERROR "Invalid NUM_COMPONENTS argument given!")
    ENDIF()

    # Use 3 by default for NUM_COMPONENTS:
    IF("${${p}_NUM_COMPONENTS}" STREQUAL "")
        SET(${p}_NUM_COMPONENTS "3")
    ENDIF()

    # Construct regular expression for normalization:
    SET(regex "^[0-9]+")
    WHILE("${${p}_NUM_COMPONENTS}" GREATER "1")
        STRING(APPEND regex ".[0-9]+")
        MATH(EXPR "${p}_NUM_COMPONENTS" "${${p}_NUM_COMPONENTS} - 1")
    ENDWHILE()

    # Normalize version to at least three components:
    WHILE(NOT ("${${p}_VERSION}" MATCHES "${regex}"))
        SET("${p}_VERSION" "${${p}_VERSION}.0")
    ENDWHILE()

    # Write result to the OUTPUT_VARIABLE:
    SET("${${p}_OUTPUT_VARIABLE}" "${${p}_VERSION}" PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(SharemindNumericVersionToList v out)
    SharemindCheckNumericVersionSyntax("${v}")
    STRING(REPLACE "." ";" v "${v}")
    SET("${out}" "${v}" PARENT_SCOPE)
ENDFUNCTION()
