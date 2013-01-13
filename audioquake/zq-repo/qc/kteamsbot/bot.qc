// !!! TEMPORARY functions for bot testing !!!
/* entity (string name) testbot = #83; */
/* void (entity e, string key, string value) setinfo = #84; */

void PlayerReady();


void DeveloperLightning (entity e1, entity e2, float flag)
{
};


void bot_map_load ()
{
	// place your qc loaded waypoints here

	if (mapname == "dm1")
		map_dm1();
	else if (mapname == "dm2")
		map_dm2();
	else if (mapname == "dm3")
		map_dm3();
	else if (mapname == "dm4")
		map_dm4();
	else if (mapname == "dm5")
		map_dm5();
	else if (mapname == "dm6")
		map_dm6();
}

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Variables and stuff

bot.qc has become pretty much a header file
for all variables in the bot...

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

// ----- entity fields ---
.float	wallhug, keys, oldkeys, ishuman;
.float	b_frags, b_clientno, b_shirt, b_pants; 
.float	ai_time, b_sound, missile_speed;
.float	portal_time, b_skill;
.float	b_aiflags, b_num, b_chattime;
.float	route_failed, dyn_flags, dyn_time;
.float	dyn_plat;
.entity	temp_way, last_way;
.entity	target1, target2, target3, target4;
.entity	_next, _last;
.entity	current_way;
.vector	b_angle, mouse_emu, obs_dir;
.vector	b_dir;
.float	forwardmove, sidemove, upmove;
.vector	dyn_dest;
.float	search_time;

// used for the physics & movement AI
float KEY_MOVEUP 		= 1;
float KEY_MOVEDOWN 	= 2;
float KEY_MOVELEFT 	= 4;
float KEY_MOVERIGHT 	= 8;
float KEY_MOVEFORWARD	= 16;
float KEY_MOVEBACK	= 32;
float KEY_LOOKUP		= 64;
float KEY_LOOKDOWN	= 128;
float KEY_LOOKLEFT	= 256;
float KEY_LOOKRIGHT	= 512;

// these are aiflags for waypoints
// some overlap to the bot
float AI_TELELINK_1	= 1; // link type
float AI_TELELINK_2	= 2; // link type
float AI_TELELINK_3	= 4; // link type
float AI_TELELINK_4	= 8; // link type
float AI_DOORFLAG		= 16; // read ahead
float AI_PRECISION	= 32; // read ahead + point
float AI_SURFACE		= 64; // point 
float AI_BLIND		= 128; // read ahead + point
float AI_JUMP		= 256; // point + ignore
float AI_DIRECTIONAL	= 512; // read ahead + ignore
float AI_PLAT_BOTTOM	= 1024; // read ahead 
float AI_RIDE_TRAIN	= 2048; // read ahead 
float AI_SUPER_JUMP	= 4096; // point + ignore + route test
float AI_SNIPER		= 8192; // point type 
float AI_AMBUSH		= 16384; // point type
float AI_DOOR_NO_OPEN	= 32768; // read ahead
float AI_DIFFICULT	= 65536; // route test
float AI_TRACE_TEST	= 131072; // route test

// these are flags for bots/players (dynamic/editor flags)
float AI_OBSTRUCTED	= 1;
float AI_HOLD_SELECT	= 2;
float AI_ROUTE_FAILED	= 2;
float AI_WAIT		= 4;
float AI_DANGER		= 8;

// addition masks
float AI_POINT_TYPES 	= 29152;
float AI_READAHEAD_TYPES	= 36528;
float AI_IGNORE_TYPES	= 4864;

float WM_UNINIT		= 0;
float WM_DYNAMIC		= 1;
float WM_LOADING		= 2;
float WM_LOADED		= 3;
// editor modes aren't available in QW, but we retain support of them
// since the editor is still built into the AI in places
float WM_EDITOR		= 4;
float WM_EDITOR_DYNAMIC	= 5;
float WM_EDITOR_DYNLINK	= 6;

float OPT_NOCHAT	= 2;

// -------globals-----
float		max_clients = 32;	/* Tonik --- only waypoint code checks it... */
float		bot_count, b_options;
float		waypoint_mode;
float		waypoints, direct_route;
entity		fixer;
entity		route_table;
entity 		player_head, way_head;
float		busy_waypoints;


// ------- Functions exported to the engine ----------
void	BotConnect ();
void	BotDisconnect ();
void	BotPreThink ();
void	BotPostThink ();


// -------Prototypes------

// rankings
float	ClientBitFlag (float clientno);

// waypointing
void	DynamicWaypoint ();
entity	make_waypoint (vector org);
void	ClearAllWays ();
void	FixWaypoints ();
float	begin_route ();
void	bot_get_path (entity this, float direct);
void	WaypointThink ();
entity	FindWayPoint (entity start);

// physics & movement
float	bot_can_rj (entity e);
void	bot_jump ();
void	frik_bot_roam ();
float	frik_walkmove (vector weird);
void	frik_movetogoal ();
void	frik_obstacles ();
float	frik_recognize_plat (float flag);
float	frik_KeysForDir (vector sdir);
void	frik_obstructed (vector whichway, float danger);
void	CL_KeyMove ();

// ai & misc
float	fov (entity targ);
float	angcomp (float y1, float y2);
float	wisible (entity targ1, entity targ2);
float	sisible (entity targ);
float	fisible (entity targ);
vector	realorigin (entity ent);
void	target_drop (entity ent);
void	target_add (entity ent);
void	KickABot ();
void	bot_lost (entity targ, float success);
string	BotName (entity ent, float r);
string	PickARandomName (entity ent);
float	frik_anglemod (float v);
void	bot_chat ();
void	bot_start_topic (float tpic);


// ----------Commands---------
void(entity e, float chan, string samp, float vol, float atten) real_sound = #8;
vector(entity e, float sped)		real_aim = #44;	

//----------------------------------------------------------------------------

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Function redeclarations. These allow function 
designed to work for clients (sprint, so forth)
to mainly not complain when working with a bot

Although these shouldn't be needed anymore,
as the bots truly are clients now, if you don't
stop the SZ_ buffer from filling up by disabling
direct messages to the bots, it crashes quake :-(

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

vector aim (entity e, float sped)
{
	e.missile_speed = sped;
	return real_aim(e, sped);
}

void sound (entity e, float chan, string samp, float vol, float atten)
{
	real_sound (e, chan, samp, vol, atten);

	if (samp == "items/inv3.wav")
		return;
	else if (e.classname == "player")
		e.b_sound = time + 1;
/* Tonik -- what the ****? */
	else if (other.classname == "player")
		other.b_sound = time + 1;
}

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Stuff mentioned up top
it just links the bot into the mod

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

float GetClientNum (entity ent);

void ClientConnected ()
{
	// link him into the player list
	if (player_head)
		player_head._last = self;
	self._next = player_head;
	player_head = self;

 	if (!stof(infokey(self, "*bot")))
	self.ishuman = true;
}


void ClientDisconnected ()
{
	if (player_head == self)
		player_head = self._next;
	if (self._next)
		self._next._last = self._last;
	if (self._last)
		self._last._next = self._next;
}

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Bot Chat code

The rest of this code is in bot_rank.qc

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void(entity client, float level, string s, string s2) sprint2 = #24;
void(float level, string s, string s2) bprint2	= #23;

void BotSay (string s)
{
	bprint2 (PRINT_CHAT, self.netname, s);
}
void BotSayInit ()
{
	bprint (PRINT_CHAT, self.netname);
}
void BotSay2 (string h)
{
	bprint (PRINT_CHAT, h);
}
void BotSayTeam (string h)
{
	// FBX QW doesn't support teamplay...yet
}


/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Rankings 'utilities'. Written by Alan Kivlin,
this code just fools clients by sending precisely
the same network messages as when a real player
signs on to the server.

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

float ClientBitFlag (float clientno)
{
	float	bitflag;

	bitflag = 1;
	while(clientno > 0)
	{
		bitflag = bitflag * 2;
		clientno = clientno - 1;
	}
	return bitflag;
}


/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

BotConnect and related functions.

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/				
entity GetClientEntity (float num)
{
	entity	upsy;
	upsy = world;
	num = num + 1;
	while (num > 0)
	{
		num = num - 1;
		upsy = nextent(upsy);
	}
	return upsy;
}

float GetClientNum (entity ent)
{
	entity upsy;
	float	num;

	upsy = world;
	num = 0;
	while (ent != upsy)
	{
		num = num + 1;
		upsy = nextent(upsy);
	}

	return num;
}

// called by the engine instead of ClientConnect for bots
void BotConnect ()
{
	ClientConnect ();

	bot_count = bot_count + 1;

	bot_start_topic(1);

	// load the waypoints if not loaded yet
	if (waypoint_mode < WM_LOADED)
		bot_map_load();

	self.b_clientno = GetClientNum(self);

/*	// players can set skill all weird, so leave these checks in
	whatskill = rint(whatskill);
	if (whatskill > 3)
		whatskill = 3;
	else if (whatskill < 0)
		whatskill = 0;
	self.b_skill = whatskill;
*/

	self.b_skill = 2;	// FIXME FIXME, skill should be saved across levels

	self.ready = 0; 
	PlayerReady();
}

// called by the engine instead of ClientDisconnect for bots
void BotDisconnect ()
{
	ClientDisconnect ();
	bot_count = bot_count - 1;
}


void BotAI ();	// Tonik

// called by the engine instead of PlayerPreThink for bots
void BotPreThink ()
{
	frik_obstacles();
	CL_KeyMove();
	BotAI ();

	if (self.b_frags != self.frags)
	{
		if (self.b_frags > self.frags)
		{
			if (pointcontents(self.origin) == CONTENT_LAVA)
				bot_start_topic(10);
			else
				bot_start_topic(9);
		}
		else
			bot_start_topic(2);
		self.b_frags = self.frags;
	}

	DynamicWaypoint();

	PlayerPreThink ();
}

// called by the engine instead of PlayerPostThink for bots
void BotPostThink ()
{
	PlayerPostThink ();		// just call the default function
}


void BotFrame ()
{
	string	h;
	
	h = infokey(world, "bot_options");
	b_options = stof(h);
}

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Client commands. Allow the player to perform bot
related functions.

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void Cmd_AddBot (string botnum_s, string skill_s)
{
	entity bot;
	float whatbot;

/*	float skill;
	if (skill_s != "")
		skill = stof(skill_s);
	else
		skill = 1;
*/

	whatbot = stof(botnum_s);

	bot = testbot("newbot");

	if (!bot)
	{
		bprint (PRINT_HIGH, "Unable to connect a bot, server is full.\n");
		return;
	}

	if (whatbot)
		bot.netname = BotName(bot, whatbot);
	else
		bot.netname = PickARandomName(bot);

	setinfo (bot, "name", bot.netname);

	string tmp;
	tmp = ftos(bot.b_shirt);
	setinfo (bot, "topcolor", tmp);

	tmp = ftos(bot.b_pants);
	setinfo (bot, "bottomcolor", tmp);
}

void Cmd_RemoveBot ()
{
	KickABot ();
}
