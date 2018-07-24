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

IF(NOT DEFINED SharemindArguments_INCLUDED)
SET(SharemindArguments_INCLUDED TRUE)


FUNCTION(SharemindCheckRequiredArgument prefix argname)
    IF("${${prefix}_${argname}}" STREQUAL "")
        MESSAGE(FATAL_ERROR "Required ${argname} argument not given!")
    ENDIF()
ENDFUNCTION()

FUNCTION(SharemindCheckNoUnparsedArguments prefix)
    IF(DEFINED "${prefix}_UNPARSED_ARGUMENTS")
        MESSAGE(FATAL_ERROR
                "Unrecognized arguments: ${${prefix}_UNPARSED_ARGUMENTS}")
    ENDIF()
ENDFUNCTION()


ENDIF() # SharemindArguments_INCLUDED
