/*
Copyright (C) 1996-1997 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/
// admin.qc

float CountPlayers();
float CountRTeams();
void AdminMatchStart();
void StopTimer();
void NextLevel();
void EndMatch(float skip_log);

void NextClient();
void ExitKick(entity kicker);
void Deathmsg();
void RandomPickup();

// This is designed for pickup games and creates totally random teams(ish)
// It creates teams thus :
// Team red  color 4  skin base
// team blue color 13 skin base
// Does it by finding out how many players should be in each team.  Then it goes through each
// player and uses a random function.  If the number returned less than .5 it puts it in k_teamnumber 1.
// It does this until alreadyset = ineachteam.  Once that is done it loops through players and checks if
// we have found enough players for the team.  If it has then it sets all others to blue.
// Else it adds next player.  Once we have found enough players then we loop through again setting teams.
void RandomPickup ()
{
    entity p;
    float f1=0, ineachteam=0, alreadyset=0;

    if(self.k_admin != 2)
    {
        sprint(self, 2, "You are not an admin\n");
        return;
    }

    if(match_in_progress)
        return;

    // Firstly obtain the number of players we have in total on server
    f1 = CountPlayers();

    // Dont need to bother if less than 4 players
    if(f1 < 4)
    {
        sprint(self, 2, "You need at least 4 players to do this.\n");
        return;
    }

    // Now we have number in each team.
    ineachteam = f1/2;

    // loop through players and put in one team or other as you go through.
    p = find(world, classname, "player");
    while(p != world)
    {
        if(p.netname != "")
        {
            // Make all players have no team/skin/color x
            stuffcmd(p, "break\ncolor 0\nteam \"\"\nskin base\n");

            // If we have not found enough players then add to first team.
            if(alreadyset < ineachteam)
            {
                if (random() < 0.5)
                {
                    // Make member of team one
                    p.k_teamnumber = 1;
                    // Increment number of players set to team 1.
                    alreadyset = alreadyset + 1;
                }
                else
                {
                    // Make member of team two
                    p.k_teamnumber = 2;
                }
            }
        }
        p = find(p, classname, "player");
    }

    // We have looped through each players once and should hopefully have enough players.
    // If not we loop again and find enough players for the first team.
    if(alreadyset < ineachteam)
    {
        p = find(world, classname, "player");
        while(p != world)
        {
            if(p.netname != ""  && p.k_teamnumber !=1)
            {
                // If we have not found enough players then add to first team.
                if(alreadyset < ineachteam)
                {
                    // We make this player member of team 1.
                    p.k_teamnumber = 1;

                    // Increment number of players set to team 1.
                    alreadyset = alreadyset + 1;
                }
            }
            p = find(p, classname, "player");
        }
    }

    // We have looped through the players twice so we are guaranteed to have enough players.
    // We now loop again for the last time and set the teams.

    p = find(world, classname, "player");
    while(p != world)
    {
        if(p.netname != "")
        {
            if(p.k_teamnumber==1)
            {
                stuffcmd(p, "break\ncolor 4\nskin \"\"\nteam red\n");
            }
            else
            {
                stuffcmd(p, "break\ncolor 13\nskin \"\"\nteam blue\n");
            }
            // Then we reset what team they are in to avoid problems.
            p.k_teamnumber = 0;
        }
        p = find(p, classname, "player");
    }

    bprint(3, "console: random pickup game it is then\n");
}

// This toggle's between different messages
void Deathmsg ()
{
    float tmp;

    if(self.k_admin != 2)
    {
        sprint(self, 2, "You are not an admin\n");
        return;
    }

    if(match_in_progress)
        return;

    tmp = stof(infokey(world, "k_deathmsg"));

    bprint(2, "Ãõóôïí äåáôèíåóóáçåó ");
    if(tmp != 0)
    {
        bprint(2, "disabled\n");
        localcmd("localinfo k_deathmsg 0\n");
    }
    else
    {
        bprint(2, "enabled\n");
        localcmd("localinfo k_deathmsg 1\n");
    }
}


void KickThink ()
{
    sprint(self.owner, 2, "Your ëéãë mode has timed out.\n");
    self.nextthink = -1;
    ExitKick(self.owner);
}

void AdminKick ()
{
    entity kickguard;

    if(self.k_captain)
    {
        sprint(self, 2, "Exit ãáðôáéî mode first\n");
        return;
    }
    if(self.k_admin != 2)
    {
        sprint(self, 2, "You are not an admin\n");
        return;
    }
    if(self.k_kicking)
        ExitKick(self);
    else
    {
        self.k_kicking = 1;
        sprint(self, 2, "Kicking process started\nžžžžžžžžžžžžžžžžžžžžžŸ\nType ù to kick, î for next, ëéãë to leave.\n");
        self.kick_ctype = "player";
        self.k_playertokick = world;
        kickguard = spawn(); // Check the 1 minute timeout for kick mode
        kickguard.owner = self;
        kickguard.classname = "kickguard";
        kickguard.think = KickThink;
        kickguard.nextthink = time + 60;
        NextClient();
    }
}

void NextClient ()
{
    float loop = 1;

    while(loop)
    {
        self.k_playertokick = find(self.k_playertokick, classname, self.kick_ctype);
        if(self.k_playertokick == world)
            if(self.kick_ctype == "player")
                self.kick_ctype = "spectator";
            else
                self.kick_ctype = "player";
        else if(self.k_playertokick.netname != "" &&
                (self.kick_ctype == "spectator" ||
                 (self.kick_ctype == "player" &&
                  self.k_playertokick.k_accepted == 2)))
            loop = 0;
    }
    sprint(self, 2, "Kick ", self.kick_ctype, " ");
    sprint(self, 2, self.k_playertokick.netname, "?\n");
}

void YesKick ()
{
    entity oldtokick;

    if(self.k_kicking)
    {
        if(self.k_playertokick.classname != "" && self.k_playertokick != self)
        {
            bprint(2, self.k_playertokick.netname, " was kicked by ", self.netname, "\n");
            sprint(self.k_playertokick, 2, "You were kicked from the server\n");
            oldtokick = self.k_playertokick;
            NextClient();
            oldtokick.classname = "";
            stuffcmd(oldtokick, "disconnect\n");
        }
        else if(self.k_playertokick == self)
        {
            bprint(2, self.netname, " kicked ");
            if(infokey(self, "gender") == "f")
                bprint(2, "herself\n");
            else
                bprint(2, "himself\n");
            sprint(self, 2, "Say \"bye\" and then type \"disconnect\" next time.\n");
            self.classname = "";
            stuffcmd(self, "disconnect\n");
        }
    }
}

void DontKick ()
{
    if (self.k_kicking)
        NextClient();
}

void ExitKick (entity kicker)
{
    local entity childkick;

    if (kicker.k_kicking)
    {
        kicker.k_kicking = 0;
        childkick = find(world, classname, "kickguard");
        while(childkick.owner != kicker)
            childkick = find(childkick, classname, "kickguard");
        remove
            (childkick);
        if(kicker.classname != "")
            sprint(kicker, 2, "Kicking process terminated\n");
    }
}

void ReqAdmin ()
{
    //  admin state=1.5 check for election
    if(self.k_admin == 1.5)
    {
        sprint(self, 2, "Abort åìåãôion first\n");
        return;
    }
    if(self.k_admin == 2)
    {
        bprint(2, self.netname, " is no longer an admin.\n");
        if(self.k_kicking)
            ExitKick(self);
        self.k_admin = 0;
        return;
    }
    if(self.k_admin)
        return;
    self.k_admin = 1;
    self.k_adminc = 6;
    self.k_added = 0;
    // You can now use numbers to enter code
    sprint(self, 2, "Use îõíâåòó or éíðõìóåó to enter code\n");
}

void AdminImpBot ()
{
    float coef, i1;
    string s1;

    if(self.k_adminc == 0)
    {
        self.k_admin = 0;
        return;
    }
    i1 = self.k_adminc - 1;
    coef = self.impulse;
    while(i1)
    {
        coef = coef * 10;
        i1 = i1 - 1;
    }
    self.k_added = self.k_added + coef;
    self.k_adminc = self.k_adminc - 1;
    if(!self.k_adminc)
    {
        if(self.k_added == stof(infokey(world, "k_admincode")))
        {
            bprint(2, self.netname, " çáéîó áäíéî óôáôõó!");
            bprint(3, "\n");
            sprint(self, 2, "Type ãïííáîäó for info\n");
            self.k_admin = 2;
        }
        else
        {
            self.k_admin = 0;
            sprint(self, 2, "Access denied...\n");
        }
    }
    else
    {

        s1 = ftos(self.k_adminc);
        sprint(self, 2, s1, " íïòå ôï çï\n");
    }
}

void ReadyThink ()
{
    float i1;
    string tmp;
    entity p;

    if(self.owner.classname == "player" && !self.owner.ready)
    {
        k_force = 0;
        bprint(2, self.owner.netname, " interrupts countdown\n");
        remove
            (self);
        return;
    }
    if(self.owner.classname != "player" && !k_force)
    {
        bprint(2, self.owner.netname, " interrupts countdown\n");
        remove
            (self);
        return;
    }
    self.attack_finished = self.attack_finished - 1;
    i1 = self.attack_finished;
    if(!i1)
    {
        k_force = 0;
        AdminMatchStart();
        remove
            (self);
        return;
    }

    if(i1 == 1)
        tmp = "\n“";
    if(i1 == 2)
        tmp = "\n”";
    if(i1 == 3)
        tmp = "\n•";
    if(i1 == 4)
        tmp = "\n–";
    if(i1 == 5)
        tmp = "\n—";
    if(i1 == 6)
        tmp = "\n˜";
    if(i1 == 7)
        tmp = "\n™";
    if(i1 == 8)
        tmp = "\nš";
    if(i1 == 9)
        tmp = "\n›";
    if(i1 == 10)
        tmp = "\n“’";
    p = find(world, classname, "player");
    while(p != world)
    {
        if(p.netname != "")
        {
            if(p.ready)
                if(i1 == 1)
                    centerprint(p, tmp, " second to gamestart");
                else
                    centerprint(p, tmp, " seconds to gamestart");
            else
                if(i1 == 1)
                        centerprint(p, tmp, " second to gamestart\nÇï òåáäù!");

                else
                        centerprint(p, tmp, " seconds to gamestart\nÇï òåáäù!");
        }
        p = find(p, classname, "player");
    }
    p = find(world, classname, "spectator");
    while(p != world)
    {
        if(p.netname != "")
            if(i1 == 1)
                centerprint(p, tmp, " second to gamestart");
            else
                centerprint(p, tmp, " seconds to gamestart");
        p = find(p, classname, "spectator");
    }
    self.nextthink = time + 1;
}

void AdminForceStart ()
{
    entity mess;
    float f1, k_lockmin, k_lockmax;
    string tmp;

    if(match_in_progress || self.k_admin != 2)
        return;
    if(self.classname == "player" && !self.ready)
    {
        sprint(self, 2, "Ready yourself first\n");
        return;
    }
    k_lockmin = stof(infokey(world, "k_lockmin"));
    k_lockmax = stof(infokey(world, "k_lockmax"));
    f1 = CountRTeams();
    if(f1 < k_lockmin)
    {
        tmp = ftos(k_lockmin - f1);
        sprint(self, 2, tmp, " more team");
        if((k_lockmin - f1) != 1)
            sprint(self, 2, "s");
        sprint(self, 2, " required.\n");
        return;
    }
    if(f1 > k_lockmax)
    {
        sprint(self, 2, "Get rid of ");
        tmp = ftos(f1 - k_lockmax);
        sprint(self, 2, tmp, " team");
        if((f1 - k_lockmax) != 1)
            sprint(self, 2, "s");
        sprint(self, 2, "!\n");
        return;
    }
    f1 = CountPlayers();
    if(f1)
    {
        bprint(2, self.netname, " forces matchstart!\n");
        k_force = 1;
        mess = spawn();
        mess.classname = "mess";
        mess.owner = self;
        mess.think = ReadyThink;
        mess.nextthink = time + 0.1;
        mess.attack_finished = 10 + 1;
    }
    else
        sprint(self, 2, "Can't issue! More players needed.\n");
}


void BotForceStart ()
{
    entity p;
    float f1;

    bprint(2, "server is tired of waiting\nmatch WILL commence!\n");
    f1 = 0;
    p = find(world, classname, "player");
    while(p != world)
    {
        if(p.netname != "")
        {
            if(p.ready && p.k_accepted == 2)
            {
                f1 = f1 + 1;
            }
            else
            {
                p.k_accepted = 0;
                bprint(2, p.netname, " was kicked by IDLE BOT\n");
                sprint(p, 2, "Bye bye! Pay attention next time.\n");
                p.classname = "";
                stuffcmd(p, "disconnect\n");
            }
        }
        p = find(p, classname, "player");
    }
    k_attendees = f1;
    if(k_attendees > 1)
        StartTimer();
    else
    {
        bprint(2, "Can't start! More players needed.\n");
        StopTimer();
        NextLevel();
    }
}

void AdminMatchStart ()
{
    entity p;
    float f1;

    f1 = 0;
    p = find(world, classname, "player");
    while(p != world)
    {
        if(p.netname != "")
        {
            if(p.ready && p.k_accepted == 2)
            {
                f1 = f1 + 1;
            }
            else
            {
                p.k_accepted = 0;
                bprint(2, p.netname, " was kicked by admin forcestart\n");
                sprint(p, 2, "Bye bye! Pay attention next time.\n");
                p.classname = "";
                stuffcmd(p, "disconnect\n");
            }
        }
        p = find(p, classname, "player");
    }
    k_attendees = f1;
    if(k_attendees)
        StartTimer();
    else
    {
        bprint(2, "Can't start! More players needed.\n");
        StopTimer();
        NextLevel();
    }
}

void AdminForceBreak ()
{
    string tmp;

    if(self.k_admin == 2 && self.classname != "player" && !match_in_progress)
    {
        k_force = 0;
        return;
    }
    if(self.k_admin != 2 || !match_in_progress)
        return;
    if(self.classname != "player" && match_in_progress == 1)
    {
        k_force = 0;
        StopTimer();

        return;
    }
    if(k_oldmaxspeed)
    {
        tmp = ftos(k_oldmaxspeed);
        cvar_set("sv_maxspeed", tmp);
    }
    dprint("%forcebreak%");
    dprint(self.netname);
    dprint("\n");
    bprint(2, self.netname, " forces a break!\nMATCH OVER!!\n");
    EndMatch(0);
}

void TogglePreWar ()
{
    entity p;
    float tmp;

    if(self.k_admin != 2)
        return;
    tmp = stof(infokey(world, "k_prewar"));
    if(tmp != 0)
    {
        localcmd("localinfo k_prewar 0\n");
        if(!match_in_progress)
        {
            bprint(2, "Players may îïô fire before match!\n");
            p = find(p, classname, "player");
            while(p != world)
            {
                if(p.netname != "")
                    stuffcmd(p, "-attack\n");
                p = find(p, classname, "player");
            }
        }
        else
            sprint(self, 2, "Players may îïô fire before match!\n");
        return;
    }
    localcmd("localinfo k_prewar 1\n");
    if(!match_in_progress)
        bprint(2, "Players may fire before match.\n");
    else
        sprint(self, 2, "Players may fire before match.\n");
}

void ToggleMapLock ()
{
    float tmp;

    if(self.k_admin != 2)
        return;
    tmp = stof(infokey(world, "k_lockmap"));
    if(tmp != 0)
    {
        localcmd("localinfo k_lockmap 0\n");
        if(!match_in_progress)
            bprint(2, self.netname, " unlocks map.\n");
        else
            sprint(self, 2, "Map unlocked.\n");
        return;
    }
    localcmd("localinfo k_lockmap 1\n");
    if(!match_in_progress)
        bprint(2, "Map is locked!\n");
    else
        sprint(self, 2, "Map is locked!\n");
}

void ToggleMaster ()
{
    float f1;
    string s1;

    if(self.k_admin != 2)
        return;
    f1 = stof(infokey(world, "k_master"));
    f1 = 1 - f1;
    if(f1)
    {
        bprint(2, self.netname, " sets mastermode!\nPlayers may îïô alter settings\n");
    }
    else
        bprint(2,"Mastermode disabled\nPlayers can now alter settings\n");
    s1 = ftos(f1);
    localcmd("localinfo k_master ");
    localcmd(s1);
    localcmd("\n");
}

void AdminForcePause ()
{
    entity e1;
    float f1;
    string s1;

    if(self.k_admin != 2 || match_in_progress != 2)
        return;
    k_pause = 1 - k_pause;
    WriteByte(2, 24);
    if(k_pause)
    {
        bprint(2, self.netname, " issues a pause");
        bprint(3, "\n");
        k_pausetime = time;
        k_oldmaxspeed = k_maxspeed;
        cvar_set("sv_maxspeed", "0");
        WriteByte(2, 1);
        e1 = nextent(world);
        while(e1 != world)
        {
            if(e1.nextthink > time)
            {
                e1.k_ptime = e1.nextthink;
                e1.nextthink = -1;
                if(e1.classname == "player")
                    e1.maxspeed = 0;
            }
            e1 = nextent(e1);
        }
    }
    else
    {
        bprint(3, "console: unpaused!\n");
        WriteByte(2, 0);
        e1 = nextent(world);
        f1 = time - k_pausetime;
        s1 = ftos(k_oldmaxspeed);
        cvar_set("sv_maxspeed", s1);
        while(e1 != world)
        {
            if(e1.nextthink == -1)
                e1.nextthink = f1 + e1.k_ptime;
            if(e1.classname == "player")
            {
                e1.maxspeed = k_oldmaxspeed;
                e1.pain_finished = f1 + e1.pain_finished;
                if(e1.invincible_finished)
                    e1.invincible_finished = f1 + e1.invincible_finished;
                if(e1.invisible_finished)
                    e1.invisible_finished = f1 + e1.invisible_finished;
                if(e1.super_damage_finished)
                    e1.super_damage_finished = f1 + e1.super_damage_finished;
                if(e1.super_damage_finished)
                    e1.radsuit_finished = f1 + e1.radsuit_finished;
                e1.air_finished = f1 + e1.air_finished;
            }
            else if(e1.classname == "dropring" || e1.classname == "dropquad")
                e1.cnt = f1 + e1.cnt;
            e1 = nextent(e1);
        }
    }
}

