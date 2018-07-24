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


INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Lists.cmake")

FUNCTION(SharemindConfigureFile inFile outFile)
    FILE(READ "${inFile}" contents)
    UNSET(needle)
    FOREACH(arg IN LISTS ARGN)
        IF(DEFINED needle)
            STRING(REPLACE "${needle}" "${${arg}}" contents "${contents}")
            UNSET(needle)
        ELSE()
            IF(arg STREQUAL "")
                MESSAGE(FATAL_ERROR "Invalid empty needle given!")
            ENDIF()
            SET(needle "${arg}")
        ENDIF()
    ENDFOREACH()
    IF(DEFINED needle)
        MESSAGE(FATAL_ERROR "Invalid number of arguments given!")
    ENDIF()
    FILE(WRITE "${outFile}" "${contents}")
ENDFUNCTION()
