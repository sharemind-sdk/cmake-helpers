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

IF(NOT DEFINED SharemindPackaging_INCLUDED)
SET(SharemindPackaging_INCLUDED TRUE)


INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Arguments.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Lists.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Polymorphism.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Variables.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Versioning.cmake")
INCLUDE(CMakeParseArguments)

FUNCTION(SharemindSetupPackaging)
    SharemindCheckUndefined(CPACK_PACKAGE_VERSION_MAJOR)
    SharemindCheckUndefined(CPACK_PACKAGE_VERSION_MINOR)
    SharemindCheckUndefined(CPACK_PACKAGE_VERSION_PATCH)
    SharemindCheckUndefined(CPACK_PACKAGE_VERSION)

    SharemindNewList(flags)
    SET(opts1 VENDOR VENDOR_CONTACT
              DEB_VENDOR_VERSION DEB_VENDOR_PREFIX DEB_COMPRESSION)
    SET(optsn GENERATORS)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments(CPA)

    # Populate CPACK_PACKAGE_VERSION* variables from PROJECT_VERSION:
    SharemindNormalizeVersion(VERSION "${PROJECT_VERSION}"
                              OUTPUT_VARIABLE vl)
    SharemindNumericVersionToList("${vl}" vl)
    SharemindListExtractFromHead("${vl}" v1 v2 v3)
    SET(CPACK_PACKAGE_VERSION_MAJOR "${v1}" PARENT_SCOPE)
    SET(CPACK_PACKAGE_VERSION_MINOR "${v2}" PARENT_SCOPE)
    SET(CPACK_PACKAGE_VERSION_PATCH "${v3}" PARENT_SCOPE)
    SET(CPACK_PACKAGE_VERSION "${v1}.${v2}.${v3}" PARENT_SCOPE)


    # Initialize an empty CPACK_COMPONENTS_ALL, so that by default, no packages
    # are generated.
    SET(CPACK_COMPONENTS_ALL PARENT_SCOPE)

    # The list of components ignored by packaging:
    SET(SHAREMIND_PACKAGING_IGNORED_COMPONENTS PARENT_SCOPE)

    # Handle VENDOR:
    SharemindSetToDefaultIfEmpty(CPA_VENDOR "Cybernetica AS")
    SET(CPACK_PACKAGE_VENDOR "${CPA_VENDOR}" PARENT_SCOPE)

    # Handle VENDOR_CONTACT:
    SharemindSetToDefaultIfEmpty(CPA_VENDOR_CONTACT
        "Sharemind packaging <sharemind-packaging@cyber.ee>")
    SET(CPACK_PACKAGE_CONTACT "${CPA_VENDOR_CONTACT}" PARENT_SCOPE)

    # Handle GENERATORS:
    SharemindSetToDefaultIfEmpty(CPA_GENERATORS "DEB")
    LIST(REMOVE_DUPLICATES CPA_GENERATORS)
    SET(CPACK_GENERATOR "${CPA_GENERATORS}" PARENT_SCOPE)

    # Debian:
    FOREACH(generator IN LISTS CPA_GENERATORS)
        IF("${generator}" STREQUAL "DEB")
            # Handle DEB_VENDOR_PREFIX and DEB_VENDOR_VERSION:
            SharemindSetToDefaultIfEmpty(CPA_DEB_VENDOR_PREFIX "cyber")
            SharemindSetToDefaultIfEmpty(CPA_DEB_VENDOR_VERSION "1")
            SET(s "$ENV{SHAREMIND_CPACK_DEB_VENDOR_VERSION_SUFFIX}")
            SET(CPACK_DEBIAN_PACKAGE_RELEASE
                "${CPA_DEB_VENDOR_PREFIX}${CPA_DEB_VENDOR_VERSION}${s}"
                PARENT_SCOPE)
            UNSET(s)

            # Handle DEB_COMPRESSION:
            SharemindSetToDefaultIfEmpty(CPA_DEB_COMPRESSION "xz")
            SET(CPACK_DEBIAN_COMPRESSION_TYPE "${CPA_DEB_COMPRESSION}"
                PARENT_SCOPE)

            SET(CPACK_DEB_COMPONENT_INSTALL "ON" PARENT_SCOPE)
            SET(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT" PARENT_SCOPE)
        ENDIF()
    ENDFOREACH()
ENDFUNCTION()

FUNCTION(SharemindPackageInstallEmptyDirectories)
    SharemindNewList(flags)
    SET(opts1 COMPONENT)
    SET(optsn DIRECTORIES)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments(CPA)

    FOREACH(dir IN LISTS CPA_DIRECTORIES)
        GET_FILENAME_COMPONENT(name "${dir}" NAME)
        GET_FILENAME_COMPONENT(dir "${dir}" DIRECTORY)
        FILE(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/emptyDirs/${name}")
        IF("${CPA_COMPONENT}" STREQUAL "")
            INSTALL(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/emptyDirs/${name}"
                    DESTINATION "${dir}"
                    EXCLUDE_FROM_ALL)
        ELSE()
            INSTALL(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/emptyDirs/${name}"
                    DESTINATION "${dir}"
                    EXCLUDE_FROM_ALL
                    COMPONENT "${CPA_COMPONENT}")
        ENDIF()
    ENDFOREACH()
ENDFUNCTION()

FUNCTION(SharemindPackagingFailIfComponentAlreadyHandled c)
    LIST(FIND CPACK_COMPONENTS_ALL "${c}" index)
    IF(NOT (index EQUAL -1))
        MESSAGE(FATAL_ERROR
                "Component ${c} has already been added to packaging!")
    ENDIF()
    LIST(FIND SHAREMIND_PACKAGING_IGNORED_COMPONENTS "${c}" index)
    IF(NOT (index EQUAL -1))
        MESSAGE(FATAL_ERROR
            "Component ${c} has already been set to be ignored by packaging!")
    ENDIF()
ENDFUNCTION()

FUNCTION(SharemindAddComponentPackage_ component)
    IF("${component}" STREQUAL "")
        MESSAGE(FATAL_ERROR "Invalid component name given: ${component}")
    ENDIF()
    GET_CMAKE_PROPERTY(components COMPONENTS)
    LIST(FIND components "${component}" i)
    IF("${i}" EQUAL -1)
        MESSAGE(FATAL_ERROR "Component not found: ${component}")
    ENDIF()

    SharemindNewList(flags)
    SET(opts1 NAME DESCRIPTION
              DEB_NAME DEB_DESCRIPTION DEB_SECTION OUTPUT_VAR_REGISTRY)
    SET(optsn DEB_DEPENDS DEB_EXTRA_CONTROL_FILES)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments(CPA)

    SharemindSetToDefaultIfEmpty(CPA_NAME "${component}")
    SharemindSetToDefaultIfEmpty(CPA_DESCRIPTION "${CPA_NAME} package")

    FOREACH(e IN LISTS CPA_DEB_EXTRA_CONTROL_FILES)
        IF(NOT (EXISTS "${e}"))
            MESSAGE(FATAL_ERROR
                    "\"${e}\" given in DEB_EXTRA_CONTROL_FILES does not exist!")
        ENDIF()
    ENDFOREACH()

    SharemindNewList(varRegistry)

    FOREACH(generator IN LISTS CPACK_GENERATOR)
        IF("${generator}" STREQUAL "DEB")
            SharemindCheckRequiredArgument(CPA DEB_SECTION)
            SharemindSetToDefaultIfEmpty(CPA_DEB_NAME "${CPA_NAME}")
            SharemindSetToDefaultIfEmpty(CPA_DEB_DESCRIPTION
                                         "${CPA_DESCRIPTION}")

            STRING(TOUPPER "${component}" C)
            SET(V_PACKAGE_NAME "CPACK_DEBIAN_${C}_PACKAGE_NAME")
            SET(V_PACKAGE_DESCRIPTION "CPACK_COMPONENT_${C}_DESCRIPTION")
            SET(V_PACKAGE_SECTION "CPACK_DEBIAN_${C}_PACKAGE_SECTION")
            SET(V_PACKAGE_DEPENDS "CPACK_DEBIAN_${C}_PACKAGE_DEPENDS")
            SET(V_PACKAGE_EXTRA "CPACK_DEBIAN_${C}_PACKAGE_CONTROL_EXTRA")

            SharemindRegisteredSet(varRegistry
                "${V_PACKAGE_NAME}" "${CPA_DEB_NAME}")
            SharemindRegisteredSet(varRegistry
                "${V_PACKAGE_DESCRIPTION}" "${CPA_DEB_DESCRIPTION}")
            IF(NOT ("${CPA_DEB_DEPENDS}" STREQUAL ""))
                SET(DEB_DEPENDS "")
                FOREACH(d IN LISTS CPA_DEB_DEPENDS)
                    STRING(STRIP "${d}" d)
                    IF("${DEB_DEPENDS}" STREQUAL "")
                        IF("${d}" MATCHES "^\\|")
                            STRING(SUBSTRING "${d}" 1 -1 d)
                            STRING(STRIP "${d}" DEB_DEPENDS)
                        ELSE()
                            SET(DEB_DEPENDS "${d}")
                        ENDIF()
                    ELSE()
                        IF("${d}" MATCHES "^\\|")
                            STRING(SUBSTRING "${d}" 1 -1 d)
                            STRING(STRIP "${d}" d)
                            SET(DEB_DEPENDS "${DEB_DEPENDS} | ${d}")
                        ELSE()
                            SET(DEB_DEPENDS "${DEB_DEPENDS}, ${d}")
                        ENDIF()
                    ENDIF()
                ENDFOREACH()
                STRING(REPLACE ";|" " |" CPA_DEB_DEPENDS "${CPA_DEB_DEPENDS}")
                STRING(REPLACE ";" ", " CPA_DEB_DEPENDS "${CPA_DEB_DEPENDS}")
                SharemindRegisteredSet(varRegistry
                    "${V_PACKAGE_DEPENDS}" "${DEB_DEPENDS}")
            ENDIF()

            IF(NOT ("${CPA_DEB_EXTRA_CONTROL_FILES}" STREQUAL ""))
                SharemindRegisteredSet(varRegistry
                    "${V_PACKAGE_EXTRA}" "${CPA_DEB_EXTRA_CONTROL_FILES}")
            ENDIF()

            SharemindRegisteredSet(varRegistry
                "${V_PACKAGE_SECTION}" "${CPA_DEB_SECTION}")
        ENDIF()
    ENDFOREACH()

    # Mark component as enabled for CPACK:
    SharemindListAppendUnique(CPACK_COMPONENTS_ALL "${component}")
    SharemindRegisteredSet(varRegistry CPACK_COMPONENTS_ALL
                           "${CPACK_COMPONENTS_ALL}")

    # CPACK_DEBIAN_PACKAGE_RELEASE is set by SharemindSetupPackaging
    # Currently component-specific versioning is not supported
    SharemindRegisteredSet(varRegistry
        "${CMAKE_PROJECT_NAME}_DEB_${component}_PACKAGE_VERSION"
        "${PROJECT_VERSION}-${CPACK_DEBIAN_PACKAGE_RELEASE}")

    SharemindElevateRegisteredVariables(${varRegistry})
    IF(NOT ("${CPA_OUTPUT_VAR_REGISTRY}" STREQUAL ""))
        SET("${CPA_OUTPUT_VAR_REGISTRY}" ${varRegistry} PARENT_SCOPE)
    ENDIF()
ENDFUNCTION()
MACRO(SharemindAddComponentPackage component)
    SharemindPackagingFailIfComponentAlreadyHandled("${component}")
    CMAKE_PARSE_ARGUMENTS(SharemindAddComponentPackage_tmp_CPA
        "PARENT_SCOPE" "" "" ${ARGN})
    IF(SharemindAddComponentPackage_tmp_CPA_PARENT_SCOPE)
        UNSET(SharemindAddComponentPackage_tmp_CPA_PARENT_SCOPE)
        SharemindAddComponentPackage_("${component}"
            OUTPUT_VAR_REGISTRY SharemindAddComponentPackage_tmp_vars
            ${SharemindAddComponentPackage_tmp_CPA_UNPARSED_ARGUMENTS})
        SharemindElevateRegisteredVariables(
            ${SharemindAddComponentPackage_tmp_vars})
        UNSET(SharemindAddComponentPackage_tmp_vars)
    ELSE()
        UNSET(SharemindAddComponentPackage_tmp_CPA_PARENT_SCOPE)
        SharemindAddComponentPackage_("${component}"
            ${SharemindAddComponentPackage_tmp_CPA_UNPARSED_ARGUMENTS})
    ENDIF()
    UNSET(SharemindAddComponentPackage_tmp_CPA_UNPARSED_ARGUMENTS)
ENDMACRO()

FUNCTION(SharemindPackagingIgnoreComponent_ component)
    SET(scope "")
    IF("${ARGC}" GREATER 1)
        IF(NOT ("${ARGN}" STREQUAL "PARENT_SCOPE"))
            MESSAGE(FATAL_ERROR "Invalid arguments given!")
        ENDIF()
        SET(scope " PARENT_SCOPE")
    ENDIF()
    SharemindPackagingFailIfComponentAlreadyHandled(${component})
    SharemindListAppendUnique(SHAREMIND_PACKAGING_IGNORED_COMPONENTS
        "${component}")
    STRING(CONCAT out
        "SET(SHAREMIND_PACKAGING_IGNORED_COMPONENTS \""
        "${SHAREMIND_PACKAGING_IGNORED_COMPONENTS}"
        "\"${scope})")
    SET(SharemindPackagingIgnoreComponent_tmp "${out}" PARENT_SCOPE)
ENDFUNCTION()
MACRO(SharemindPackagingIgnoreComponent)
    SharemindPackagingIgnoreComponent_(${ARGN})
    SharemindCreateEvalFile("${SharemindPackagingIgnoreComponent_tmp}"
                            SharemindPackagingIgnoreComponent_tmp)
    INCLUDE("${SharemindPackagingIgnoreComponent_tmp}")
    UNSET(SharemindPackagingIgnoreComponents_tmp)
ENDMACRO()

FUNCTION(SharemindPackagingWarnOnUnpackagedComponents)
    # Retrieve a list of all known components:
    GET_CMAKE_PROPERTY(CS COMPONENTS)

    # Remove all from CS all components included in CPACK_COMPONENTS_ALL, using
    # foreach instead of just LIST(REMOVE_ITEM), because the latter would
    # require CPACK_COMPONENTS_ALL to be non-empty:
    FOREACH(C IN LISTS CPACK_COMPONENTS_ALL)
        LIST(REMOVE_ITEM CS "${C}")
    ENDFOREACH()

    # Remove all from CS all components included in
    # SHAREMIND_PACKAGING_IGNORED_COMPONENTS, using foreach instead of just
    # LIST(REMOVE_ITEM), because the latter would require
    # SHAREMIND_PACKAGING_IGNORED_COMPONENTS to be non-empty:
    FOREACH(C IN LISTS SHAREMIND_PACKAGING_IGNORED_COMPONENTS)
        LIST(REMOVE_ITEM CS "${C}")
    ENDFOREACH()

    # Warn about components not packaged or ignored:
    FOREACH(C IN LISTS CS)
        MESSAGE(WARNING "Component \"${C}\" not packaged and not ignored!")
    ENDFOREACH()
ENDFUNCTION()

MACRO(SharemindPackagingFinalize)
    SharemindPackagingWarnOnUnpackagedComponents()
    INCLUDE(CPack)
ENDMACRO()


ENDIF() # SharemindPackaging_INCLUDED
