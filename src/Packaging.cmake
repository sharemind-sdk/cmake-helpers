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
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Polymorphism.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Variables.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Versioning.cmake")


FUNCTION(SharemindSetupPackaging)
    SharemindCheckUndefined(CPACK_PACKAGE_VERSION_MAJOR)
    SharemindCheckUndefined(CPACK_PACKAGE_VERSION_MINOR)
    SharemindCheckUndefined(CPACK_PACKAGE_VERSION_PATCH)
    SharemindCheckUndefined(CPACK_PACKAGE_VERSION)

    SharemindGenerateUniqueVariablePrefix(p)
    SharemindNewList(flags)
    SET(opts1 VENDOR VENDOR_CONTACT
              DEB_VENDOR_VERSION DEB_VENDOR_PREFIX DEB_COMPRESSION)
    SET(optsn GENERATORS)
    CMAKE_PARSE_ARGUMENTS("${p}" "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments("${p}")

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
    SharemindSetToDefaultIfEmpty("${p}_VENDOR" "Cybernetica AS")
    SET(CPACK_PACKAGE_VENDOR "${${p}_VENDOR}" PARENT_SCOPE)

    # Handle VENDOR_CONTACT:
    SharemindSetToDefaultIfEmpty("${p}_VENDOR_CONTACT"
        "Sharemind packaging <sharemind-packaging@cyber.ee>")
    SET(CPACK_PACKAGE_CONTACT "${${p}_VENDOR_CONTACT}" PARENT_SCOPE)

    # Handle GENERATORS:
    SharemindSetToDefaultIfEmpty("${p}_GENERATORS" "DEB")
    LIST(REMOVE_DUPLICATES "${p}_GENERATORS")
    SET(CPACK_GENERATOR "${${p}_GENERATORS}" PARENT_SCOPE)

    # Debian:
    FOREACH(generator IN LISTS "${p}_GENERATORS")
        IF("${generator}" STREQUAL "DEB")
            # Handle DEB_VENDOR_PREFIX and DEB_VENDOR_VERSION:
            SharemindSetToDefaultIfEmpty("${p}_DEB_VENDOR_PREFIX" "cyber")
            SharemindSetToDefaultIfEmpty("${p}_DEB_VENDOR_VERSION" "1")
            SET(s "$ENV{SHAREMIND_CPACK_DEB_VENDOR_VERSION_SUFFIX}")
            SET(CPACK_DEBIAN_PACKAGE_RELEASE
                "${${p}_DEB_VENDOR_PREFIX}${${p}_DEB_VENDOR_VERSION}${s}"
                PARENT_SCOPE)
            UNSET(s)

            # Handle DEB_COMPRESSION:
            # Use xz compression when building release packages and gzip otherwise
            IF(CMAKE_BUILD_TYPE STREQUAL "Release")
                SharemindSetToDefaultIfEmpty("${p}_DEB_COMPRESSION" "xz")
            ELSE()
                SharemindSetToDefaultIfEmpty("${p}_DEB_COMPRESSION" "gzip")
            ENDIF()

            SET(CPACK_DEBIAN_COMPRESSION_TYPE "${${p}_DEB_COMPRESSION}"
                PARENT_SCOPE)

            SET(CPACK_DEB_COMPONENT_INSTALL "ON" PARENT_SCOPE)
            SET(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT" PARENT_SCOPE)
        ENDIF()
    ENDFOREACH()
ENDFUNCTION()

FUNCTION(SharemindPackageInstallEmptyDirectories)
    SharemindGenerateUniqueVariablePrefix(p)
    SharemindNewList(flags)
    SET(opts1 COMPONENT)
    SET(optsn DIRECTORIES)
    CMAKE_PARSE_ARGUMENTS("${p}" "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments("${p}")

    FOREACH(dir IN LISTS "${p}_DIRECTORIES")
        GET_FILENAME_COMPONENT(name "${dir}" NAME)
        GET_FILENAME_COMPONENT(dir "${dir}" DIRECTORY)
        FILE(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/emptyDirs/${name}")
        IF("${${p}_COMPONENT}" STREQUAL "")
            INSTALL(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/emptyDirs/${name}"
                    DESTINATION "${dir}"
                    EXCLUDE_FROM_ALL)
        ELSE()
            INSTALL(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/emptyDirs/${name}"
                    DESTINATION "${dir}"
                    EXCLUDE_FROM_ALL
                    COMPONENT "${${p}_COMPONENT}")
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

    SharemindGenerateUniqueVariablePrefix(p)
    SharemindNewList(flags)
    SET(opts1 NAME DESCRIPTION
              DEB_NAME DEB_DESCRIPTION DEB_SECTION DEB_SOURCE
              OUTPUT_VAR_REGISTRY)
    SET(optsn
        DEB_BREAKS
        DEB_CONFLICTS
        DEB_DEPENDS
        DEB_ENHANCES
        DEB_EXTRA_CONTROL_FILES
        DEB_PREDEPENDS
        DEB_PROVIDES
        DEB_RECOMMENDS
        DEB_REPLACES
        DEB_SUGGESTS)
    CMAKE_PARSE_ARGUMENTS("${p}" "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments("${p}")

    SharemindSetToDefaultIfEmpty("${p}_NAME" "${component}")
    SharemindSetToDefaultIfEmpty("${p}_DESCRIPTION" "${${p}_NAME} package")

    FOREACH(e IN LISTS "${p}_DEB_EXTRA_CONTROL_FILES")
        IF(NOT (EXISTS "${e}"))
            MESSAGE(FATAL_ERROR
                    "\"${e}\" given in DEB_EXTRA_CONTROL_FILES does not exist!")
        ENDIF()
    ENDFOREACH()

    SharemindNewList(varRegistry)

    FOREACH(generator IN LISTS CPACK_GENERATOR)
        IF("${generator}" STREQUAL "DEB")
            CMAKE_POLICY(PUSH)
            CMAKE_POLICY(SET CMP0057 NEW)
            # https://www.debian.org/doc/debian-policy/ch-archive.html#sections:
            SET(validSections admin cli-mono comm database debug devel doc
                              editors education electronics embedded fonts games
                              gnome gnu-r gnustep graphics hamradio haskell
                              httpd interpreters introspection java javascript
                              kde kernel libdevel libs lisp localization mail
                              math metapackages misc net news ocaml oldlibs
                              otherosfs perl php python ruby rust science shells
                              sound tasks tex text utils vcs video web x11 xfce
                              zope)
            SharemindCheckArgument("${p}" "DEB_SECTION" REQUIRED NON_EMPTY)
            IF(NOT("${${p}_DEB_SECTION}" IN_LIST validSections))
                MESSAGE(FATAL_ERROR
                        "Invalid DEB_SECTION given: ${${p}_DEB_SECTION}")
            ENDIF()
            SharemindSetToDefaultIfEmpty("${p}_DEB_NAME" "${${p}_NAME}")
            SharemindSetToDefaultIfEmpty("${p}_DEB_DESCRIPTION"
                                         "${${p}_DESCRIPTION}")

            STRING(TOUPPER "${component}" C)
            SET(V_PACKAGE_NAME "CPACK_DEBIAN_${C}_PACKAGE_NAME")
            SET(V_PACKAGE_DESCRIPTION "CPACK_COMPONENT_${C}_DESCRIPTION")
            SET(V_PACKAGE_SECTION "CPACK_DEBIAN_${C}_PACKAGE_SECTION")
            SET(V_PACKAGE_EXTRA "CPACK_DEBIAN_${C}_PACKAGE_CONTROL_EXTRA")
            SET(V_PACKAGE_SOURCE "CPACK_DEBIAN_${C}_PACKAGE_SOURCE")

            SharemindRegisteredSet(varRegistry
                "${V_PACKAGE_NAME}" "${${p}_DEB_NAME}")
            SharemindRegisteredSet(varRegistry
                "${V_PACKAGE_DESCRIPTION}" "${${p}_DEB_DESCRIPTION}")
            SharemindRegisteredSet(varRegistry
                "${V_PACKAGE_SOURCE}" "${${p}_DEB_SOURCE}")

            SET(fieldsWithAlternatives DEPENDS PREDEPENDS RECOMMENDS SUGGESTS)
            FOREACH(field BREAKS CONFLICTS DEPENDS ENHANCES PREDEPENDS PROVIDES
                          RECOMMENDS REPLACES SUGGESTS)
                SET(V_PACKAGE_${field} "CPACK_DEBIAN_${C}_PACKAGE_${field}")
                IF(NOT ("${${p}_DEB_${field}}" STREQUAL ""))
                    SET(DEB_${field} "")
                    FOREACH(d IN LISTS "${p}_DEB_${field}")
                        STRING(STRIP "${d}" d)
                        IF("${DEB_${field}}" STREQUAL "")
                            IF(("${field}" IN_LIST fieldsWithAlternatives)
                               AND ("${d}" MATCHES "^\\|"))
                                STRING(SUBSTRING "${d}" 1 -1 d)
                                STRING(STRIP "${d}" DEB_${field})
                            ELSE()
                                SET(DEB_${field} "${d}")
                            ENDIF()
                        ELSE()
                            IF(("${field}" IN_LIST fieldsWithAlternatives)
                               AND ("${d}" MATCHES "^\\|"))
                                STRING(SUBSTRING "${d}" 1 -1 d)
                                STRING(STRIP "${d}" d)
                                SET(DEB_${field} "${DEB_${field}} | ${d}")
                            ELSE()
                                SET(DEB_${field} "${DEB_${field}}, ${d}")
                            ENDIF()
                        ENDIF()
                    ENDFOREACH()
                    IF("${field}" IN_LIST fieldsWithAlternatives)
                        STRING(REPLACE ";|" " |" "${p}_DEB_${field}"
                            "${${p}_DEB_${field}}")
                    ENDIF()
                    STRING(REPLACE ";" ", " "${p}_DEB_${field}"
                        "${${p}_DEB_${field}}")
                    SharemindRegisteredSet(varRegistry
                        "${V_PACKAGE_${field}}" "${DEB_${field}}")
                ENDIF()
            ENDFOREACH()
            CMAKE_POLICY(POP)

            IF(NOT ("${${p}_DEB_EXTRA_CONTROL_FILES}" STREQUAL ""))
                SharemindRegisteredSet(varRegistry
                    "${V_PACKAGE_EXTRA}" "${${p}_DEB_EXTRA_CONTROL_FILES}")
            ENDIF()

            SharemindRegisteredSet(varRegistry
                "${V_PACKAGE_SECTION}" "${${p}_DEB_SECTION}")
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
        "${CPACK_PACKAGE_VERSION}-${CPACK_DEBIAN_PACKAGE_RELEASE}")

    SharemindElevateRegisteredVariables(${varRegistry})
    IF(NOT ("${${p}_OUTPUT_VAR_REGISTRY}" STREQUAL ""))
        SET("${${p}_OUTPUT_VAR_REGISTRY}" ${varRegistry} PARENT_SCOPE)
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
        MESSAGE(FATAL_ERROR "Component \"${C}\" not packaged and not ignored!")
    ENDFOREACH()
ENDFUNCTION()

MACRO(SharemindPackagingFinalize)
    SharemindPackagingWarnOnUnpackagedComponents()
    INCLUDE(CPack)
ENDMACRO()
