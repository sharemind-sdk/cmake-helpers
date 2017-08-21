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

IF(NOT DEFINED SharemindCMakeFindFiles_INCLUDED)
SET(SharemindCMakeFindFiles_INCLUDED TRUE)


# TODO: Use CMakePackageConfigHelpers instead?

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Arguments.cmake")
INCLUDE(CMakeParseArguments)

FUNCTION(SharemindUseCMakeFindFiles)
    SharemindNewList(flags)
    SET(opts1 PROJECT_NAME COMPONENT)
    SharemindNewList(optsn)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments(CPA)

    # Handle PROJECT_NAME:
    IF("${CPA_PROJECT_NAME}" STREQUAL "")
        SET(CPA_PROJECT_NAME "${CMAKE_PROJECT_NAME}")
    ENDIF()

    # Handle COMPONENT:
    IF("${CPA_COMPONENT}" STREQUAL "")
        SET(CPA_COMPONENT "dev")
    ENDIF()

    ADD_CUSTOM_TARGET(
        "include_${CPA_PROJECT_NAME}_CMakeFindFiles_in_IDE" SOURCES
        "${CMAKE_CURRENT_SOURCE_DIR}/${CPA_PROJECT_NAME}Config.cmake.in"
        "${CMAKE_CURRENT_SOURCE_DIR}/${CPA_PROJECT_NAME}ConfigVersion.cmake.in")
    CONFIGURE_FILE(
        "${CMAKE_CURRENT_SOURCE_DIR}/${CPA_PROJECT_NAME}Config.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/${CPA_PROJECT_NAME}Config.cmake" @ONLY)
    CONFIGURE_FILE(
        "${CMAKE_CURRENT_SOURCE_DIR}/${CPA_PROJECT_NAME}ConfigVersion.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/${CPA_PROJECT_NAME}ConfigVersion.cmake"
        @ONLY)
    INSTALL(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/${CPA_PROJECT_NAME}Config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/${CPA_PROJECT_NAME}ConfigVersion.cmake"
        DESTINATION "lib/${CPA_PROJECT_NAME}"
        COMPONENT "${CPA_COMPONENT}")
ENDFUNCTION()


ENDIF() # SharemindCMakeFindFiles_INCLUDED
