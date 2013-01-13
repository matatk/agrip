//ZEUS 2.0

// constants
float   LINK_ONE_WAY = 1;
float   LINK_TWO_WAY = 2;

// function prototypes
void    (float show_msg)                              ZEUS_Activate;
void    (float name_number, float new_name)           ZEUS_LevelRespawn;
void    (entity ent, string str1)                     ZEUS_sprint;
void    (float dir)                                   ZEUS_PlaceNode;
void    ()                                            ZEUS_SpawnMapNode;
void    (vector org, string mdl_name, float ent_time) ZEUS_SpawnMarker;
float   (entity targ)                                 ZEUS_visible;
void    (string str1)                                 Debug_Msg;
void    (string str1)                                 Debug_Msgln;
void    ()                                            ZEUS_EnemyWeapon;
void    ()                                            ZEUS_CheckImpulses;

// variables for dynamic mapping
entity  ZEUS_map_first;
entity  ZEUS_map_last;
float   node_count;
float   nodes_visible;
float   ZEUS_activate_level_bot;
float   ZEUS_show_info;
float   ZEUS_info_count;

// the last opponent spawned, for debugging
entity  ZEUS_last_opponent;
entity  ZEUS_first_opponent;
entity  ZEUS_spawn_temp;

// number of deathmatch bots active;
float   ZEUS_opponent_bots;

// name of item that bot is seeking after
string  seek_string;