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
/* AGRIP Definitions */

// Turn on accessibility features...
#define AGRIP ///< Enables hooks for the main AGRIP code in the standard QC files.

/**\file
    MOD HOOKS
    
    Enable hooks for mods (these allow mod authors to hook into the AGRIP/QC
    code at certain points thus making the process of modding a lot less
    invasive and keepign our and their code clean)...

    Simply define the following in your \<modname\>_defs.qc file...
    
    - AGRIP_MODHOOK_PRECACHE
         if enabled, the mod must provide a function agrip_modhook_precache()
         which can be used by the mod to load the sounds it requires at the
         start of a map.
*/

/// Define our helper objects...
/// These really work as fields for each entity in the game
.entity agrip_nav; ///< link to the player's navigation helper entity (added to global list of fields for each entity)
.entity agrip_d5k; ///< link to the player's D5k entity (added to global list of fields for each entity)
.entity agrip_esr; ///< link to the player's ESR entity (added to global list of fields for each entity)
.entity agrip_aux; ///< link to the player's auxiliary infomation entity (added to global list of fields for each entity)

// These used to be in qw/defs.qc but were removed:
.float volume;

// Bot stuff...
void (float clientcalled) KickABotDM;
float (float bteam, float clientcalled) KickABotTeam;
void (float bottom, float top, string bteam, float clientcalled) create_bot;

// Builtins...
// ZQ experimental bot
entity (string name) testbot = #0x5a0A;
// AGRIP's soundtoclient function
//void (entity client, entity e, float chan, string samp, float vol, float atten) soundtoclient = #0x5a08;

// For debugging...
void (entity client, entity e, float chan, string samp, float vol, float atten) safe_soundtoclient =
{
    /* for testing this function...
    if( random() > 0.99 )
    {
        dprint("INITING CRASH...\n");
        vol = 42;
    }*/

    if( vol < 0 )
    {
        dprint("PLEASE REPORT THIS BUG, INCLUDING ALL ERROR MESSAGES!\n");
        local float i;
        while( i < 1000000)
        {
            i = i + 1;
        }
    }
    else if( vol > 1 )
    {
        dprint("PLEASE REPORT THIS BUG, INCLUDING ALL ERROR MESSAGES!\n");
        local float i;
        while( i < 1000000)
        {
            i = i + 1;
        }
    }
    else
    {
        soundtoclient(client, e, chan, samp, vol, atten);
    }
}

/* $AGRIP-END */
