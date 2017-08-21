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

IF(NOT DEFINED SharemindSplitDebug_INCLUDED)
SET(SharemindSplitDebug_INCLUDED TRUE)


FUNCTION(SharemindSplitDebug_ targetName destination)
    IF(NOT TARGET "${targetName}")
        MESSAGE(FATAL_ERROR "No such target: ${targetName}")
    ENDIF()

    FIND_PROGRAM(objcopy NAMES "objcopy"
                               "${CMAKE_LIBRARY_ARCHITECTURE}-objcopy")
    IF(NOT objcopy)
        MESSAGE(FATAL_ERROR "Required program not found: objcopy")
    ENDIF()
    ADD_CUSTOM_COMMAND(TARGET "${targetName}" POST_BUILD
        COMMAND "${objcopy}" "--compress-debug-sections"
                             "$<TARGET_FILE:${targetName}>"
                             "$<TARGET_FILE:${targetName}>.debug"
        COMMAND "${objcopy}"
                "--strip-unneeded"
                "--remove-section=.comment"
                "--remove-section=.note"
                "--remove-section=.note.*"
                "--add-gnu-debuglink=$<TARGET_FILE:${targetName}>.debug"
                "$<TARGET_FILE:${targetName}>"
    )
    INSTALL(FILES "$<TARGET_FILE:${targetName}>.debug"
            DESTINATION "${destination}"
            COMPONENT "debug")
ENDFUNCTION()

FUNCTION(SharemindLibraryAddSplitDebug targetName)
    SharemindSplitDebug_("${targetName}" "lib/debug/usr/lib" ${ARGN})
ENDFUNCTION()

FUNCTION(SharemindExecutableAddSplitDebug targetName)
    SharemindSplitDebug_("${targetName}" "lib/debug/usr/bin" ${ARGN})
ENDFUNCTION()


ENDIF() # SharemindSplitDebug_INCLUDED
