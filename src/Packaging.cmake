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

IF(NOT DEFINED SharemindPackaging_INCLUDED)
SET(SharemindPackaging_INCLUDED TRUE)


INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Arguments.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Lists.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Variables.cmake")
INCLUDE(CMakeParseArguments)

FUNCTION(SharemindSetupPackaging)
    SharemindNewList(flags)
    SET(opts1 VENDOR VENDOR_CONTACT
              DEB_VENDOR_VERSION DEB_VENDOR_PREFIX DEB_COMPRESSION)
    SET(optsn GENERATORS)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments(CPA)

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
            SET(CPACK_DEBIAN_PACKAGE_RELEASE
                "${CPA_DEB_VENDOR_PREFIX}${CPA_DEB_VENDOR_VERSION}"
                PARENT_SCOPE)

            # Handle DEB_COMPRESSION:
            SharemindSetToDefaultIfEmpty(CPA_DEB_COMPRESSION "xz")
            SET(CPACK_DEBIAN_COMPRESSION_TYPE "${CPA_DEB_COMPRESSION}"
                PARENT_SCOPE)

            SET(CPACK_DEB_COMPONENT_INSTALL "ON" PARENT_SCOPE)
            SET(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT" PARENT_SCOPE)
        ENDIF()
    ENDFOREACH()
ENDFUNCTION()

FUNCTION(SharemindAddComponentPackage component)
    IF("${component}" STREQUAL "")
        MESSAGE(FATAL_ERROR "Invalid component name given: ${component}")
    ENDIF()
    GET_CMAKE_PROPERTY(components COMPONENTS)
    LIST(FIND components "${component}" i)
    IF("${i}" EQUAL -1)
        MESSAGE(FATAL_ERROR "Component not found: ${component}")
    ENDIF()
    LIST(LENGTH components numComponents)

    SharemindNewList(flags)
    SET(opts1 NAME DESCRIPTION
              DEB_NAME DEB_DESCRIPTION DEB_SECTION)
    SET(optsn DEB_DEPENDS)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})

    SharemindSetToDefaultIfEmpty(CPA_NAME "${component}")
    SharemindSetToDefaultIfEmpty(CPA_DESCRIPTION "${CPA_NAME} package")

    FOREACH(generator IN LISTS CPACK_GENERATOR)
        IF("${generator}" STREQUAL "DEB")
            SharemindCheckRequiredArgument(CPA DEB_SECTION)
            SharemindSetToDefaultIfEmpty(CPA_DEB_NAME "${CPA_NAME}")
            SharemindSetToDefaultIfEmpty(CPA_DEB_DESCRIPTION
                                         "${CPA_DESCRIPTION}")

            IF("${numComponents}" EQUAL 1)
                SET(V_PACKAGE_NAME "CPACK_DEBIAN_PACKAGE_NAME")
                SET(V_PACKAGE_DESCRIPTION "CPACK_DEBIAN_PACKAGE_DESCRIPTION")
                SET(V_PACKAGE_SECTION "CPACK_DEBIAN_PACKAGE_SECTION")
                SET(V_PACKAGE_DEPENDS "CPACK_DEBIAN_PACKAGE_DEPENDS")
            ELSE()
                STRING(TOUPPER "${component}" C)
                SET(V_PACKAGE_NAME "CPACK_DEBIAN_${C}_PACKAGE_NAME")
                SET(V_PACKAGE_DESCRIPTION "CPACK_COMPONENT_${C}_DESCRIPTION")
                SET(V_PACKAGE_SECTION "CPACK_DEBIAN_${C}_PACKAGE_SECTION")
                SET(V_PACKAGE_DEPENDS "CPACK_DEBIAN_${C}_PACKAGE_DEPENDS")
            ENDIF()

            SET("${V_PACKAGE_NAME}" "${CPA_DEB_NAME}" PARENT_SCOPE)
            SET("${V_PACKAGE_DESCRIPTION}" "${CPA_DEB_DESCRIPTION}"
                PARENT_SCOPE)
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
                SET("${V_PACKAGE_DEPENDS}" "${DEB_DEPENDS}" PARENT_SCOPE)
            ENDIF()

            SET("${V_PACKAGE_SECTION}" "${CPA_DEB_SECTION}" PARENT_SCOPE)
        ENDIF()
    ENDFOREACH()
ENDFUNCTION()

MACRO(SharemindPackagingFinalize)
    INCLUDE(CPack)
ENDMACRO()


ENDIF() # SharemindPackaging_INCLUDED
