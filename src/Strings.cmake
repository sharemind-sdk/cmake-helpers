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

FUNCTION(SharemindStringHasPrefix str searchPrefix out)
    SET("${out}" TRUE PARENT_SCOPE)
    STRING(LENGTH "${searchPrefix}" prefixLen)
    IF("${prefixLen}" LESS 1)
        RETURN()
    ENDIF()
    STRING(SUBSTRING "${str}" 0 "${prefixLen}" prefix)
    IF("${prefix}" STREQUAL "${searchPrefix}")
        RETURN()
    ENDIF()
    SET("${out}" FALSE PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(SharemindStringStripPrefix str prefix out)
    SharemindGenerateUniqueVariablePrefix(p)
    SET(flags FATAL_IF_PREFIX_NOT_FOUND)
    SharemindNewList(opts1)
    SharemindNewList(optsn)
    CMAKE_PARSE_ARGUMENTS("${p}" "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments("${p}")

    SharemindStringHasPrefix("${str}" "${prefix}" hasPrefix)
    IF("${hasPrefix}")
        STRING(LENGTH "${prefix}" prefixLen)
        STRING(SUBSTRING "${str}" "${prefixLen}" -1 str)
    ELSEIF("${${p}_FATAL_IF_PREFIX_NOT_FOUND}")
        MESSAGE(FATAL_ERROR "Prefix \"${prefix}\" not found in \"${str}\"!")
    ENDIF()
    SET("${out}" "${str}" PARENT_SCOPE)
ENDFUNCTION()
