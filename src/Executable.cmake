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

IF(NOT DEFINED SharemindExecutable_INCLUDED)
SET(SharemindExecutable_INCLUDED TRUE)


INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Arguments.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/SplitDebug.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Targets.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Versioning.cmake")
INCLUDE(CMakeParseArguments)

FUNCTION(SharemindAddExecutable name)
    IF("${name}" STREQUAL "")
        MESSAGE(FATAL_ERROR "Empty name given!")
    ENDIF()

    SET(flags NO_SPLITDEBUG)
    SET(opts1 OUTPUT_NAME VERSION)
    SET(optsn SOURCES INCLUDE_DIRECTORIES COMPILE_DEFINITIONS LINK_LIBRARIES)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments(CPA)

    # Handle SOURCES:
    IF("${CPA_SOURCES}" STREQUAL "")
        MESSAGE(FATAL_ERROR "No valid SOURCES given!")
    ENDIF()

    ADD_EXECUTABLE("${name}" ${CPA_SOURCES})

    # Handle OUTPUT_NAME:
    IF(NOT ("${CPA_OUTPUT_NAME}" STREQUAL ""))
        SET_TARGET_PROPERTIES("${name}" PROPERTIES
                              OUTPUT_NAME "${CPA_OUTPUT_NAME}")
    ENDIF()

    # Handle VERSION:
    IF(NOT ("${CPA_VERSION}" STREQUAL ""))
        SharemindCheckNumericVersionSyntax("${CPA_VERSION}")
        SET_TARGET_PROPERTIES("${name}" PROPERTIES VERSION "${CPA_VERSION}")
    ENDIF()

    SharemindTargetSetPropertiesIfNonEmpty("${name}" INCLUDE_DIRECTORIES
                                           "${CPA_INCLUDE_DIRECTORIES}")
    SharemindTargetSetPropertiesIfNonEmpty("${name}" COMPILE_DEFINITIONS
                                           "${CPA_COMPILE_DEFINITIONS}")
    SharemindTargetSetPropertiesIfNonEmpty("${name}" LINK_LIBRARIES
                                           "${CPA_LINK_LIBRARIES}")
    INSTALL(TARGETS "${name}" RUNTIME DESTINATION "bin" COMPONENT "bin")

    # Handle split debug files:
    IF(NOT "${CPA_NO_SPLITDEBUG}")
        SharemindExecutableAddSplitDebug("${name}")
    ENDIF()
ENDFUNCTION()


ENDIF() # SharemindExecutable_INCLUDED
