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

IF(NOT DEFINED SharemindSharedLibrary_INCLUDED)
SET(SharemindSharedLibrary_INCLUDED TRUE)


INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Arguments.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Lists.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/SplitDebug.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Targets.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Versioning.cmake")
INCLUDE(CMakeParseArguments)

FUNCTION(SharemindAddSharedLibrary name)
    IF("${name}" STREQUAL "")
        MESSAGE(FATAL_ERROR "Empty name given!")
    ENDIF()

    SET(flags NO_SPLITDEBUG MODULE)
    SET(opts1 OUTPUT_NAME VERSION SOVERSION)
    SET(optsn SOURCES INCLUDE_DIRECTORIES COMPILE_DEFINITIONS COMPILE_FLAGS
                      LINK_LIBRARIES LEGACY_DEFINITIONS)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments(CPA)

    # Handle VERSION:
    IF("${CPA_VERSION}" STREQUAL "")
        IF(NOT ("${PROJECT_VERSION}" STREQUAL ""))
            SET(CPA_VERSION "${PROJECT_VERSION}")
        ELSE()
            MESSAGE(FATAL_ERROR
                    "VERSION not given and PROJECT_VERSION not set!")
        ENDIF()
    ENDIF()
    SharemindCheckNumericVersionSyntax("${CPA_VERSION}")

    # Handle SOVERSION:
    IF("${CPA_SOVERSION}" STREQUAL "")
        SharemindNumericVersionToList("${CPA_VERSION}" vl)
        SharemindListExtractFromHead("${vl}" soversion_major soversion_minor)
        SET(CPA_SOVERSION "${soversion_major}.${soversion_minor}")
    ENDIF()

    # Handle SOURCES:
    IF("${CPA_SOURCES}" STREQUAL "")
        MESSAGE(FATAL_ERROR "No valid SOURCES given!")
    ENDIF()

    IF("${CPA_MODULE}")
        SET(type MODULE)
    ELSE()
        SET(type SHARED)
    ENDIF()

    ADD_LIBRARY("${name}" "${type}" ${CPA_SOURCES})
    SET_TARGET_PROPERTIES("${name}" PROPERTIES
                          VERSION "${CPA_VERSION}"
                          SOVERSION "${CPA_SOVERSION}")

    # Handle OUTPUT_NAME:
    IF(NOT ("${CPA_OUTPUT_NAME}" STREQUAL ""))
        SET_TARGET_PROPERTIES("${name}" PROPERTIES
                              OUTPUT_NAME "${CPA_OUTPUT_NAME}")
    ENDIF()

    SharemindTargetSetCommonProperties("${name}"
                                       "${CPA_INCLUDE_DIRECTORIES}"
                                       "${CPA_COMPILE_DEFINITIONS}"
                                       "${CPA_COMPILE_FLAGS}"
                                       "${CPA_LINK_LIBRARIES}"
                                       "${CPA_LEGACY_DEFINITIONS}")
    INSTALL(TARGETS "${name}" LIBRARY DESTINATION "lib" COMPONENT "lib")

    # Handle split debug files:
    IF(NOT "${CPA_NO_SPLITDEBUG}")
        SharemindLibraryAddSplitDebug("${name}")
    ENDIF()
ENDFUNCTION()


ENDIF() # SharemindSharedLibrary_INCLUDED
