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

CMAKE_MINIMUM_REQUIRED(VERSION 3.10)
PROJECT(SharemindCMakeHelpers VERSION 1.6.0)

INCLUDE(GNUInstallDirs)
SET(SRCDIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
INCLUDE("${SRCDIR}/CMakeFindFiles.cmake")
INCLUDE("${SRCDIR}/Lists.cmake")
INCLUDE("${SRCDIR}/Strings.cmake")
INCLUDE("${SRCDIR}/Packaging.cmake")
INCLUDE("${SRCDIR}/UserConfig.cmake")
INCLUDE("${SRCDIR}/Versioning.cmake")

SharemindIncludeUserConfigs()

SET(SCRIPTDIR "cmake-scripts")
SET(SCRIPTROOT "lib/cmake/${CMAKE_PROJECT_NAME}/${SCRIPTDIR}")

FILE(GLOB_RECURSE SharemindCMakeHelpers_SOURCES
    "${SRCDIR}/*.cmake"
    "${SRCDIR}/*.in"
)
INSTALL(FILES ${SharemindCMakeHelpers_SOURCES} DESTINATION "${SCRIPTROOT}"
        COMPONENT "dev")
ADD_CUSTOM_TARGET("include_SharemindCMakeHelpers_SOURCES_in_IDE"
                  SOURCES ${SharemindCMakeHelpers_SOURCES})

SET(everything "${CMAKE_CURRENT_BINARY_DIR}/everything.cmake")
FILE(WRITE "${everything}" "")
FOREACH(s IN LISTS SharemindCMakeHelpers_SOURCES)
    SharemindStringStripPrefix("${s}" "${SRCDIR}/" s)
    FILE(APPEND "${everything}" "INCLUDE(\"\${CMAKE_CURRENT_LIST_DIR}/${s}\")\n")
ENDFOREACH()
INSTALL(FILES "${everything}" DESTINATION "lib/cmake/${CMAKE_PROJECT_NAME}"
        COMPONENT "dev")

SharemindUseCMakeFindFiles()

SharemindSetupPackaging()
SharemindAddComponentPackage("dev"
    NAME "sharemind-cmake-helpers"
    DESCRIPTION "Sharemind CMake Helpers"
    DEB_SECTION "libs"
)
SharemindPackagingFinalize()
