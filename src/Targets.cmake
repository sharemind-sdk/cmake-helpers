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

IF(NOT DEFINED SharemindTargets_INCLUDED)
SET(SharemindTargets_INCLUDED TRUE)


INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Definitions.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Lists.cmake")

MACRO(SharemindTargetSetPropertyIfNonEmpty target property value)
    IF(NOT("${value}" STREQUAL ""))
        SET_TARGET_PROPERTIES("${target}" PROPERTIES "${property}" "${value}")
    ENDIF()
ENDMACRO()

FUNCTION(SharemindTargetSetCommonProperties target includeDirs compileDefs
                                            compileFlags linkLibraries linkFlags
                                            oldDefs)
    SharemindNewUniqueList(ids ${includeDirs})
    SharemindNewUniqueList(cfs ${compileFlags})
    SharemindNewUniqueList(cds ${compileDefs})
    SharemindNewUniqueList(lls ${linkLibraries})
    SharemindNewUniqueList(lfs ${linkFlags})
    FOREACH(value IN LISTS oldDefs)
        SharemindIsDefinition("${value}" isDef)
        IF("${isDef}")
            STRING(SUBSTRING "${value}" 2 -1 value)
            SharemindListAppendUnique(cds "${value}")
        ELSE()
            SharemindListAppendUnique(cfs "${value}")
        ENDIF()
    ENDFOREACH()
    SharemindTargetSetPropertyIfNonEmpty("${target}" INCLUDE_DIRECTORIES
                                         "${ids}")
    SharemindTargetSetPropertyIfNonEmpty("${target}" COMPILE_FLAGS "${cfs}")
    SharemindTargetSetPropertyIfNonEmpty("${target}" COMPILE_DEFINITIONS
                                         "${cds}")
    SharemindTargetSetPropertyIfNonEmpty("${target}" LINK_LIBRARIES "${lls}")
    SharemindTargetSetPropertyIfNonEmpty("${target}" LINK_FLAGS "${lfs}")
ENDFUNCTION()


ENDIF() # SharemindTargets_INCLUDED
