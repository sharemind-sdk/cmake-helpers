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
# Foundation and appearing in the file LICENSE.GPL included in the
# packaging of this file.  Please review the following information to
# ensure the GNU General Public License version 3.0 requirements will be
# met: http://www.gnu.org/copyleft/gpl-3.0.html.
#
# For further information, please contact us at sharemind@cyber.ee.
#

IF(NOT DEFINED SharemindLists_INCLUDED)
SET(SharemindLists_INCLUDED TRUE)


MACRO(SharemindNewList name)
    SET("${name}" tmp)
    LIST(REMOVE_ITEM "${name}" tmp)
    LIST(APPEND "${name}" ${ARGN})
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


ENDIF() # SharemindLists_INCLUDED
