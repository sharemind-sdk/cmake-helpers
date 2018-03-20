#
# Copyright (C) 2015 Cybernetica
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

CMAKE_MINIMUM_REQUIRED(VERSION 3.6)
PROJECT(SharemindCMakeHelpers VERSION 1.1.1)

INCLUDE(GNUInstallDirs)
SET(SRCDIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
INCLUDE("${SRCDIR}/CMakeFindFiles.cmake")
INCLUDE("${SRCDIR}/Lists.cmake")
INCLUDE("${SRCDIR}/Strings.cmake")
INCLUDE("${SRCDIR}/UserConfig.cmake")
INCLUDE("${SRCDIR}/Versioning.cmake")

SharemindSetProjectVersion()
SharemindIncludeUserConfigs()

SET(SCRIPTDIR "cmake-scripts")
SET(SCRIPTROOT "lib/${CMAKE_PROJECT_NAME}/${SCRIPTDIR}")
SET(FULL_SCRIPTROOT "${CMAKE_INSTALL_PREFIX}/${SCRIPTROOT}")

FILE(GLOB_RECURSE SharemindCMakeHelpers_SOURCES
    "${SRCDIR}/*.cmake"
    "${SRCDIR}/*.in"
)
INSTALL(FILES ${SharemindCMakeHelpers_SOURCES} DESTINATION "${SCRIPTROOT}")
ADD_CUSTOM_TARGET("include_SharemindCMakeHelpers_SOURCES_in_IDE"
                  SOURCES ${SharemindCMakeHelpers_SOURCES})

SET(everything "${CMAKE_CURRENT_BINARY_DIR}/everything.cmake")
FILE(WRITE "${everything}" "")
FOREACH(s IN LISTS SharemindCMakeHelpers_SOURCES)
    SharemindStringStripPrefix("${s}" "${SRCDIR}/" s)
    FILE(APPEND "${everything}" "INCLUDE(\"${FULL_SCRIPTROOT}/${s}\")\n")
ENDFOREACH()
INSTALL(FILES "${everything}" DESTINATION "lib/SharemindCMakeHelpers")

SharemindUseCMakeFindFiles()
