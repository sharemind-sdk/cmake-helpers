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


FUNCTION(SharemindCompileSecrec)
    # Usage: SharemindCompileSecrec(
    #  inFile ".sc input SecreC source file to be compiled"
    #  outFile ".sb output SecreC binary file"
    #  moduleIncludePaths "List of module search paths appended to compiler with -I flag"
    #  extraDeps "Additional list of files which will trigger a recompilation when changed"
    #  )
    SET(opts1 inFile outFile)
    SET(optsn moduleIncludePaths extraDeps)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})
    # Find paths from CMAKE_PREFIX_PATH
    FIND_PATH(SCC_PATH "bin/scc" PATHS "${CMAKE_PREFIX_PATH}")
    FIND_PATH(STDLIB_PATH "lib/sharemind/stdlib" PATHS "${CMAKE_PREFIX_PATH}")
    FIND_PATH(LIBRARY_PATH "lib/libscc.so" PATHS "${CMAKE_PREFIX_PATH}")
    # Find the file name from outfile to be used as custom_target name
    STRING(REGEX MATCH [^\\/]+$ CUSTOM_TARGET_NAME ${CPA_inFile})
    # Find the list of SecreC stdlib files so we can run rebuild when they change
    FILE(GLOB secrec_stdlib_files "${STDLIB_PATH}/lib/sharemind/stdlib/*.sc")
    # Build a list of include dirs to be appended to scc compiler
    FOREACH (path ${CPA_moduleIncludePaths})
      LIST(APPEND includeArgs "-I")
      LIST(APPEND includeArgs ${path})
    ENDFOREACH()
    ADD_CUSTOM_COMMAND(
      COMMENT "Compiling ${CPA_inFile}"
      DEPENDS "${CPA_inFile}" "${secrec_stdlib_files}" "${CPA_extraDeps}"
      OUTPUT "${CPA_outFile}"
      COMMAND
      "${CMAKE_COMMAND}" "-E" "env" "LD_LIBRARY_PATH=${LIBRARY_PATH}/lib"
      "${SCC_PATH}/bin/scc"
      "-I" "${STDLIB_PATH}/lib/sharemind/stdlib/" ${includeArgs}
      "-o" "${CPA_outFile}"
      "${CPA_inFile}")
    ADD_CUSTOM_TARGET("compile-secrec-${CUSTOM_TARGET_NAME}" ALL
      DEPENDS "${CPA_outFile}"
    )
ENDFUNCTION()