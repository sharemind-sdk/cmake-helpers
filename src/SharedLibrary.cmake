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

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Arguments.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/CompileOptions.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Lists.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/SplitDebug.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Variables.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Versioning.cmake")


FUNCTION(SharemindAddSharedLibrary name)
    IF("${name}" STREQUAL "")
        MESSAGE(FATAL_ERROR "Empty name given!")
    ENDIF()

    SharemindGenerateUniqueVariablePrefix(p)
    SET(flags NO_SPLITDEBUG MODULE)
    SET(opts1 OUTPUT_NAME VERSION SOVERSION COMPONENT SPLITDEBUG_COMPONENT STD)
    SET(optsn SOURCES)
    CMAKE_PARSE_ARGUMENTS("${p}" "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments("${p}")

    # Handle VERSION:
    IF("${${p}_VERSION}" STREQUAL "")
        IF(NOT ("${PROJECT_VERSION}" STREQUAL ""))
            SET("${p}_VERSION" "${PROJECT_VERSION}")
        ELSE()
            MESSAGE(FATAL_ERROR
                    "VERSION not given and PROJECT_VERSION not set!")
        ENDIF()
    ENDIF()
    SharemindCheckNumericVersionSyntax("${${p}_VERSION}")

    # Handle SOVERSION:
    IF("${${p}_SOVERSION}" STREQUAL "")
        SharemindNumericVersionToList("${${p}_VERSION}" vl)
        SharemindListExtractFromHead("${vl}" soversion_major soversion_minor)
        SET("${p}_SOVERSION" "${soversion_major}.${soversion_minor}")
    ENDIF()

    # Handle SOURCES:
    IF("${${p}_SOURCES}" STREQUAL "")
        MESSAGE(FATAL_ERROR "No valid SOURCES given!")
    ENDIF()

    IF("${${p}_MODULE}")
        SET(type MODULE)
    ELSE()
        SET(type SHARED)
    ENDIF()

    SharemindListMaybeSortByFileSize("${${p}_SOURCES}" "${p}_SOURCES")
    ADD_LIBRARY("${name}" "${type}" ${${p}_SOURCES})
    SET_TARGET_PROPERTIES("${name}" PROPERTIES
                          VERSION "${${p}_VERSION}"
                          SOVERSION "${${p}_SOVERSION}")
    TARGET_LINK_OPTIONS("${name}"
        PRIVATE
            "-Wl,--as-needed"
            "-Wl,--no-undefined"
            "-Wl,--no-allow-shlib-undefined"
        )

    # Handle OUTPUT_NAME:
    IF(NOT ("${${p}_OUTPUT_NAME}" STREQUAL ""))
        SET_TARGET_PROPERTIES("${name}" PROPERTIES
                              OUTPUT_NAME "${${p}_OUTPUT_NAME}")
    ENDIF()

    # Handle STD:
    SharemindSetCompileOptionsFromStd("${name}" "${${p}_STD}")

    # Handle COMPONENT:
    IF("${${p}_COMPONENT}" STREQUAL "")
       SET("${p}_COMPONENT" "lib")
    ENDIF()

    INSTALL(TARGETS "${name}"
            EXPORT "${name}-Export"
            LIBRARY DESTINATION "lib"
            COMPONENT "${${p}_COMPONENT}")

    # Handle split debug files:
    IF(NOT "${${p}_NO_SPLITDEBUG}")
        # Handle SPLITDEBUG_COMPONENT:
        IF("${${p}_SPLITDEBUG_COMPONENT}" STREQUAL "")
           SET("${p}_SPLITDEBUG_COMPONENT" "debug")
        ENDIF()
        SharemindLibraryAddSplitDebug("${name}"
                                      COMPONENT "${${p}_SPLITDEBUG_COMPONENT}")
    ENDIF()
ENDFUNCTION()
