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
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Lists.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/SplitDebug.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Targets.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Variables.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Versioning.cmake")

FUNCTION(SharemindAddExecutable name)
    IF("${name}" STREQUAL "")
        MESSAGE(FATAL_ERROR "Empty name given!")
    ENDIF()

    SharemindGenerateUniqueVariablePrefix(p)
    SET(flags NO_SPLITDEBUG)
    SET(opts1 OUTPUT_NAME VERSION COMPONENT SPLITDEBUG_COMPONENT)
    SET(optsn SOURCES INCLUDE_DIRECTORIES COMPILE_DEFINITIONS COMPILE_FLAGS
                      LINK_LIBRARIES LINK_FLAGS LEGACY_DEFINITIONS)
    CMAKE_PARSE_ARGUMENTS("${p}" "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments("${p}")

    # Handle SOURCES:
    IF("${${p}_SOURCES}" STREQUAL "")
        MESSAGE(FATAL_ERROR "No valid SOURCES given!")
    ENDIF()

    SharemindListMaybeSortByFileSize("${${p}_SOURCES}" ${p}_SOURCES)
    ADD_EXECUTABLE("${name}" ${${p}_SOURCES})

    # Handle OUTPUT_NAME:
    IF(NOT ("${${p}_OUTPUT_NAME}" STREQUAL ""))
        SET_TARGET_PROPERTIES("${name}" PROPERTIES
                              OUTPUT_NAME "${${p}_OUTPUT_NAME}")
    ENDIF()

    # Handle VERSION:
    IF(NOT ("${${p}_VERSION}" STREQUAL ""))
        SharemindCheckNumericVersionSyntax("${${p}_VERSION}")
        SET_TARGET_PROPERTIES("${name}" PROPERTIES VERSION "${${p}_VERSION}")
    ENDIF()

    SharemindListAppendUnique(${p}_LINK_FLAGS "-Wl,--as-needed"
                                              "-Wl,--no-undefined"
                                              "-Wl,--no-allow-shlib-undefined")

    SharemindTargetSetCommonProperties("${name}"
                                       "${${p}_INCLUDE_DIRECTORIES}"
                                       "${${p}_COMPILE_DEFINITIONS}"
                                       "${${p}_COMPILE_FLAGS}"
                                       "${${p}_LINK_LIBRARIES}"
                                       "${${p}_LINK_FLAGS}"
                                       "${${p}_LEGACY_DEFINITIONS}")

    # Handle COMPONENT:
    IF("${${p}_COMPONENT}" STREQUAL "")
        SET(${p}_COMPONENT "bin")
    ENDIF()
    INSTALL(TARGETS "${name}"
            EXPORT "${name}-Export"
            RUNTIME DESTINATION "bin"
            COMPONENT "${${p}_COMPONENT}")

    # Handle split debug files:
    IF(NOT "${${p}_NO_SPLITDEBUG}")
        # Handle SPLITDEBUG_COMPONENT:
        IF("${${p}_SPLITDEBUG_COMPONENT}" STREQUAL "")
            SET(${p}_SPLITDEBUG_COMPONENT "debug")
        ENDIF()
        SharemindExecutableAddSplitDebug("${name}"
            COMPONENT "${${p}_SPLITDEBUG_COMPONENT}"
        )
    ENDIF()
ENDFUNCTION()
