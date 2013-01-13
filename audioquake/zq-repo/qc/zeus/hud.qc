/*
===================
global variables
===================
*/

entity  HUD_box;
entity  HUD_tag;
entity  HUD_status_health;
entity  HUD_status_armor;
entity  HUD_status_ent;
entity  HUD_target;
entity  HUD_viewer;

float   HUD_active;
float   HUD_box_old_frame;

/*
======================
HUD_Precache
======================
*/
void () HUD_Precache =
{
  precache_model2 ("progs/hud_box.spr");
  precache_model2 ("progs/hud_tag.spr");
  precache_model2 ("progs/hud_stat.spr");
};


/*
======================
HUD_Init
======================
*/

void () HUD_Init =
{
  // exit if already initialized
  if (HUD_box != world) return;

  HUD_box = spawn ();
  HUD_box.solid = SOLID_NOT;
  HUD_box.flags = 0;
  HUD_box.movetype = MOVETYPE_NONE;
  HUD_box.angles = self.angles;
  HUD_box.classname = "HUD_target";
  setmodel (HUD_box, "");
  setsize (HUD_box, '0 0 0 ', '0 0 0');
  setorigin (HUD_box, '0 0 0');

  HUD_tag = spawn ();
  HUD_tag.solid = SOLID_NOT;
  HUD_tag.flags = 0;
  HUD_tag.movetype = MOVETYPE_NONE;
  HUD_tag.angles = self.angles;
  HUD_tag.classname = "HUD_tag";
  setmodel (HUD_tag, "");
  setsize (HUD_tag, '0 0 0 ', '0 0 0');
  setorigin (HUD_tag, '0 0 0');

  HUD_status_health = spawn ();
  HUD_status_health.solid = SOLID_NOT;
  HUD_status_health.flags = 0;
  HUD_status_health.movetype = MOVETYPE_NONE;
  HUD_status_health.angles = self.angles;
  HUD_status_health.classname = "HUD_status_health";
  setmodel (HUD_status_health, "");
  setsize (HUD_status_health, '0 0 0 ', '0 0 0');
  setorigin (HUD_status_health, '0 0 0');

  HUD_status_armor = spawn ();
  HUD_status_armor.solid = SOLID_NOT;
  HUD_status_armor.flags = 0;
  HUD_status_armor.movetype = MOVETYPE_NONE;
  HUD_status_armor.angles = self.angles;
  HUD_status_armor.classname = "HUD_status_armor";
  setmodel (HUD_status_armor, "");
  setsize (HUD_status_armor, '0 0 0 ', '0 0 0');
  setorigin (HUD_status_armor, '0 0 0');
};

/*
======================
HUD_UpdateTarget

Keeps the target pinned on the targ entity
======================
*/

void () HUD_UpdateTarget =
{
  local   float   dist;
  local   vector  dir, ang;

  dir = HUD_target.origin - HUD_viewer.origin;
  dist = vlen (dir);
  dir = normalize (dir);
  ang = vectoangles (dir);
  makevectors (ang);

  setorigin (self, HUD_target.origin - dir * 50 + '0 0 16');
  if (dist > 200)
    setorigin (HUD_tag, HUD_viewer.origin + HUD_viewer.view_ofs + dir * 200 + v_right * 32 + v_up * 32);
  else
    setorigin (HUD_tag, HUD_target.origin + HUD_viewer.view_ofs - dir * 50 + v_right * 32 + v_up * 32);
};

/*
======================
HUD_Shrink
======================
*/
void () HUD_Shrink =
{
  HUD_tag.frame = 2;

  if (self.frame >= 1) self.frame = self.frame - 2;
  if (self.frame < 1)
  {
    self.think = SUB_Null;
    self.nextthink = time + frametime;
    setmodel (HUD_box, "");
    setmodel (HUD_tag, "");
  }
  else
  {
    self.think = HUD_Shrink;
    self.nextthink = time + frametime;
  }
};

/*
======================
HUD_TargetOff
======================
*/
void (entity ent) HUD_TargetOff =
{
  ent.think = HUD_Shrink;
  ent.nextthink = time + frametime;
};

/*
======================
HUD_Follow
======================
*/
void () HUD_Follow =
{
  local   float   r;

  if (HUD_target.health > 0)
  {
    HUD_UpdateTarget ();
    HUD_tag.frame = 1;

    if (random () < 0.15)
    {
      r = random ();
      if (r < 0.25)
        self.frame = 16;
      else if (r < 0.5)
        self.frame = 17;
      else if (r < 0.75)
        self.frame = 18;
      else
        self.frame = 19;
    }
    else self.frame = 15;

    self.nextthink = time + frametime;
    self.think = HUD_Follow;
  }
  else
    HUD_TargetOff (self);
};

/*
======================
HUD_Grow
======================
*/
void () HUD_Grow =
{
  if (HUD_target.health > 0)
  {
    HUD_tag.frame = 0;

    if (self.frame < 15) self.frame = self.frame + 2;
    if (self.frame == 15)
      self.think = HUD_Follow;
    else
      self.think = HUD_Grow;
    self.nextthink = time + frametime;

    HUD_UpdateTarget ();
  }
  else
    HUD_TargetOff (self);
};

/*
======================
HUD_TargetOn
======================
*/
void (entity targ, entity viewer) HUD_TargetOn =
{
  if ((HUD_target == targ) && (HUD_viewer == viewer)) return;

  if (!HUD_active) return;

  HUD_target = targ;
  HUD_viewer = viewer;

  HUD_box.think = HUD_Grow;
  HUD_box.nextthink = time + frametime;

  setmodel (HUD_box, "progs/hud_box.spr");
  setmodel (HUD_tag, "progs/hud_tag.spr");
  HUD_box.frame = 1;
};

/*
======================
HUD_UpdateStatus

Keeps the status in player view,
updates the frames according to entity health
======================
*/
void () HUD_UpdateStatus =
{
  local   float   armor_max;

  if (HUD_viewer.classname == "player")
    makevectors (HUD_viewer.v_angle);
  else
    makevectors (HUD_viewer.angles);
  if (self.classname == "HUD_status_health")
  {
    if (HUD_status_ent.health <= 25)
      self.frame = 4;
    else if (HUD_status_ent.health <= 50)
      self.frame = 3;
    else if (HUD_status_ent.health <= 75)
      self.frame = 2;
    else if (HUD_status_ent.health < 100)
      self.frame = 1;
    else
      self.frame = 0;

    setorigin (HUD_status_health, HUD_viewer.origin + HUD_viewer.view_ofs + v_forward * 50 - v_right * 40 + v_up * 16);
  }
  else
  {
    if (HUD_status_ent.armortype == 0.3)
      armor_max = 100;
    else if (HUD_status_ent.armortype == 0.6)
      armor_max = 150;
    else
      armor_max = 200;

    if (HUD_status_ent.armorvalue <= armor_max / 4)
      self.frame = 9;
    else if (HUD_status_ent.armorvalue <= (armor_max / 4) * 2)
      self.frame = 8;
    else if (HUD_status_ent.armorvalue <= (armor_max / 4) * 3)
      self.frame = 7;
    else if (HUD_status_ent.armorvalue < (armor_max))
      self.frame = 6;
    else
      self.frame = 5;

    setorigin (HUD_status_armor, HUD_viewer.origin + HUD_viewer.view_ofs + v_forward * 50 - v_right * 40 + v_up * 12);
  }

  //self.think = HUD_UpdateStatus;
  //self.nextthink = time + frametime;
};


/*
======================
HUD_StatusOn
======================
*/
void (entity ent, entity viewer) HUD_StatusOn =
{
  if (!HUD_active) return;

  HUD_viewer = viewer;
  HUD_status_ent = ent;

  setmodel (HUD_status_health, "progs/hud_stat.spr");
  setmodel (HUD_status_armor, "progs/hud_stat.spr");
  HUD_status_armor.frame = 5;

  HUD_status_health.think = HUD_UpdateStatus;
  HUD_status_health.nextthink = time + frametime;
  HUD_status_armor.think = HUD_UpdateStatus;
  HUD_status_armor.nextthink = time + frametime;

  HUD_UpdateStatus ();
};

/*
======================
HUD_ShutDown
======================
*/
void () HUD_ShutDown =
{
  self.frame = self.frame - 2;
  if (self.frame < 1)
  {
    self.think = SUB_Null;
    setmodel (self, "");

    setmodel (HUD_status_armor, "");
    setmodel (HUD_status_health, "");
    setmodel (HUD_tag, "");
    HUD_status_armor.think = SUB_Null;
    HUD_status_health.think = SUB_Null;

    return;
  }
  else
  {
    if (HUD_viewer.classname == "player")
      makevectors (HUD_viewer.v_angle);
    else
      makevectors (HUD_viewer.angles);

    setorigin (self, HUD_viewer.origin + HUD_viewer.view_ofs + v_forward * 50 + '0 0 16');
    setorigin (HUD_tag, HUD_viewer.origin + HUD_viewer.view_ofs + v_forward * 150 + v_right * 110 + v_up * 75);

    self.think = HUD_ShutDown;
    self.nextthink = time + frametime;
  }
};

/*
======================
HUD_StatusOff
======================
*/
void () HUD_StatusOff =
{
  setmodel (HUD_tag, "progs/hud_tag.spr");
  HUD_tag.frame = 3;
  setmodel (HUD_box, "progs/hud_box.spr");
  HUD_box.frame = 15;
  HUD_box.think = HUD_ShutDown;
  HUD_box.nextthink = time + frametime;
};