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


INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Padding.cmake")

MACRO(SharemindNewList name)
    SET("${name}" tmp)
    LIST(REMOVE_ITEM "${name}" tmp)
    LIST(APPEND "${name}" ${ARGN})
ENDMACRO()

MACRO(SharemindNewUniqueList name)
    SharemindNewList("${name}" ${ARGN})
    LIST(REMOVE_DUPLICATES "${name}")
ENDMACRO()

MACRO(SharemindListAppendUnique name)
    LIST(APPEND "${name}" ${ARGN})
    LIST(REMOVE_DUPLICATES "${name}")
ENDMACRO()

FUNCTION(SharemindListExtractFromHead list)
    LIST(LENGTH list l)
    MATH(EXPR n "${ARGC} - 1")
    IF("${l}" LESS "${n}")
        MESSAGE(FATAL_ERROR "Not enough elements in given list!")
    ENDIF()
    SET(i 0)
    FOREACH(out IN LISTS ARGN)
        LIST(GET list "${i}" o)
        SET("${out}" "${o}" PARENT_SCOPE)
        MATH(EXPR i "${i} + 1")
    ENDFOREACH()
ENDFUNCTION()

# Sorts the given files based on size (largest first) to slightly optimize the
# build times for multi-core setups to keep all cores as busy as possible. Note
# that this optimization is rather fragile because it depends on how CMake and
# make handle work queues internally.
FUNCTION(SharemindListMaybeSortByFileSize list out)
    FIND_PROGRAM(WC NAMES wc)
    IF(WC)
        SET(l tmp)
        LIST(REMOVE_ITEM l tmp)
        SET(r 0) # result variable
        SET(m 0) # max size
        FOREACH(f IN LISTS list)
            EXECUTE_PROCESS(
                COMMAND "${WC}" -c "${f}"
                OUTPUT_VARIABLE o
                RESULT_VARIABLE r)
            IF(r)
                BREAK()
            ENDIF()
            STRING(REGEX MATCH "^(0|[1-9][0-9]*) " s "${o}")
            STRING(STRIP "${s}" s)
            IF("${s}" GREATER "${m}")
                SET(m "${s}")
            ENDIF()
            LIST(APPEND l "${o}")
        ENDFOREACH()
        IF(NOT r)
            STRING(LENGTH "${m}" n)
            SET(t tmp)
            LIST(REMOVE_ITEM t tmp)
            FOREACH(i IN LISTS l)
                STRING(REGEX REPLACE "^(0|[1-9][0-9]*) " "${m} " s "${i}")
                SharemindPadTo("${i}" "0" "${s}" i)
                LIST(APPEND t "${i}")
            ENDFOREACH()
            SET(l tmp)
            LIST(REMOVE_ITEM l tmp)
            LIST(SORT t)
            LIST(REVERSE t)
            FOREACH(i IN LISTS t)
                STRING(REGEX REPLACE "^[0-9]+ +" "" i "${i}")
                STRING(STRIP "${i}" i)
                LIST(APPEND l "${i}")
            ENDFOREACH()
            SET("${out}" ${l} PARENT_SCOPE)
        ENDIF()
    ELSE()
        SET("${out}" "${list}" PARENT_SCOPE)
    ENDIF()
ENDFUNCTION()
