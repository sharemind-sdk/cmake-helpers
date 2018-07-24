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


MACRO(SharemindCheckUndefined vname)
    IF(DEFINED "${vname}")
        MESSAGE(FATAL_ERROR "${vname} already defined!")
    ENDIF()
ENDMACRO()

MACRO(SharemindSetToDefaultIfEmpty varname)
    IF("${${varname}}" STREQUAL "")
        SET("${varname}" "${ARGN}")
    ENDIF()
ENDMACRO()

MACRO(SharemindRegisteredSet registryName varName)
    LIST(APPEND "${registryName}" "${varName}")
    LIST(REMOVE_DUPLICATES "${registryName}")
    SET("${varName}" ${ARGN})
ENDMACRO()

MACRO(SharemindElevateRegisteredVariables)
    FOREACH(varName IN ITEMS ${ARGN})
        SET("${varName}" ${${varName}} PARENT_SCOPE)
    ENDFOREACH()
ENDMACRO()

FUNCTION(SharemindGenerateUniqueVariablePrefix out)
    GET_CMAKE_PROPERTY(allVariableNames VARIABLES)
    SET(prefixPrefix "SharemindGenerateUniqueVariablePrefix")
    SET(counter 1)
    WHILE(TRUE)
        SET(prefix "${prefixPrefix}_${counter}_")
        SET(hasPrefix FALSE)
        FOREACH(variableName IN LISTS allVariableNames)
            IF(variableName MATCHES "^${prefix}")
                SET(hasPrefix TRUE)
                BREAK()
            ENDIF()
        ENDFOREACH()
        IF(NOT hasPrefix)
            SET("${out}" "${prefix}" PARENT_SCOPE)
            RETURN()
        ENDIF()
        MATH(EXPR counter "${counter} + 1")
    ENDWHILE()
ENDFUNCTION()
