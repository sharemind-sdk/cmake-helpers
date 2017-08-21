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

IF(NOT DEFINED SharemindCompileOptions_INCLUDED)
SET(SharemindCompileOptions_INCLUDED TRUE)


INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Arguments.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Lists.cmake")
INCLUDE(CMakeParseArguments)
INCLUDE(CheckCCompilerFlag)
INCLUDE(CheckCXXCompilerFlag)

FUNCTION(SharemindCheckCCompilerFlag flag out)
    STRING(SUBSTRING "${flag}" 1 -1 FlagName)
    STRING(REPLACE "+" "--plus--" FlagName "${FlagName}")
    CHECK_C_COMPILER_FLAG("${flag}" C_COMPILER_HAS_${FlagName}_FLAG)
    IF(C_COMPILER_HAS_${FlagName}_FLAG)
        SET("${out}" TRUE PARENT_SCOPE)
    ELSE()
        SET("${out}" FALSE PARENT_SCOPE)
    ENDIF()
ENDFUNCTION()
FUNCTION(SharemindCheckCxxCompilerFlag flag out)
    STRING(SUBSTRING "${flag}" 1 -1 FlagName)
    STRING(REPLACE "+" "--plus--" FlagName "${FlagName}")
    CHECK_CXX_COMPILER_FLAG("${flag}" CXX_COMPILER_HAS_${FlagName}_FLAG)
    IF(CXX_COMPILER_HAS_${FlagName}_FLAG)
        SET("${out}" TRUE PARENT_SCOPE)
    ELSE()
        SET("${out}" FALSE PARENT_SCOPE)
    ENDIF()
ENDFUNCTION()

FUNCTION(SharemindCheckAddCCompilerFlag flag)
    SharemindCheckCCompilerFlag("${flag}" hasFlag)
    IF("${hasFlag}")
        ADD_COMPILE_OPTIONS("${flag}")
    ENDIF()
ENDFUNCTION()
FUNCTION(SharemindCheckAddCxxCompilerFlag flag)
    SharemindCheckCxxCompilerFlag("${flag}" hasFlag)
    IF("${hasFlag}")
        ADD_COMPILE_OPTIONS("${flag}")
    ENDIF()
ENDFUNCTION()

FUNCTION(SharemindCheckAddCCompilerFlags)
    FOREACH(flag IN LISTS ARGN)
        SharemindCheckAddCCompilerFlag("${flag}")
    ENDFOREACH()
ENDFUNCTION()
FUNCTION(SharemindCheckAddCxxCompilerFlags)
    FOREACH(flag IN LISTS ARGN)
        SharemindCheckAddCxxCompilerFlag("${flag}")
    ENDFOREACH()
ENDFUNCTION()

FUNCTION(SharemindSetC99CompileOptions)
    SharemindNewList(flags)
    SharemindNewList(opts1)
    SET(optsn COMPILE_FLAGS DEFINITIONS)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments(CPA)

    ADD_COMPILE_OPTIONS(
        "-std=c99" "-Wall" "-Wextra" "-O2"
        "$<$<NOT:$<STREQUAL:$<CONFIGURATION>,Release>>:-ggdb>"
        "$<$<NOT:$<STREQUAL:$<CONFIGURATION>,Release>>:-fno-omit-frame-pointer>"
        "$<$<STREQUAL:$<CONFIGURATION>,Release>:-DNDEBUG>"
        "$<$<STREQUAL:$<CONFIGURATION>,Release>:-fomit-frame-pointer>"
    )
    SharemindCheckAddCCompilerFlags(
        "-Weverything"
        "-Wlogical-op"
        "-Wno-padded"
        "-Wabi"
        "-Wbad-function-cast"
        "-Wc++-compat"
        "-Wformat"
        "-Wswitch-default"
        "-Wunused"
        "-Wfloat-equal"
        "-Wshadow"
        "-Wpointer-arith"
        "-Wcast-qual"
        "-Wstrict-prototypes"
        "-Wconversion"
        "-Wsign-conversion"
        "-Wunused-macros"
        ${CPA_COMPILE_FLAGS}
    )
    ADD_DEFINITIONS(
        "-D__STDC_CONSTANT_MACROS"
        "-D__STDC_FORMAT_MACROS"
        "-D__STDC_LIMIT_MACROS"
        ${CPA_DEFINITIONS}
    )
ENDFUNCTION()

FUNCTION(SharemindSetCxx11CompileOptions)
    SharemindNewList(flags)
    SharemindNewList(opts1)
    SET(optsn COMPILE_FLAGS DEFINITIONS)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments(CPA)

    ADD_COMPILE_OPTIONS(
        "-std=c++11" "-Wall" "-Wextra" "-O2"
        "$<$<NOT:$<STREQUAL:$<CONFIGURATION>,Release>>:-ggdb>"
        "$<$<NOT:$<STREQUAL:$<CONFIGURATION>,Release>>:-fno-omit-frame-pointer>"
        "$<$<STREQUAL:$<CONFIGURATION>,Release>:-DNDEBUG>"
        "$<$<STREQUAL:$<CONFIGURATION>,Release>:-fomit-frame-pointer>"
    )
    SharemindCheckAddCxxCompilerFlags(
        "-Weverything"
        "-Wlogical-op"
        "-Wno-c++98-compat"
        "-Wno-c++98-compat-pedantic"
        "-Wno-covered-switch-default"
        "-Wno-float-equal"
        "-Wno-gnu-case-range"
        "-Wno-noexcept-type"
        "-Wno-packed"
        "-Wno-padded"
        "-Wno-weak-vtables"
        "-Wsuggest-override"
        "-Wzero-as-null-pointer-constant"
        ${CPA_COMPILE_FLAGS}
    )
    ADD_DEFINITIONS(
        "-D__STDC_CONSTANT_MACROS"
        "-D__STDC_FORMAT_MACROS"
        "-D__STDC_LIMIT_MACROS"
        ${CPA_DEFINITIONS}
    )
ENDFUNCTION()


ENDIF() # SharemindCompileOptions_INCLUDED
