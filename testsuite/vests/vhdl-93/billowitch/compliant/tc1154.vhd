
-- Copyright (C) 2001 Bill Billowitch.

-- Some of the work to develop this test suite was done with Air Force
-- support.  The Air Force and Bill Billowitch assume no
-- responsibilities for this software.

-- This file is part of VESTs (Vhdl tESTs).

-- VESTs is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the
-- Free Software Foundation; either version 2 of the License, or (at
-- your option) any later version. 

-- VESTs is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for more details. 

-- You should have received a copy of the GNU General Public License
-- along with VESTs; if not, write to the Free Software Foundation,
-- Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 

-- ---------------------------------------------------------------------
--
-- $Id: tc1154.vhd,v 1.2 2001-10-26 16:29:39 paw Exp $
-- $Revision: 1.2 $
--
-- ---------------------------------------------------------------------

package c06s06b00x00p02n01i01154pkg is
  type A1 is array (1 to 2) of BOOLEAN;
  type A2 is array (1 to 2) of A1;
end c06s06b00x00p02n01i01154pkg;

use work.c06s06b00x00p02n01i01154pkg.all;
ENTITY c06s06b00x00p02n01i01154ent IS
  port (PT: A2) ;
  attribute AT1 : BOOLEAN;
  attribute AT1 of PT : signal is TRUE;
END c06s06b00x00p02n01i01154ent;

ARCHITECTURE c06s06b00x00p02n01i01154arch OF c06s06b00x00p02n01i01154ent IS

BEGIN
  TESTING: PROCESS
    variable k : integer := 5;
  BEGIN
    if PT'AT1 then
      k := 5;
    end if;
    assert NOT( k=5 )
      report "***PASSED TEST: c06s06b00x00p02n01i01154"
      severity NOTE;
    assert ( k=5 )
      report "***FAILED TEST: c06s06b00x00p02n01i01154 - The attribute name consists of a prefix, an apostrophe('), an attribute designator, and (optionally) a static expression enclosed with parentheses."
      severity ERROR;
    wait;
  END PROCESS TESTING;

END c06s06b00x00p02n01i01154arch;
