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

IF(NOT DEFINED SharemindPolymorphism_INCLUDED)
SET(SharemindPolymorphism_INCLUDED TRUE)


SET(SharemindPolymorphism_CURRENT_LEVEL 0)

FUNCTION(SharemindCall_ f)
    SET(args "")
    FOREACH(arg IN LISTS ARGN)
        STRING(REPLACE "\\" "\\\\" arg "${arg}")
        STRING(REPLACE "\"" "\\\"" arg "${arg}")
        SET(args "${args} \"${arg}\"")
    ENDFOREACH()
    STRING(STRIP "${args}" args)
    SET(level "${SharemindPolymorphism_CURRENT_LEVEL}")
    MATH(EXPR next "${level} + 1")
    SET(lvar "SharemindPolymorphism_CURRENT_LEVEL")
    FILE(WRITE
         "${CMAKE_CURRENT_BINARY_DIR}/SharemindPolymorphism_${level}.cmake"
         "SET(${lvar} \"${next}\")\n${f}(${args})\nSET(${lvar} \"${level}\")\n")
ENDFUNCTION()

MACRO(SharemindCall f)
    SharemindCall_("${f}" ${ARGN})
    INCLUDE("${CMAKE_CURRENT_BINARY_DIR}/SharemindPolymorphism_${SharemindPolymorphism_CURRENT_LEVEL}.cmake")
ENDMACRO()


ENDIF() # SharemindPolymorphism_INCLUDED
