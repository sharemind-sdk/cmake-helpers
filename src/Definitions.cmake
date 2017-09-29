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

IF(NOT DEFINED SharemindDefinitions_INCLUDED)
SET(SharemindDefinitions_INCLUDED TRUE)


MACRO(SharemindIsDefinition def out)
    IF("${def}" MATCHES "^[-/]D[A-Za-z_][A-Za-z0-9_]*(=.*)?$")
        SET("${out}" TRUE)
    ELSE()
        SET("${out}" FALSE)
    ENDIF()
ENDMACRO()


ENDIF() # SharemindDefinitions_INCLUDED
