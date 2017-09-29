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

IF(NOT DEFINED SharemindCompileOptions_INCLUDED)
SET(SharemindCompileOptions_INCLUDED TRUE)


INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Arguments.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Lists.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Polymorphism.cmake")
INCLUDE(CMakeParseArguments)
INCLUDE(CheckCCompilerFlag)
INCLUDE(CheckCXXCompilerFlag)

FUNCTION(SharemindCheckCompilerFlag compiler flag out)
    STRING(SUBSTRING "${flag}" 1 -1 FlagName)
    STRING(REPLACE "+" "--plus--" FlagName "${FlagName}")
    SharemindCall("CHECK_${compiler}_COMPILER_FLAG" "${flag}"
                  "has_flag_${FlagName}")
    IF("${has_flag_${FlagName}}")
        SET("${out}" TRUE PARENT_SCOPE)
    ELSE()
        SET("${out}" FALSE PARENT_SCOPE)
    ENDIF()
ENDFUNCTION()

FUNCTION(SharemindCheckCompilerFlags compiler out)
    SharemindNewList(o)
    FOREACH(flag IN LISTS ARGN)
        SharemindCheckCompilerFlag("${compiler}" "${flag}" hasFlag)
        IF("${hasFlag}")
            SharemindListAppendUnique(o "${flag}")
        ENDIF()
    ENDFOREACH()
    SET("${out}" ${o} PARENT_SCOPE)
ENDFUNCTION()

SharemindNewUniqueList(SharemindForcedCompileOptions
    "-Wall"
    "-Wextra"
    "-O2"
    "$<$<NOT:$<STREQUAL:$<CONFIGURATION>,Release>>:-ggdb>"
    "$<$<NOT:$<STREQUAL:$<CONFIGURATION>,Release>>:-fno-omit-frame-pointer>"
    "$<$<STREQUAL:$<CONFIGURATION>,Release>:-DNDEBUG>"
    "$<$<STREQUAL:$<CONFIGURATION>,Release>:-fomit-frame-pointer>"
)
SharemindNewUniqueList(SharemindC99ForcedCompileOptions
    "-std=c99"
    ${SharemindForcedCompileOptions}
)
SharemindNewUniqueList(SharemindCxx11ForcedCompileOptions
    "-std=c++11"
    ${SharemindForcedCompileOptions}
)

SharemindNewUniqueList(SharemindForcedCompileDefinitions
    "__STDC_CONSTANT_MACROS"
    "__STDC_FORMAT_MACROS"
    "__STDC_LIMIT_MACROS"
)
SharemindNewUniqueList(SharemindC99ForcedCompileDefinitions
    ${SharemindForcedCompileDefinitions}
)
SharemindNewUniqueList(SharemindCxx11ForcedCompileDefinitions
    ${SharemindForcedCompileDefinitions}
)

SharemindNewUniqueList(SharemindCheckCompileOptions
    "-Weverything"
    "-Wfloat-equal"
    "-Wformat"
    "-Wlogical-op"
    "-Wno-packed"
    "-Wno-padded"
    "-Wpointer-arith"
    "-Werror=format"
    "-Werror=format-signedness"
    "-Werror=register"
    "-Werror=alloca"
)
SharemindNewUniqueList(SharemindC99CheckCompileOptions
    ${SharemindCheckCompileOptions}
    "-Wabi"
    "-Wbad-function-cast"
    "-Wc++-compat"
    "-Wcast-qual"
    "-Wconversion"
    "-Wshadow"
    "-Wsign-conversion"
    "-Wstrict-prototypes"
    "-Wswitch-default"
    "-Wunused"
    "-Wunused-macros"
)
SharemindNewUniqueList(SharemindCxx11CheckCompileOptions
    ${SharemindCheckCompileOptions}
    "-faligned-new"
    "-fdefine-sized-deallocation"
    "-Wno-c++98-compat"
    "-Wno-c++98-compat-pedantic"
    "-Wno-covered-switch-default"
    "-Wno-gnu-case-range"
    "-Wno-noexcept-type"
    "-Wno-weak-vtables"
    "-Wsuggest-override"
    "-Wzero-as-null-pointer-constant"
    "-Werror=terminate"
)

FUNCTION(SharemindSetCompileOptions compiler standard)
    SharemindNewList(flags)
    SharemindNewList(opts1)
    SET(optsn TARGETS FORCED_OPTIONS CHECK_OPTIONS DEFINITIONS COMPILE_FLAGS)
    CMAKE_PARSE_ARGUMENTS(CPA "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments(CPA)

    SharemindNewList(forced
        ${Sharemind${standard}ForcedCompileOptions}
        ${CPA_FORCED_OPTIONS}
    )
    SharemindCheckCompilerFlags("${compiler}" optional
        ${Sharemind${standard}CheckCompileOptions}
        ${CPA_CHECK_OPTIONS}
        ${CPA_COMPILE_FLAGS}
    )
    SharemindNewList(options ${forced} ${optional})
    SharemindNewList(definitions
        ${Sharemind${standard}ForcedCompileDefinitions}
        ${CPA_DEFINITIONS}
    )

    IF("${CPA_TARGETS}" STREQUAL "")
        ADD_COMPILE_OPTIONS(${options})
        FOREACH(definition IN LISTS definitions)
            ADD_DEFINITIONS("-D${definition}")
        ENDFOREACH()
    ELSE()
        SET_TARGET_PROPERTIES(${CPA_TARGETS}
            PROPERTIES
                COMPILE_OPTIONS "${options}"
                COMPILE_DEFINITIONS "${definitions}"
        )
    ENDIF()
ENDFUNCTION()
MACRO(SharemindSetC99CompileOptions)
    SharemindSetCompileOptions("C" "C99" ${ARGN})
ENDMACRO()
MACRO(SharemindSetCxx11CompileOptions)
    SharemindSetCompileOptions("CXX" "Cxx11" ${ARGN})
ENDMACRO()


ENDIF() # SharemindCompileOptions_INCLUDED
