/*  Copyright 2004 Matthew Tylee Atkinson

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

/* $AGRIP-START */
/* AGRIP Auxiliary Player Information Object */

/**\file
// NOTES

// Collision Detection
//
// The following properties are set from outside,
// by the collision-detection function:
//
//      * self.ammo_shells      - bitfield of ``just hit this'' direction elements
//      * self.ammo_nails       - bitfield of ``sustained touch'' directoin elements
//      * self.ammo_rockets     - counts the number of walls we're touching
//
// Please refer to the function snap_misc_blockedtest() for more
// information on the values these properties can take.

// Bot Call Flag FIXME
//
// If the player wants bots to come to their aid, the self.ammo_cells flag is set.
// When the bots tell the player they're on their way, the self.lip flag is set.
// When the bots get to the player, they set the self.items flag.

// Waypoint Marker Count
//
// The self.health variable keeps track of which waypoint marker we are up to.

// Message Lock
//
// If for some reason, high-priority messages need to have their priority
// status revoked, the .state flag can be set.  This will render all high
// priority messages non-high priority until the flag is unset.
//
// It is primarily used to stop the device messages from masking the player
// death messages.
*/

// PROTOTYPES

void() snap_aux_constructor;


// IMPLEMENTATIONS

/**
    Set up the aux object.
	
    Like other constructors, this function is run as the player.
*/
void() snap_aux_constructor =
{
    local entity new_agaux;
                                                                                           
    new_agaux = spawn();
                                                                                           
    // Set up new aux object...
    new_agaux.movetype = MOVETYPE_NONE;
    new_agaux.solid = SOLID_NOT;
                                                                                           
    // Connect the aux object and player...
    new_agaux.owner = self;
    self.agrip_aux = new_agaux;
};

/* $AGRIP-END */
