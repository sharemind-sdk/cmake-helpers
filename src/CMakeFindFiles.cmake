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
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/CMakeHelpersDir.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/ConfigureFile.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Variables.cmake")
INCLUDE(CMakePackageConfigHelpers)
INCLUDE(CMakeParseArguments)

FUNCTION(SharemindUseCMakeFindFiles)
    SharemindGenerateUniqueVariablePrefix(p)
    SharemindNewList(flags)
    SET(opts1 PROJECT_NAME COMPONENT)
    SharemindNewList(optsn)
    CMAKE_PARSE_ARGUMENTS("${p}" "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments("${p}")

    # Handle PROJECT_NAME:
    IF("${${p}_PROJECT_NAME}" STREQUAL "")
        SET(${p}_PROJECT_NAME "${CMAKE_PROJECT_NAME}")
    ENDIF()

    # Handle COMPONENT:
    IF("${${p}_COMPONENT}" STREQUAL "")
        SET(${p}_COMPONENT "dev")
    ENDIF()

    ADD_CUSTOM_TARGET(
        "include_${${p}_PROJECT_NAME}_CMakeFindFiles_in_IDE" SOURCES
        "${CMAKE_CURRENT_SOURCE_DIR}/${${p}_PROJECT_NAME}Config.cmake.in"
        "${CMAKE_CURRENT_SOURCE_DIR}/${${p}_PROJECT_NAME}ConfigVersion.cmake.in")
    CONFIGURE_FILE(
        "${CMAKE_CURRENT_SOURCE_DIR}/${${p}_PROJECT_NAME}Config.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/${${p}_PROJECT_NAME}Config.cmake" @ONLY)
    CONFIGURE_FILE(
        "${CMAKE_CURRENT_SOURCE_DIR}/${${p}_PROJECT_NAME}ConfigVersion.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/${${p}_PROJECT_NAME}ConfigVersion.cmake"
        @ONLY)
    INSTALL(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/${${p}_PROJECT_NAME}Config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/${${p}_PROJECT_NAME}ConfigVersion.cmake"
        DESTINATION "lib/${${p}_PROJECT_NAME}"
        COMPONENT "${${p}_COMPONENT}")
ENDFUNCTION()

FUNCTION(SharemindCreateCMakeFindFiles)
    SharemindGenerateUniqueVariablePrefix(p)
    SharemindNewList(flags)
    SET(opts1 PROJECT_NAME COMPONENT VERSION)
    SET(optsn INCLUDE_DIRS LIBRARIES DEFINITIONS)
    CMAKE_PARSE_ARGUMENTS("${p}" "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments("${p}")

    # Handle PROJECT_NAME:
    IF("${${p}_PROJECT_NAME}" STREQUAL "")
        SET(${p}_PROJECT_NAME "${CMAKE_PROJECT_NAME}")
    ENDIF()

    # Handle COMPONENT:
    IF("${${p}_COMPONENT}" STREQUAL "")
        SET(${p}_COMPONENT "dev")
    ENDIF()

    # Handle VERSION:
    IF("${${p}_VERSION}" STREQUAL "")
        IF("${PROJECT_VERSION}" STREQUAL "")
            MESSAGE(FATAL_ERROR
                    "VERSION not given and variable PROJECT_VERSION is empty!")
        ENDIF()
        SET(${p}_VERSION "${PROJECT_VERSION}")
    ENDIF()

    SharemindNewUniqueList(${p}_INCLUDE_DIRS ${${p}_INCLUDE_DIRS})
    SharemindNewUniqueList(${p}_LIBRARIES "-Wl,--as-needed" ${${p}_LIBRARIES})
    SharemindNewUniqueList(${p}_DEFINITIONS ${${p}_DEFINITIONS})

    SharemindConfigureFile(
        "${SharemindCMakeHelpersDir}/FindFileConfig.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/${${p}_PROJECT_NAME}Config.cmake"
        "@CPA_PROJECT_NAME@" "${p}_PROJECT_NAME"
        "@CPA_INCLUDE_DIRS@" "${p}_INCLUDE_DIRS"
        "@CPA_LIBRARIES@" "${p}_LIBRARIES"
        "@CPA_DEFINITIONS@" "${p}_DEFINITIONS")
    SharemindConfigureFile(
        "${SharemindCMakeHelpersDir}/FindFileConfigVersion.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/${${p}_PROJECT_NAME}ConfigVersion.cmake"
        "@CPA_PROJECT_NAME@" "${p}_PROJECT_NAME"
        "@CPA_VERSION@" "${p}_VERSION")
    INSTALL(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/${${p}_PROJECT_NAME}Config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/${${p}_PROJECT_NAME}ConfigVersion.cmake"
        DESTINATION "lib/${${p}_PROJECT_NAME}"
        COMPONENT "${${p}_COMPONENT}")
ENDFUNCTION()

FUNCTION(SharemindCreateCMakeFindFilesForTarget target)
    IF("${target}" STREQUAL "")
        MESSAGE(FATAL_ERROR "Emtpy target name given!")
    ENDIF()

    SharemindGenerateUniqueVariablePrefix(p)
    SharemindNewList(flags)
    SET(opts1 NAMESPACE COMPONENT VERSION COMPATIBILITY PACKAGE_NAME)
    CMAKE_PARSE_ARGUMENTS("${p}" "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments("${p}")

    # Handle NAMESPACE:
    IF("${${p}_NAMESPACE}" STREQUAL "")
        SET(${p}_NAMESPACE "Sharemind")
    ENDIF()

    # Handle COMPONENT:
    IF("${${p}_COMPONENT}" STREQUAL "")
        SET(${p}_COMPONENT "dev")
    ENDIF()

    # Handle VERSION:
    IF("${${p}_VERSION}" STREQUAL "")
        IF("${PROJECT_VERSION}" STREQUAL "")
            MESSAGE(FATAL_ERROR
                    "VERSION not given and variable PROJECT_VERSION is empty!")
        ENDIF()
        SET(${p}_VERSION "${PROJECT_VERSION}")
    ENDIF()

    # Handle COMPATIBILITY:
    IF("${${p}_COMPATIBILITY}" STREQUAL "")
        SET(${p}_COMPATIBILITY "SameMinorVersion")
    ENDIF()

    # Handle PACKAGE_NAME:
    IF("${${p}_PACKAGE_NAME}" STREQUAL "")
        IF("${${p}_NAMESPACE}" STREQUAL "${target}")
            SET(${p}_PACKAGE_NAME "${target}")
        ELSE()
            SET(${p}_PACKAGE_NAME "${${p}_NAMESPACE}${target}")
        ENDIF()
    ENDIF()

    INSTALL(TARGETS "${target}" EXPORT "${target}Export" COMPONENT "dev")
    INSTALL(EXPORT "${target}Export"
        NAMESPACE "${${p}_NAMESPACE}::"
        FILE "${${p}_PACKAGE_NAME}Config.cmake"
        DESTINATION "lib/cmake/${${p}_PACKAGE_NAME}"
        COMPONENT "dev")
    WRITE_BASIC_PACKAGE_VERSION_FILE(
        "${CMAKE_CURRENT_BINARY_DIR}/${${p}_PACKAGE_NAME}ConfigVersion.cmake"
        VERSION "${${p}_VERSION}"
        COMPATIBILITY "${${p}_COMPATIBILITY}")
    INSTALL(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/${${p}_PACKAGE_NAME}ConfigVersion.cmake"
        DESTINATION "lib/cmake/${${p}_PACKAGE_NAME}"
        COMPONENT "${${p}_COMPONENT}")
ENDFUNCTION()
