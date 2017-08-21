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


INCLUDE(CheckCCompilerFlag)
FUNCTION(SharemindCheckAddCCompilerFlag flag)
    STRING(SUBSTRING "${flag}" 1 -1 FlagName)
    STRING(REPLACE "+" "--plus--" FlagName "${FlagName}")
    CHECK_C_COMPILER_FLAG("${flag}" C_COMPILER_HAS_${FlagName}_FLAG)
    IF(C_COMPILER_HAS_${FlagName}_FLAG)
        ADD_COMPILE_OPTIONS("${flag}")
    ENDIF()
ENDFUNCTION()

INCLUDE(CheckCXXCompilerFlag)
FUNCTION(SharemindCheckAddCxxCompilerFlag flag)
    STRING(SUBSTRING "${flag}" 1 -1 FlagName)
    STRING(REPLACE "+" "--plus--" FlagName "${FlagName}")
    CHECK_CXX_COMPILER_FLAG("${flag}" CXX_COMPILER_HAS_${FlagName}_FLAG)
    IF(CXX_COMPILER_HAS_${FlagName}_FLAG)
        ADD_COMPILE_OPTIONS("${flag}")
    ENDIF()
ENDFUNCTION()

MACRO(SharemindSetCxx11CompileOptions)
    ADD_COMPILE_OPTIONS(
        "-std=c++11" "-Wall" "-Wextra" "-O2"
        "$<$<NOT:$<STREQUAL:$<CONFIGURATION>,Release>>:-ggdb>"
        "$<$<NOT:$<STREQUAL:$<CONFIGURATION>,Release>>:-fno-omit-frame-pointer>"
        "$<$<STREQUAL:$<CONFIGURATION>,Release>:-DNDEBUG>"
        "$<$<STREQUAL:$<CONFIGURATION>,Release>:-fomit-frame-pointer>"
    )
    SharemindCheckAddCxxCompilerFlag("-Weverything")                                                                                                                                                                                                            
    SharemindCheckAddCxxCompilerFlag("-Wlogical-op")                                                                                                                                                                                                            
    SharemindCheckAddCxxCompilerFlag("-Wno-c++98-compat")                                                                                                                                                                                                       
    SharemindCheckAddCxxCompilerFlag("-Wno-c++98-compat-pedantic")                                                                                                                                                                                              
    SharemindCheckAddCxxCompilerFlag("-Wno-covered-switch-default")                                                                                                                                                                                             
    SharemindCheckAddCxxCompilerFlag("-Wno-float-equal")                                                                                                                                                                                                        
    SharemindCheckAddCxxCompilerFlag("-Wno-gnu-case-range")                                                                                                                                                                                                     
    SharemindCheckAddCxxCompilerFlag("-Wno-noexcept-type")                                                                                                                                                                                                      
    SharemindCheckAddCxxCompilerFlag("-Wno-packed")                                                                                                                                                                                                             
    SharemindCheckAddCxxCompilerFlag("-Wno-padded")                                                                                                                                                                                                             
    SharemindCheckAddCxxCompilerFlag("-Wno-weak-vtables")                                                                                                                                                                                                       
    SharemindCheckAddCxxCompilerFlag("-Wsuggest-override")                                                                                                                                                                                                      
    SharemindCheckAddCxxCompilerFlag("-Wzero-as-null-pointer-constant")
    ADD_DEFINITIONS(
        "-D__STDC_LIMIT_MACROS"
        "-D__STDC_FORMAT_MACROS"
    )
ENDMACRO()


ENDIF() # SharemindCompileOptions_INCLUDED
