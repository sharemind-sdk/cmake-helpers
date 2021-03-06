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
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/Variables.cmake")
INCLUDE(CheckCCompilerFlag)
INCLUDE(CheckCXXCompilerFlag)


FUNCTION(SharemindCheckCompilerFlag compiler flag out)
    STRING(SUBSTRING "${flag}" 1 -1 FlagName)
    STRING(REPLACE "+" "--plus--" FlagName "${FlagName}")
    CMAKE_LANGUAGE(CALL "CHECK_${compiler}_COMPILER_FLAG"
                   "${flag}" "has_flag_${FlagName}")
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

FUNCTION(SharemindTargetOptionalCompilerOptions target compiler)
    SharemindGenerateUniqueVariablePrefix(p)
    SET(optsn PRIVATE PUBLIC INTERFACE)
    CMAKE_PARSE_ARGUMENTS("${p}" "" "" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments("${p}")

    FOREACH(opt ${optsn})
        IF(NOT ("${${p}_${opt}}" STREQUAL ""))
            SharemindCheckCompilerFlags("${compiler}" checked ${${p}_${opt}})
            TARGET_COMPILE_OPTIONS("${target}" ${opt} ${checked})
        ENDIF()
    ENDFOREACH()
ENDFUNCTION()

FUNCTION(SharemindLanguageWrapCompileOptions language out)
    SharemindNewList(r)
    FOREACH(e IN LISTS ARGN)
        LIST(APPEND r "$<$<COMPILE_LANGUAGE:${language}>:${e}>")
    ENDFOREACH()
    SET("${out}" "${r}" PARENT_SCOPE)
ENDFUNCTION()

SharemindNewUniqueList(SharemindForcedCompileOptions
    "-Wall"
    "-Wextra"
    "-O2"
    "$<$<NOT:$<STREQUAL:$<CONFIGURATION>,Release>>:-ggdb>"
    "$<$<NOT:$<STREQUAL:$<CONFIGURATION>,Release>>:-fno-omit-frame-pointer>"
    "$<$<STREQUAL:$<CONFIGURATION>,Release>:-fomit-frame-pointer>"
)
SharemindNewUniqueList(SharemindC99ForcedCompileOptions
    ${SharemindForcedCompileOptions}
)
SharemindNewUniqueList(SharemindCxx14ForcedCompileOptions
    ${SharemindForcedCompileOptions}
)
SharemindNewUniqueList(SharemindCxx17ForcedCompileOptions
    ${SharemindForcedCompileOptions}
)

SharemindNewUniqueList(SharemindForcedCompileDefinitions
    "__STDC_CONSTANT_MACROS"
    "__STDC_FORMAT_MACROS"
    "__STDC_LIMIT_MACROS"
    "_POSIX_C_SOURCE=200809L"
    "_XOPEN_SOURCE=700"
    "$<$<STREQUAL:$<CONFIGURATION>,Release>:NDEBUG>"
)
SharemindNewUniqueList(SharemindC99ForcedCompileDefinitions
    ${SharemindForcedCompileDefinitions}
)
SharemindNewUniqueList(SharemindCxx14ForcedCompileDefinitions
    ${SharemindForcedCompileDefinitions}
)
SharemindNewUniqueList(SharemindCxx17ForcedCompileDefinitions
    ${SharemindCxx14ForcedCompileDefinitions}
)

SharemindNewUniqueList(SharemindCheckCompileOptions
    "-fasynchronous-unwind-tables"
    "-fcf-protection=full"
    "-fexceptions"
    "-fstack-clash-protection"
    "-fstack-protector-strong"
    "-mcet"
    "-pipe"
    "-Weverything"
    "-Wfloat-equal"
    "-Wformat"
    "-Wlogical-op"
    "-Wno-exit-time-destructors"
    "-Wno-disabled-macro-expansion"
    "-Wno-documentation-unknown-command"
    "-Wno-global-constructors"
    "-Wno-packed"
    "-Wno-padded"
    "-Wno-switch-enum"
    "-Wpointer-arith"
    "-Werror=format"
    "-Werror=format-signedness"
    "-Werror=alloca"
    "-Werror=gnu-zero-variadic-macro-arguments"
    "-Werror=null-pointer-arithmetic"
    "-Werror=embedded-directive"
    "-Werror=unused-result"
)
SharemindNewUniqueList(SharemindC99CheckCompileOptions
    ${SharemindCheckCompileOptions}
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
SharemindNewUniqueList(SharemindCxx14CheckCompileOptions
    ${SharemindCheckCompileOptions}
    "-faligned-new"
    "-fdef-sized-delete"          # For Clang <  SVN 229597
    "-fdefine-sized-deallocation" # For Clang >= SVN 229597
    "-fstrong-eval-order"
    "-Werror=register"
    "-Werror=extra-semi"
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
SharemindNewUniqueList(SharemindCxx17CheckCompileOptions
    ${SharemindCheckCompileOptions}
    "-faligned-new"
    "-fdef-sized-delete"          # For Clang <  SVN 229597
    "-fdefine-sized-deallocation" # For Clang >= SVN 229597
    "-Werror=register"
    "-Werror=extra-semi"
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

FUNCTION(SharemindSetDefaultCompileOptions target standard)
    IF("${standard}" MATCHES "^[Cc]99$")
        SET(compiler "C")
    ELSEIF("${standard}" MATCHES "^[Cc][Xx][Xx]1[47]$")
        SET(compiler "CXX")
    ELSE()
        MESSAGE(FATAL_ERROR "Unsupported standard specified: ${standard}")
    ENDIF()
    STRING(REGEX REPLACE "^[^0-9]" "" version "${standard}")

    SharemindGenerateUniqueVariablePrefix(p)
    SharemindNewList(flags)
    SharemindNewList(opts1)
    SET(optsn TARGETS)
    CMAKE_PARSE_ARGUMENTS("${p}" "${flags}" "${opts1}" "${optsn}" ${ARGN})
    SharemindCheckNoUnparsedArguments("${p}")

    SharemindCheckCompilerFlags("${compiler}" options
        ${Sharemind${standard}CheckCompileOptions})
    LIST(INSERT options 0 "${Sharemind${standard}ForcedCompileOptions}")
    SET(definitions "${Sharemind${standard}ForcedCompileDefinitions}")
    SharemindLanguageWrapCompileOptions("${compiler}" options ${options})
    SharemindLanguageWrapCompileOptions("${compiler}" definitions
        ${definitions})

    SET_TARGET_PROPERTIES(${target}
        PROPERTIES
            ${compiler}_STANDARD "${version}"
            ${compiler}_EXTENSIONS FALSE
            ${compiler}_REQUIRED TRUE
    )
    TARGET_COMPILE_OPTIONS("${target}" PRIVATE "${options}")
    TARGET_COMPILE_DEFINITIONS("${target}" PRIVATE "${definitions}")
ENDFUNCTION()

FUNCTION(SharemindSetCompileOptionsFromStd target std)
    IF("${std}" STREQUAL "")
        GET_CMAKE_PROPERTY(enabledLangs ENABLED_LANGUAGES)
        CMAKE_POLICY(PUSH)
        CMAKE_POLICY(SET CMP0057 NEW)
        IF("C" IN_LIST enabledLangs)
            SharemindSetDefaultCompileOptions("${target}" "C99")
        ENDIF()
        IF("CXX" IN_LIST enabledLangs)
            SharemindSetDefaultCompileOptions("${target}" "Cxx14")
        ENDIF()
        CMAKE_POLICY(POP)
    ELSEIF(NOT ("${std}" MATCHES "^[Ss][Kk][Ii][Pp]$"))
        SharemindSetDefaultCompileOptions("${target}" "${std}")
    ENDIF()
ENDFUNCTION()
