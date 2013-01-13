// ZEUS bot - begin new entity fields

.entity		bot;		// bot entity
.entity         bot_owner;      // bot's owner
.entity         next_bot;       // next bot owned by bot's owner

.float		bot_flag;	// existence of bot (TRUE or FALSE)
.float          bot_attack;     // TRUE if attack okay, false if not to attack
.float          bot_view;       // (TRUE if seeing through bot, FALSE otherwise)
.float          bot_stay;       // (TRUE if bot is not following player)
.float          bot_avail;      // (TRUE if bot powerup taken during deathmatch)
.float          ZEUS_pain_delay;       // pain time for different bot skills

// variables for bot ai
.void ()        th_follow;

.float   forward_jump_vel;
.float   upward_jump_vel;

.float   ZEUS_weapon_range;
.float   ZEUS_optimal_range;
.float   ZEUS_minimum_range;
.float   ZEUS_only_axe;
.float   ZEUS_skill;

.float   ZEUS_UR_oldest;        // UR# of longest flagged item
.entity  ZEUS_UR_item_1;        // unreachable item 1
.entity  ZEUS_UR_item_2;        // unreachable item 2
.entity  ZEUS_UR_item_3;        // unreachable item 3

.float  ZEUS_UR_yaw_1;         // unreachable item 1, yaw at last sighting
.float  ZEUS_UR_yaw_2;         // unreachable item 2, yaw at last sighting
.float   ZEUS_UR_yaw_3;         // unreachable item 3, yaw at last sighting

.vector  ZEUS_UR_loc_1;         // unreachable item 1, location at last sighting
.vector  ZEUS_UR_loc_2;         // unreachable item 1, location at last sighting
.vector  ZEUS_UR_loc_3 ;         // unreachable item 1, location at last sighting

.vector  ZEUS_own_lastorg;
.float   ZEUS_stuck;            // TRUE if hung on a wall
.float   ZEUS_stuck_dir;        // direction of turn to get off of wall
.float   ZEUS_waterlevel;       // regular .waterlevel field is not updated
                                // the same as a client, so this must be used instead
.float   ZEUS_watertype;
.vector  ZEUS_last_enemy_loc;   // last known location of enemy

// roaming AI vars

.float   ZEUS_findtarget_skip;
.float   ZEUS_roam;             // TRUE = follow movetarget
                                // FALSE = follow bot_owner
.vector  ZEUS_last_roam_org;

// mapping fields
.entity  ZEUS_cur_map_node;
.entity  ZEUS_last_map_node;
.entity  ZEUS_link1;
.entity  ZEUS_link2;
.entity  ZEUS_link3;
.entity  ZEUS_link4;
.entity  ZEUS_link5;
.entity  ZEUS_link6;

// for keeping a singly linked list of nodes for linear searches
.entity  ZEUS_next_node;

// for keeping a list of nodes to a desired location
.entity  ZEUS_path;

// to track items visible from this node

.float   ZEUS_enemy_weapon;

// combat AI vars

// used in .attackstate to save current dir of strafe
// in combat
float AS_STRAFE_LEFT  = 5;
float AS_STRAFE_RIGHT = 6;

// ZEUS bot - end new entity fields

// gloabal temp variable for printing text and numbers -- because of
// Quake's global function parameter area
string  temp_text;
float   temp_float;

float	ZEUS_pathing;
