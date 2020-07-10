/*
==========================================================================

ZEUS 2.x Dynamic Mapping Routines

==========================================================================
*/

/*
======================
ZEUS_NodeVisible
======================
*/

float (entity targ) ZEUS_NodeVisible =
{
  local   vector  spot1, spot2;

  spot1 = self.origin + self.view_ofs;
  spot2 = targ.origin + targ.view_ofs;
  traceline (spot1, spot2, true, self);	// see through other monsters

  if ((trace_fraction == 1) || (trace_ent == targ))
    return true;

  return false;
};

/*
======================
ZEUS_ItemValue

returns a float that reflects the value of ent relative to other items
of that type
======================
*/

float (entity ent) ZEUS_ItemValue =
{
  if (ent == world) return 0;

  if (ent.classname == "item_health")
    return ent.healamount;
  else if (ent.classname == "item_shells")
    return 60;
  else if (ent.classname == "item_nails")
    return 70;
  else if (ent.classname == "item_rockets")
    return 80;
  else if (ent.classname == "item_cells")
    return 90;
  else if (ent.classname == "weapon_rocketlauncher")
    return 1000;
  else if (ent.classname == "weapon_lightning")
    return 750;
  else if (ent.classname == "weapon_supernailgun")
    return 600;
  else if (ent.classname == "weapon_grenadelauncher")
    return 500;
  else if (ent.classname == "weapon_supershotgun")
    return 300;
  else if (ent.classname == "weapon_nailgun")
    return 200;
  else if (ent.classname == "weapon_shotgun")
    return 100;
  else if (ent.classname == "item_cells")
    return 90;
  else if (ent.classname == "item_rockets")
    return 80;
  else if (ent.classname == "item_spikes")
    return 70;
  else if (ent.classname == "item_shells")
    return 60;
  else if (ent.classname == "item_armorInv")
    return 1000;
  else if (ent.classname == "item_armor2")
    return 500;
  else if (ent.classname == "item_armor1")
    return 250;
  else if (ent.classname == "item_artifact_super_damage")
    return 1500;
  else if (ent.classname == "item_artifact_invulnerability")
    return 1400;
  else if (ent.classname == "item_artifact_invisibility")
    return 1300;

  return 0;
};

/*
======================
ZEUS_LinkNode

links an already existing node to the last node visited
======================
*/

void (entity last_node, entity old_node) ZEUS_LinkNode =
{
 local   float   pc1, pc2;
	
 if (last_node == old_node)
 {
   Debug_Msg ("node linked to itself!\n");
   return;
 }

 if ((last_node == world) || (old_node == world)) return;

 pc1 = pointcontents (last_node.origin);
 pc2 = pointcontents (old_node.origin);
 if (pc1 != pc2) 
   return;

 // if already linked then just exit
 if (last_node.ZEUS_link1 == old_node)
   return;
 else if (last_node.ZEUS_link2 == old_node)
   return;
 else if (last_node.ZEUS_link3 == old_node)
   return;
 else if (last_node.ZEUS_link4 == old_node)
   return;
 else if (last_node.ZEUS_link5 == old_node)
   return;
 else if (last_node.ZEUS_link6 == old_node)
   return;

 if (last_node.ZEUS_link1 == world)
   last_node.ZEUS_link1 = old_node;
 else if (last_node.ZEUS_link2 == world)
   last_node.ZEUS_link2 = old_node;
 else if (last_node.ZEUS_link3 == world)
   last_node.ZEUS_link3 = old_node;
 else if (last_node.ZEUS_link4 == world)
   last_node.ZEUS_link4 = old_node;
 else if (last_node.ZEUS_link5 == world)
   last_node.ZEUS_link5 = old_node;
 else if (last_node.ZEUS_link6 == world)
   last_node.ZEUS_link6 = old_node;
};

/*
======================
ZEUS_MakeNode

makes a new node and links it to last_node, also links last_node to new node
if dir is LINK_TWO_WAY.  Notably, teleporters do not automatically link both ways
======================
*/

entity (vector org, entity last_node, float dir) ZEUS_MakeNode =
{
  local   entity  node, head;
  local   float   val1, i, pc1, pc2;

//  Debug_Msg ("adding node\n");

  node = spawn ();

  node_count = node_count + 1;

  // set up linked list of nodes
  // is this the first node created?
  if (ZEUS_map_first == world)
  {
    ZEUS_map_first = node;
    node.ZEUS_next_node = world;
    nodes_visible = false;
  }
  else // any node created after the first
  {
    head = ZEUS_map_first;
    i = 2;
    while ((head.ZEUS_next_node != world) && (i <= node_count + 1))
    {
      head = head.ZEUS_next_node;
      i = i + 1;
    }
    if (i != node_count)
    {
      temp_text = ftos (node_count);
      Debug_Msg ("node_count = ");
      Debug_Msg (temp_text);
      temp_text = ftos (i);
      Debug_Msg (", i = ");
      Debug_Msg (temp_text);
      Debug_Msg ("\n");
      Debug_Msg ("MakeNode: error, list does not terminate.\n");
      return;
    }
    else
    {
      head.ZEUS_next_node = node;
      node.ZEUS_next_node = world;
    }
  }

  node.ZEUS_link1 = world;
  node.ZEUS_link2 = world;
  node.ZEUS_link3 = world;
  node.ZEUS_link4 = world;
  node.ZEUS_link5 = world;
  node.ZEUS_link6 = world;

  node.solid = SOLID_NOT;
  setsize (node, '0 0 0', '0 0 0');
  if (nodes_visible)
    setmodel (node, "progs/h_player.mdl");
  setorigin (node, org);
  node.classname = "ZEUS_map_node";


  // link last node to new node
  if (last_node != world)
  {
    pc1 = pointcontents (last_node.origin);
    pc2 = pointcontents (node.origin);
    if (pc1 == pc2) 
	{
      if (last_node.ZEUS_link1 == world)
        last_node.ZEUS_link1 = node;
      else if (last_node.ZEUS_link2 == world)
        last_node.ZEUS_link2 = node;
      else if (last_node.ZEUS_link3 == world)
        last_node.ZEUS_link3 = node;
      else if (last_node.ZEUS_link4 == world)
        last_node.ZEUS_link4 = node;
      else if (last_node.ZEUS_link5 == world)
        last_node.ZEUS_link5 = node;
      else if (last_node.ZEUS_link6 == world)
        last_node.ZEUS_link6 = node;
    }
  }

  temp_text = ftos (node_count);
  Debug_Msg (temp_text);
  Debug_Msgln (" nodes active");

  // now search for and make a note of any important items visible from
  // this node, ie. health, armor, weapons and ammo

  if (self.classname == "player")
    return node;

  head = findradius(org, 750);

  while (head)
  {
    if (head.netname == "")
      head = head.chain;
    else
    {
      if (ZEUS_NodeVisible (head))
      {
        val1 = ZEUS_ItemValue (head);
        if ((head.classname == "item_health") || (head.classname == "item_artifact_invulnerability") ||
           (head.classname == "item_artifact_super_damage") || (head.classname == "item_artifact_invisibility"))
        {
          if (val1 > ZEUS_ItemValue (node.ZEUS_UR_item_1))
            node.ZEUS_UR_item_1 = head;
        }
        else if ((head.classname == "weapon_supershotgun") || (head.classname == "weapon_nailgun") ||
                (head.classname == "weapon_supernailgun") || (head.classname == "weapon_grenadelauncher") ||
                (head.classname == "weapon_rocketlauncher") || (head.classname == "weapon_lightning") ||
                (head.classname == "item_shells") || (head.classname == "item_nails") ||
                (head.classname == "item_rockets") || (head.classname == "item_cells"))
        {
          if (val1 > ZEUS_ItemValue (node.ZEUS_UR_item_2))
            node.ZEUS_UR_item_2 = head;
        }
        else if ((head.classname == "item_armor1") || (head.classname == "item_armor2") ||
                 (head.classname == "item_armorInv"))
        {
          if (val1 > ZEUS_ItemValue (node.ZEUS_UR_item_3))
            node.ZEUS_UR_item_3 = head;
        }
      }
      head = head.chain;
    }
  }
  return node;
};

/*
======================
ZEUS_NearNode

returns the first node visible from self
======================
*/

entity (vector org) ZEUS_NearNode =
{
  local   entity  head;
  local   float   c;

  c = 0;
  head = ZEUS_map_first;

  while ((head != world) && (!ZEUS_NodeVisible (head)))
  {
    c = c + 1;
    head = head.ZEUS_next_node;
  }

  temp_text = ftos (c);
  Debug_Msg (temp_text);
  Debug_Msgln (" nodes vis_checked");

  return head;
};

/*
======================
ZEUS_CurrentNode

returns the closest visible node to self
======================
*/

entity (entity ent) ZEUS_CurrentNode =
{
  local   entity   head, cur_node, temp;
  local   float    last_dist, dist, i;

  temp = self;
  self = ent;

  last_dist = 600;
  i = 0;
  head = ZEUS_map_first;
  while ((head != world) && (i <= node_count))
  {
    dist = vlen (self.origin - head.origin);
    if ((ZEUS_NodeVisible (head)) && (dist < last_dist) && (fabs (self.origin_z - head.origin_z) < 48))
    {
      last_dist = dist;
      cur_node = head;
    }

    head = head.ZEUS_next_node;
    i = i + 1;
  }

  if ((cur_node != world) && (nodes_visible))
    cur_node.effects = EF_DIMLIGHT;
  else if ((cur_node == world) && (self.ZEUS_cur_map_node != world))
    self.ZEUS_cur_map_node.effects = 0;

  if ((cur_node != world) && (cur_node != self.ZEUS_cur_map_node))
  {
    // we've found a new current node, so we must adjust last_map_node and last_map_node2 to
    // reflect it

    Debug_Msgln ("linking old nodes");
    ZEUS_LinkNode (self.ZEUS_cur_map_node, cur_node);
    if ((self.ZEUS_last_map_node != world) && (nodes_visible))
      setmodel (self.ZEUS_last_map_node, "progs/h_player.mdl");

    self.ZEUS_last_map_node = self.ZEUS_cur_map_node;
    self.ZEUS_cur_map_node = cur_node;

    if ((self.ZEUS_last_map_node != world) && (nodes_visible))
      setmodel (self.ZEUS_last_map_node, "progs/g_rock2.mdl");

    if (nodes_visible)
      setmodel (self.ZEUS_cur_map_node, "progs/grenade.mdl");

    if (self.ZEUS_cur_map_node == self.ZEUS_last_map_node)
      Debug_Msgln ("Doh! cur_map_node == last_map_node\n");
  }

  self = temp;

  return cur_node;
};

/*
======================
ZEUS_SpawnMapNode
======================
*/

void () ZEUS_SpawnMapNode =
{
  local   entity  old_node;

  Debug_Msg ("SpawnMapNode: ");

  old_node = ZEUS_CurrentNode (self);

  // no node found, so make a new one
  if (!old_node)
  {
    self.ZEUS_last_map_node = world;
    self.ZEUS_cur_map_node = ZEUS_MakeNode (self.origin, world, LINK_ONE_WAY);
    Debug_Msg ("new node ");
  }
};

/*
======================
ZEUS_PlaceNode
======================
*/

void (float dir) ZEUS_PlaceNode =
{
  local   entity  old_node, cur_node;

  // if falling, don't place a node
  if (!(self.flags & FL_ONGROUND) && (self.velocity_z != 0))
    return;

  // if just teleported, don't place a node
  if (self.teleport_time > time + 0.3) return;

  // if last node is still visible, don't make a new one
  cur_node = ZEUS_CurrentNode (self);
  if (cur_node != world) return;

  // if on a platform/door going up, don't make nodes except at top and bottom
  traceline (self.origin, self.origin - '0 0 32', true, self);
  if (((trace_ent.classname == "plat") || (trace_ent.classname == "door")) &&
      (trace_ent.velocity_z != 0))
    return;

  // don't place nodes in lava or slime
  if (self.classname == "zeus_bot")
  {
    if ((self.ZEUS_waterlevel > 0) && ((self.ZEUS_watertype == CONTENT_LAVA) ||
        (self.ZEUS_watertype == CONTENT_SLIME)))
      return;
  }
  else if (self.classname == "player")
  {
    if ((self.waterlevel > 0) && ((self.watertype == CONTENT_LAVA) ||
        (self.watertype == CONTENT_SLIME)))
      return;
  }

  Debug_Msgln ("PlaceNode");

  // last node is now not visible, so make a new one at the bot's last pos
  if (!cur_node)
  {
    if ((self.ZEUS_last_map_node != world) && (nodes_visible))
      setmodel (self.ZEUS_last_map_node, "progs/h_player.mdl");

    self.ZEUS_last_map_node = self.ZEUS_cur_map_node;

    if ((self.ZEUS_last_map_node != world) && (nodes_visible))
    {
      self.ZEUS_last_map_node.effects = 0;
      setmodel (self.ZEUS_last_map_node, "progs/g_rock2.mdl");
    }

    self.ZEUS_cur_map_node = ZEUS_MakeNode (self.ZEUS_own_lastorg, self.ZEUS_cur_map_node, dir);

    if (nodes_visible)
    {
      self.ZEUS_cur_map_node.effects = EF_DIMLIGHT;
      setmodel (self.ZEUS_cur_map_node, "progs/grenade.mdl");
    }
  }
};

/*
======================
ZEUS_ToggleNodesVis
======================
*/

void () ZEUS_ToggleNodesVis =
{
  local   entity  head;

  if (nodes_visible)
    temp_text = "";
  else
    temp_text = "progs/h_player.mdl";

  nodes_visible = !nodes_visible;

  head = ZEUS_map_first;

  while (head != world)
  {
    setmodel (head, temp_text);

    head = head.ZEUS_next_node;
  }
};

/*
======================
ZEUS_AddPathNode

Adds a single node to self's path.  A path is a list of nodes that
represents a sequence of nodes required to get from one map location
to another

Input:   entity node - node to append
Output:  entity - last node in path
Changes: self.ZEUS_path
======================
*/

entity (entity node) ZEUS_AddPathNode =
{
  local   entity  new_node, temp;

  new_node = spawn ();

  // links to other nodes
  new_node.ZEUS_link1 = node.ZEUS_link1;
  new_node.ZEUS_link2 = node.ZEUS_link2;
  new_node.ZEUS_link3 = node.ZEUS_link3;
  new_node.ZEUS_link4 = node.ZEUS_link4;
  new_node.ZEUS_link5 = node.ZEUS_link5;
  new_node.ZEUS_link6 = node.ZEUS_link6;

  // items available at this node
  new_node.ZEUS_UR_item_1 = node.ZEUS_UR_item_1;
  new_node.ZEUS_UR_item_2 = node.ZEUS_UR_item_2;
  new_node.ZEUS_UR_item_3 = node.ZEUS_UR_item_3;

  // location of node
  new_node.origin = node.origin;
  new_node.model = node.model;
  new_node.solid = node.solid;
  new_node.size = node.size;
  new_node.classname = node.classname;

  if (self.ZEUS_path == world)
  {
    self.ZEUS_path = new_node;
    new_node.ZEUS_next_node = world;
  }
  else
  {
    // find last node in path
    temp = self.ZEUS_path;
    while (temp.ZEUS_next_node != world)
    {
      temp = temp.ZEUS_next_node;
    }

    // put new node on the end
    temp.ZEUS_next_node = new_node;
    new_node.ZEUS_next_node = world;
  }

  return new_node;
};

/*
======================
ZEUS_RemovePathNode

removes the first node in self's path.  A path is a list of nodes that
represents a sequence of nodes required to get from one map location
to another

Input:   entity check_node - the current node of the bot which should always
         equal the first path node, if not then the path was not achievable
         and we must trash it
Output:  float - true if path was valid and node was removed
Changes: self.ZEUS_path
======================
*/

float (entity check_node) ZEUS_RemovePathNode =
{
  local   entity  temp;

  if (self.ZEUS_path == world)
    return false;

  // remove first node in path
  temp = self.ZEUS_path;
  self.ZEUS_path = self.ZEUS_path.ZEUS_next_node;
  remove (temp);

  return true;
};

/*
======================
ZEUS_EmptyPath
======================
*/
void () ZEUS_EmptyPath =
{
  while (self.ZEUS_path != world)
    ZEUS_RemovePathNode (self.ZEUS_path);
};

/*
======================
ZEUS_ShowItemsInNode

lists the valuable items in the passed node

Input:   entity node - node to list
Output:  none
Changes: none
======================
*/

void (entity node) ZEUS_ShowItemsInNode =
{
  if (node == world)
    return;

  Debug_Msg ("Node health = ");
  if (node.ZEUS_UR_item_1 != world)
    Debug_Msg (node.ZEUS_UR_item_1.classname);
  Debug_Msg ("\n");

  Debug_Msg ("Node weapon = ");
  if (node.ZEUS_UR_item_2 != world)
    Debug_Msg (node.ZEUS_UR_item_2.classname);
  Debug_Msg ("\n");

  Debug_Msg ("Node armor = ");
  if (node.ZEUS_UR_item_3 != world)
    Debug_Msg (node.ZEUS_UR_item_3.classname);
  Debug_Msg ("\n");
};

/*
======================
ZEUS_UpdateNodeItems

updates a node to make sure that all valuable items are found
If an item is picked up just before a new node is made, that
item will not be visible when the node is made and will be skipped
even though it will respawn.  This procedure should be called
when an item is picked up to make sure that it has been tested
for inclusion in the node's item list.
======================
*/

void (entity item) ZEUS_UpdateNodeItems =
{
  local   entity  cur_node, temp;
  local   float   val1;

//  if (other.classname == "player") return;

  cur_node = other.ZEUS_cur_map_node;
  if (!cur_node)
    return;

  // make SURE item is visible from the current node, or don't update it
//  if (!ZEUS_visible (cur_node))
//    return;

  val1 = ZEUS_ItemValue (item);

  if ((item.classname == "item_health") || (item.classname == "item_artifact_invulnerability") ||
      (item.classname == "item_artifact_super_damage") || (item.classname == "item_artifact_invisibility"))
  {
    if (val1 > ZEUS_ItemValue (cur_node.ZEUS_UR_item_1))
      cur_node.ZEUS_UR_item_1 = item;
  }
  else if ((item.classname == "weapon_supershotgun") || (item.classname == "weapon_nailgun") ||
           (item.classname == "weapon_supernailgun") || (item.classname == "weapon_grenadelauncher") ||
           (item.classname == "weapon_rocketlauncher") || (item.classname == "weapon_lightning") ||
           (item.classname == "item_shells") || (item.classname == "item_spikes") ||
           (item.classname == "item_rockets") || (item.classname == "item_cells"))
  {
    if (val1 > ZEUS_ItemValue (cur_node.ZEUS_UR_item_2))
      cur_node.ZEUS_UR_item_2 = item;
  }
  else if ((item.classname == "item_armor1") || (item.classname == "item_armor2") ||
           (item.classname == "item_armorInv"))
  {
    if (val1 > ZEUS_ItemValue (cur_node.ZEUS_UR_item_3))
      cur_node.ZEUS_UR_item_3 = item;
  }
};

/*
======================
ZEUS_HighNodeCount

returns the node linked to cur_node that has the highest cnt value
======================
*/
entity (entity cur_node) ZEUS_HighNodeCount =
{
  local   entity  high_node;
  local   float   high_cnt;

  high_cnt = 0;
  high_node = cur_node;

  if (cur_node.ZEUS_link1.cnt > high_cnt)
  {
    high_cnt = cur_node.ZEUS_link1.cnt;
    high_node = cur_node.ZEUS_link1;
  }
  if (cur_node.ZEUS_link2.cnt > high_cnt)
  {
    high_cnt = cur_node.ZEUS_link2.cnt;
    high_node = cur_node.ZEUS_link2;
  }
  if (cur_node.ZEUS_link3.cnt > high_cnt)
  {
    high_cnt = cur_node.ZEUS_link3.cnt;
    high_node = cur_node.ZEUS_link3;
  }
  if (cur_node.ZEUS_link4.cnt > high_cnt)
  {
    high_cnt = cur_node.ZEUS_link4.cnt;
    high_node = cur_node.ZEUS_link4;
  }
  if (cur_node.ZEUS_link5.cnt > high_cnt)
  {
    high_cnt = cur_node.ZEUS_link5.cnt;
    high_node = cur_node.ZEUS_link5;
  }
  if (cur_node.ZEUS_link6.cnt > high_cnt)
  {
    high_cnt = cur_node.ZEUS_link6.cnt;
    high_node = cur_node.ZEUS_link6;
  }

  return high_node;
};

/*
======================
ZEUS_IsLinked

return true if first_node contains a link to second_node
======================
*/

float (entity first_node, entity second_node) ZEUS_IsLinked =
{
  if (first_node.ZEUS_link1 == second_node)
    return true;
  else if (first_node.ZEUS_link2 == second_node)
    return true;
  else if (first_node.ZEUS_link3 == second_node)
    return true;
  else if (first_node.ZEUS_link4 == second_node)
    return true;
  else if (first_node.ZEUS_link5 == second_node)
    return true;
  else if (first_node.ZEUS_link6 == second_node)
    return true;
  else
    return false;
};

/*
======================
ZEUS_ShortestPath

finds the shortest route to node dest_node from node
cur_node
======================
*/
/*
float (entity cur_node, entity dest_node) ZEUS_ShortestPath =
{
  local   entity  head;
  local   float   i, j;

//  return;

  if ((cur_node == world) || (dest_node == world))
    return;

  temp_text = ftos (node_count);
  Debug_Msg ("ShortestPath: ");
  Debug_Msg (temp_text);
  Debug_Msg (" nodes.\n");

  // set all counters in list to 0
  head = ZEUS_map_first;
  j = 0;
  while ((head != world) && (j <= node_count))
  {
    head.cnt = 0;
    head.aflag = 0;
    head = head.ZEUS_next_node;
    j = j + 1;
  }
  if (j > node_count)
    Debug_Msg ("cnt set: j exceeded node_count\n");

  dest_node.cnt = 1;
  i = 0;  // runaway counter for impossible paths

  // find the path
  while ((cur_node.cnt == 0) && (i <= node_count))
  {
    // now, check each node, if aflag == 0 and cnt > 0 find all nodes linked to
    // it, increment each one's cnt, and set each one's aflag
    head = ZEUS_map_first;
    j = 0;
    while ((head != world) && (j <= node_count))
    {
      if ((head.cnt > 0) && (head.aflag <= i))
      {
        // inc this one's cnt
        head.cnt = head.cnt + 1;

        // set it's aflag so we know it has been incremented this loop
        head.aflag = head.aflag + 1;

        // now find all nodes linked to this one. if their aflag <= i and their cnt == 0
        // inc their cnt and increment their aflag
        if (head.ZEUS_link1)
        {
          if (head.ZEUS_link1)
          {
            if ((head.ZEUS_link1.aflag <= i) && (head.ZEUS_link1.cnt == 0) && (ZEUS_IsLinked (head.ZEUS_link1, head)))
            {
              head.ZEUS_link1.aflag = i + 1;
              head.ZEUS_link1.cnt = head.ZEUS_link1.cnt + 1;
            }
            if (head.ZEUS_link2)
            {
              if ((head.ZEUS_link2.aflag <= i) && (head.ZEUS_link2.cnt == 0) && (ZEUS_IsLinked (head.ZEUS_link2, head)))
              {
                head.ZEUS_link2.aflag = i + 1;
                head.ZEUS_link2.cnt = head.ZEUS_link2.cnt + 1;
              }
              if (head.ZEUS_link3)
              {
                if ((head.ZEUS_link3.aflag <= i) && (head.ZEUS_link3.cnt == 0) && (ZEUS_IsLinked (head.ZEUS_link3, head)))
                {
                  head.ZEUS_link3.aflag = i + 1;
                  head.ZEUS_link3.cnt = head.ZEUS_link3.cnt + 1;
                }
                if (head.ZEUS_link4)
                {
                  if ((head.ZEUS_link4.aflag <= i) && (head.ZEUS_link4.cnt == 0) && (ZEUS_IsLinked (head.ZEUS_link4, head)))
                  {
                    head.ZEUS_link4.aflag = i + 1;
                    head.ZEUS_link4.cnt = head.ZEUS_link4.cnt + 4;
                  }
                  if (head.ZEUS_link5)
                  {
                    if ((head.ZEUS_link5.aflag <= i) && (head.ZEUS_link5.cnt == 0) && (ZEUS_IsLinked (head.ZEUS_link5, head)))
                    {
                      head.ZEUS_link5.aflag = i + 1;
                      head.ZEUS_link5.cnt = head.ZEUS_link5.cnt + 5;
                    }
                    if (head.ZEUS_link6)
                    {
                      if ((head.ZEUS_link6.aflag <= i) && (head.ZEUS_link6.cnt == 0) && (ZEUS_IsLinked (head.ZEUS_link6, head)))
                      {
                        head.ZEUS_link6.aflag = i + 1;
                        head.ZEUS_link6.cnt = head.ZEUS_link6.cnt + 1;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      head = head.ZEUS_next_node;
      j = j + 1;
    }
    i = i + 1;
  }

  if (cur_node.cnt > 0)
  {
    // clear any path that exist from self
    ZEUS_EmptyPath ();

    // now build the path (list of nodes) for the bot to use while going from node to node
    // start at current node
    i = 0;
    head = cur_node;

    while ((head != dest_node) && (head != world) && (i <= node_count))
    {
      ZEUS_AddPathNode (head);
      head = ZEUS_HighNodeCount (head);

      i = i + 1;
    }

    if (head == dest_node)
    {
      head = ZEUS_AddPathNode (head);

      Debug_Msg ("Going for ");
      Debug_Msg (seek_string);
      Debug_Msg ("\n");

      return true;
    }
    else
    {
      Debug_Msg ("Invalid path to ");
      Debug_Msg (seek_string);
      Debug_Msg ("\n");

      return false;
    }
  }

  Debug_Msg ("No path to ");
  Debug_Msg (seek_string);
  Debug_Msg ("\n");

  return false;
};
*/
/*
======================
ZEUS_ShortestPath

finds the shortest route to node dest_node from node
cur_node
======================
*/

float (entity cur_node, entity dest_node) ZEUS_ShortestPath =
{
	local	float	ct, i, high_count, is_linked, j;
	local	entity	head, high_link, temp, path;

	if ((cur_node == world) || (dest_node == world))
		return;

	if (!ZEUS_pathing) return;

	// reset counts in all nodes
	head = ZEUS_map_first;
	j = 0;
	while ((head != world) && (j <= node_count))
	{
		head.cnt = 0;
		head.aflag = 0;
		head = head.ZEUS_next_node;
		j = j + 1;
	}

	// find the shortest path

	cur_node.cnt = 1;
	ct = 0; // runaway counter for impossible paths
	while (dest_node.cnt == 0 && ct <= node_count)
	{
		head = ZEUS_map_first;
		j = 0;
		
		// reset all flags in all nodes
		while ((head != world) && (j <= node_count))
		{
			head.cnt = 0;
			head.aflag = 0;
			head = head.ZEUS_next_node;
			j = j + 1;
		}

		head = ZEUS_map_first;
		j = 0;
		while (head != world && j <= node_count / 2)
		{
			if (head.cnt > 0 && head.aflag == 0)
			{
				head.cnt = head.cnt + 1;
				head.aflag = 255;

				if (head.ZEUS_link1)
				{
					if (head.ZEUS_link1.aflag == 0 && head.ZEUS_link1.cnt < 1)
					{
						head.ZEUS_link1.cnt = head.ZEUS_link1.cnt + 1;
						head.ZEUS_link1.aflag = 255;
					}
				}
				if (head.ZEUS_link2)
				{
					if (head.ZEUS_link2.aflag == 0 && head.ZEUS_link2.cnt < 1)
					{
						head.ZEUS_link2.cnt = head.ZEUS_link2.cnt + 1;
						head.ZEUS_link2.aflag = 255;
					}
				}
				if (head.ZEUS_link3)
				{
					if (head.ZEUS_link3.aflag == 0 && head.ZEUS_link3.cnt < 1)
					{
						head.ZEUS_link3.cnt = head.ZEUS_link3.cnt + 1;
						head.ZEUS_link3.aflag = 255;
					}
				}
				if (head.ZEUS_link4)
				{
					if (head.ZEUS_link4.aflag == 0 && head.ZEUS_link4.cnt < 1)
					{
						head.ZEUS_link4.cnt = head.ZEUS_link4.cnt + 1;
						head.ZEUS_link4.aflag = 255;
					}
				}
				if (head.ZEUS_link5)
				{
					if (head.ZEUS_link5.aflag == 0 && head.ZEUS_link5.cnt < 1)
					{
						head.ZEUS_link5.cnt = head.ZEUS_link5.cnt + 1;
						head.ZEUS_link5.aflag = 255;
					}
				}
				if (head.ZEUS_link6)
				{
					if (head.ZEUS_link6.aflag == 0 && head.ZEUS_link6.cnt < 1)
					{
						head.ZEUS_link6.cnt = head.ZEUS_link6.cnt + 1;
						head.ZEUS_link6.aflag = 255;
					}
				}
			}

			head = head.ZEUS_next_node;
			j = j + 1;
		}

		ct = ct + 1;
	}

	// now build the path for the bot to follow
	path = world;

	if (dest_node.cnt > 0)
	{
	    // clear any path that exist from self
	    ZEUS_EmptyPath ();

		head = dest_node;
		j = 0;
		while (head != world && head != cur_node && j <= node_count)
		{
			ZEUS_AddPathNode (head);

			head = ZEUS_HighNodeCount (head);
		}

		if (head == cur_node)
		{
			Debug_Msg ("Going for ");
			Debug_Msg (seek_string);
			Debug_Msg ("\n");

			return true;
		}
		else
		{
			ZEUS_EmptyPath ();

			Debug_Msg ("Invalid path to ");
			Debug_Msg (seek_string);
			Debug_Msg ("\n");
			return false;
		}
	}

	Debug_Msg ("no path to ");
	Debug_Msg (seek_string);
	Debug_Msg ("\n");

	return false;
};

/*
======================
ZEUS_FindItem

returns the node where an item matching item_name can be found or
world if none

returns world if self is already in the node with that item, which
would mean that the item has not respawned yet
======================
*/
entity (string item_name) ZEUS_FindItem =
{
  local   entity  head;
  local   float   match, i;

  head = ZEUS_map_first;
  match = false;
  i = 0;

  while ((head != world) && (!match) && (i <= node_count + 1))
  {
    if ((head.ZEUS_UR_item_1.classname == item_name) ||
        (head.ZEUS_UR_item_2.classname == item_name) ||
        (head.ZEUS_UR_item_3.classname == item_name))
      match = true;
    else
      head = head.ZEUS_next_node;

    i = i + 1;
  }

  if (i > node_count)
    Debug_Msg ("FindItem: list corrupted.\n");

  if (head)
  {
    seek_string = item_name;
    if (ZEUS_CurrentNode (self) == head)
      return world;
  }
  return head;
};

/*
======================
ZEUS_MarkerRocketTouch
======================
*/
void () ZEUS_MarkerRocketTouch =
{
  self.velocity = '0 0 0';
  self.movetype = MOVETYPE_NONE;
};


/*
======================
ZEUS_SpawnMarkerRocket
======================
*/
void (vector org, vector end) ZEUS_SpawnMarkerRocket =
{
  local   entity  new_mis;
  local   vector  dir;

  new_mis = spawn ();

  dir = normalize (end - org);
  new_mis.solid = SOLID_BBOX;
  new_mis.movetype = MOVETYPE_FLY;
  setmodel (new_mis, "progs/missile.mdl");
  setsize (new_mis, '0 0 0', '0 0 0');
  setorigin (new_mis, org);
  new_mis.velocity = 500 * dir;
  new_mis.angles = vectoangles (new_mis.velocity);
  new_mis.nextthink = time + 6;
  new_mis.think = SUB_Remove;
  new_mis.touch = ZEUS_MarkerRocketTouch;
};

/*
======================
ZEUS_ShowLinks

Fires a rocket in the direction of every link from current node
======================
*/
void () ZEUS_ShowLinks =
{
  local   entity  cur_node;

  cur_node = ZEUS_CurrentNode (self);

  if (cur_node.ZEUS_link1)
    ZEUS_SpawnMarkerRocket (cur_node.origin, cur_node.ZEUS_link1.origin);
  if (cur_node.ZEUS_link2)
    ZEUS_SpawnMarkerRocket (cur_node.origin, cur_node.ZEUS_link2.origin);
  if (cur_node.ZEUS_link3)
    ZEUS_SpawnMarkerRocket (cur_node.origin, cur_node.ZEUS_link3.origin);
  if (cur_node.ZEUS_link4)
    ZEUS_SpawnMarkerRocket (cur_node.origin, cur_node.ZEUS_link4.origin);
  if (cur_node.ZEUS_link5)
    ZEUS_SpawnMarkerRocket (cur_node.origin, cur_node.ZEUS_link5.origin);
  if (cur_node.ZEUS_link6)
    ZEUS_SpawnMarkerRocket (cur_node.origin, cur_node.ZEUS_link6.origin);
};

/*
======================
ZEUS_ChooseRandomNode
======================
*/

entity (entity cur_node) ZEUS_ChooseRandomNode =
{
  local   float   r;
  local   entity  roam_node;

  r = random () * 6;

  if (r < 1)
    roam_node = cur_node.ZEUS_link1;
  else if (r < 2)
    roam_node = cur_node.ZEUS_link2;
  else if (r < 3)
    roam_node = cur_node.ZEUS_link3;
  else if (r < 4)
    roam_node = cur_node.ZEUS_link4;
  else if (r < 5)
    roam_node = cur_node.ZEUS_link5;
  else if (r < 6)
    roam_node = cur_node.ZEUS_link6;

  if ((!ZEUS_NodeVisible (roam_node)) || (roam_node == self.ZEUS_last_map_node))
  {
    roam_node = world;

    if ((ZEUS_NodeVisible (cur_node.ZEUS_link1)) && (cur_node.ZEUS_link1 != self.ZEUS_last_map_node))
      roam_node = cur_node.ZEUS_link1;
    else if ((ZEUS_NodeVisible (cur_node.ZEUS_link2)) && (cur_node.ZEUS_link2 != self.ZEUS_last_map_node))
      roam_node = cur_node.ZEUS_link2;
    else if ((ZEUS_NodeVisible (cur_node.ZEUS_link3)) && (cur_node.ZEUS_link3 != self.ZEUS_last_map_node))
      roam_node = cur_node.ZEUS_link3;
    else if ((ZEUS_NodeVisible (cur_node.ZEUS_link4)) && (cur_node.ZEUS_link4 != self.ZEUS_last_map_node))
      roam_node = cur_node.ZEUS_link4;
    else if ((ZEUS_NodeVisible (cur_node.ZEUS_link5)) && (cur_node.ZEUS_link5 != self.ZEUS_last_map_node))
      roam_node = cur_node.ZEUS_link5;
    else if ((ZEUS_NodeVisible (cur_node.ZEUS_link6)) && (cur_node.ZEUS_link6 != self.ZEUS_last_map_node))
      roam_node = cur_node.ZEUS_link6;
  }

  return roam_node;
};
