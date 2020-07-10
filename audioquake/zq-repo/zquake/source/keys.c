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
#include "quakedef.h"
#include "keys.h"
#include "menu.h"

/*

key up events are sent even if in console mode

*/

cvar_t	cl_chatmode = {"cl_chatmode", "2"};

#define		MAXCMDLINE	256
char	key_lines[32][MAXCMDLINE];
int		key_linepos;
int		key_lastpress;

int		edit_line=0;
int		history_line=0;

keydest_t	key_dest;

char	*keybindings[256];
qbool	consolekeys[256];	// if true, can't be rebound while in console
qbool	menubound[256];		// if true, can't be rebound while in menu
int		keyshift[256];		// key to map to if shift held down in console
int		key_repeats[256];	// if > 1, it is autorepeating
qbool	keydown[256];
qbool	keyactive[256];

typedef struct
{
	char	*name;
	int		keynum;
} keyname_t;

keyname_t keynames[] =
{
	{"TAB", K_TAB},
	{"ENTER", K_ENTER},
	{"ESCAPE", K_ESCAPE},
	{"SPACE", K_SPACE},
	{"BACKSPACE", K_BACKSPACE},

	{"CAPSLOCK",K_CAPSLOCK},
	{"PRINTSCR", K_PRINTSCR},
	{"SCRLCK", K_SCROLLLOCK},
	{"SCROLLLOCK", K_SCROLLLOCK},
	{"PAUSE", K_PAUSE},

	{"UPARROW", K_UPARROW},
	{"DOWNARROW", K_DOWNARROW},
	{"LEFTARROW", K_LEFTARROW},
	{"RIGHTARROW", K_RIGHTARROW},

	{"ALT", K_ALT},
	{"LALT", K_LALT},
	{"RALT", K_RALT},
	{"ALTGR", K_ALTGR},
	{"CTRL", K_CTRL},
	{"LCTRL", K_LCTRL},
	{"RCTRL", K_RCTRL},
	{"SHIFT", K_SHIFT},
	{"LSHIFT", K_LSHIFT},
	{"RSHIFT", K_RSHIFT},

	// Keypad stuff..
	{"NUMLOCK", KP_NUMLOCK},
	{"KP_NUMLCK", KP_NUMLOCK},
	{"KP_NUMLOCK", KP_NUMLOCK},
	{"KP_SLASH", KP_SLASH},
	{"KP_DIVIDE", KP_SLASH},
	{"KP_STAR", KP_STAR},
	{"KP_MULTIPLY", KP_STAR},

	{"KP_MINUS", KP_MINUS},

	{"KP_HOME", KP_HOME},
	{"KP_7", KP_HOME},
	{"KP_UPARROW", KP_UPARROW},
	{"KP_8", KP_UPARROW},
	{"KP_PGUP", KP_PGUP},
	{"KP_9", KP_PGUP},
	{"KP_PLUS", KP_PLUS},

	{"KP_LEFTARROW", KP_LEFTARROW},
	{"KP_4", KP_LEFTARROW},
	{"KP_5", KP_5},
	{"KP_RIGHTARROW", KP_RIGHTARROW},
	{"KP_6", KP_RIGHTARROW},

	{"KP_END", KP_END},
	{"KP_1", KP_END},
	{"KP_DOWNARROW", KP_DOWNARROW},
	{"KP_2", KP_DOWNARROW},
	{"KP_PGDN", KP_PGDN},
	{"KP_3", KP_PGDN},

	{"KP_INS", KP_INS},
	{"KP_0", KP_INS},
	{"KP_DEL", KP_DEL},
	{"KP_ENTER", KP_ENTER},

	{"F1", K_F1},
	{"F2", K_F2},
	{"F3", K_F3},
	{"F4", K_F4},
	{"F5", K_F5},
	{"F6", K_F6},
	{"F7", K_F7},
	{"F8", K_F8},
	{"F9", K_F9},
	{"F10", K_F10},
	{"F11", K_F11},
	{"F12", K_F12},

	{"INS", K_INS},
	{"DEL", K_DEL},
	{"PGDN", K_PGDN},
	{"PGUP", K_PGUP},
	{"HOME", K_HOME},
	{"END", K_END},

	{"MOUSE1", K_MOUSE1},
	{"MOUSE2", K_MOUSE2},
	{"MOUSE3", K_MOUSE3},
	{"MOUSE4", K_MOUSE4},
	{"MOUSE5", K_MOUSE5},
	{"MOUSE6", K_MOUSE6},
	{"MOUSE7", K_MOUSE7},
	{"MOUSE8", K_MOUSE8},

	{"JOY1", K_JOY1},
	{"JOY2", K_JOY2},
	{"JOY3", K_JOY3},
	{"JOY4", K_JOY4},

	{"AUX1", K_AUX1},
	{"AUX2", K_AUX2},
	{"AUX3", K_AUX3},
	{"AUX4", K_AUX4},
	{"AUX5", K_AUX5},
	{"AUX6", K_AUX6},
	{"AUX7", K_AUX7},
	{"AUX8", K_AUX8},
	{"AUX9", K_AUX9},
	{"AUX10", K_AUX10},
	{"AUX11", K_AUX11},
	{"AUX12", K_AUX12},
	{"AUX13", K_AUX13},
	{"AUX14", K_AUX14},
	{"AUX15", K_AUX15},
	{"AUX16", K_AUX16},
	{"AUX17", K_AUX17},
	{"AUX18", K_AUX18},
	{"AUX19", K_AUX19},
	{"AUX20", K_AUX20},
	{"AUX21", K_AUX21},
	{"AUX22", K_AUX22},
	{"AUX23", K_AUX23},
	{"AUX24", K_AUX24},
	{"AUX25", K_AUX25},
	{"AUX26", K_AUX26},
	{"AUX27", K_AUX27},
	{"AUX28", K_AUX28},
	{"AUX29", K_AUX29},
	{"AUX30", K_AUX30},
	{"AUX31", K_AUX31},
	{"AUX32", K_AUX32},

	{"PAUSE", K_PAUSE},

	{"MWHEELUP", K_MWHEELUP},
	{"MWHEELDOWN", K_MWHEELDOWN},

	{"SEMICOLON", ';'},	// because a raw semicolon separates commands

	{NULL,0}
};

/*
==============================================================================

			LINE TYPING INTO THE CONSOLE

==============================================================================
*/

qbool CheckForCommand (void)
{
	char	command[128];
	char	*cmd, *s;
	int		i;

	s = key_lines[edit_line]+1;

	for (i=0 ; i<127 ; i++)
		if (s[i] == ' ' || s[i] == ';')
			break;
		else
			command[i] = s[i];
	command[i] = 0;

	if (Cmd_IsLegacyCommand(command))
		return true;

	cmd = Cmd_CompleteCommand (command);
	if (!cmd || Q_stricmp (cmd, command))
		cmd = Cvar_CompleteVariable (command);
	if (!cmd || Q_stricmp (cmd, command) )
		return false;		// just a chat message
	return true;
}

//===================================================================
//  Advanced command completion
//
#define COLUMNWIDTH 20
#define MINCOLUMNWIDTH 18	// the last column may be slightly smaller

static void PaddedPrint (char *s)
{
	extern int con_linewidth;
	int	nextcolx = 0;

	if (con_x)
		nextcolx = (int)((con_x + COLUMNWIDTH)/COLUMNWIDTH)*COLUMNWIDTH;

	if (nextcolx > con_linewidth - MINCOLUMNWIDTH
		|| (con_x && nextcolx + strlen(s) >= con_linewidth))
		Com_Printf ("\n");

	if (con_x)
		Com_Printf (" ");
	while (con_x % COLUMNWIDTH)
		Com_Printf (" ");
	Com_Printf ("%s", s);
}

static char	compl_common[64];
static int	compl_clen;
static int	compl_len;

static void FindCommonSubString (char *s)
{
	if (!compl_clen) {
		strlcpy (compl_common, s, sizeof(compl_common));
		compl_clen = strlen (compl_common);
	} else {
		while (compl_clen > compl_len && Q_strnicmp(s, compl_common, compl_clen))
			compl_clen--;
	}
}


extern int Cmd_CompleteCountPossible (char *partial);
extern int Cmd_AliasCompleteCountPossible (char *partial);
extern int Cvar_CompleteCountPossible (char *partial);

extern cmd_function_t *cmd_functions;

void CompleteCommand (void)
{
	char	*cmd, *s;
	int		c, a, v;

	s = key_lines[edit_line]+1;
	if (*s == '\\' || *s == '/')
		s++;

	compl_len = strlen (s);
	compl_clen = 0;

	c = Cmd_CompleteCountPossible (s);
	a = Cmd_AliasCompleteCountPossible (s);
	v = Cvar_CompleteCountPossible (s);

	if (c + a + v > 1) {
		cmd_function_t	*cmd;
		cmd_alias_t *alias;
		cvar_t	*var;

		Com_Printf ("\n");

		if (c) {
			Com_Printf ("\x02" "commands:\n");
			for (cmd=cmd_functions ; cmd ; cmd=cmd->next) {
				if (!Q_strnicmp (s, cmd->name, compl_len)) {
					PaddedPrint (cmd->name);
					FindCommonSubString (cmd->name);
				}
			}
			if (con_x)
				Com_Printf ("\n");
		}

		if (v) {
			Com_Printf ("\x02" "variables:\n");
			for (var = Cvar_Next(NULL); var; var=Cvar_Next(var)) {
				if (!Q_strnicmp (s, var->name, compl_len)) {
					PaddedPrint (var->name);
					FindCommonSubString (var->name);
				}
			}
			if (con_x)
				Com_Printf ("\n");
		}

		if (a) {
			Com_Printf ("\x02" "aliases:\n");
			for (alias=Alias_Next(NULL); alias; alias=Alias_Next(alias))
				if (!Q_strnicmp (s, alias->name, compl_len)) {
					PaddedPrint (alias->name);
					FindCommonSubString (alias->name);
				}
			if (con_x)
				Com_Printf ("\n");
		}

	}

	if (c + a + v == 1) {
		cmd = Cmd_CompleteCommand (s);
		if (!cmd)
			cmd = Cvar_CompleteVariable (s);
		if (!cmd)
			return;	// this should never happen
	} else if (compl_clen) {
		compl_common[compl_clen] = 0;
		cmd = compl_common;
	} else
		return;

	key_lines[edit_line][1] = '/';
	strcpy (key_lines[edit_line]+2, cmd);
	key_linepos = strlen(cmd)+2;
	if (c + a + v == 1)
		key_lines[edit_line][key_linepos++] = ' ';
	key_lines[edit_line][key_linepos] = 0;
}

//===================================================================

// CompleteName function

char readableChars[256] = {	'.', '_' , '_' , '_' , '_' , '.' , '_' , '_' , '_' , '_' , 10 , '_' , 12 , '>' , '.' , '.',
						'[', ']', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '_', '_', '_'};


void InitReadableChars(void) {
	int i;
	for (i = 32; i < 128; i++)
		readableChars[i] = readableChars[128 + i] = i;
	for (i = 0; i < 32; i++)
		readableChars[128 + i] = readableChars[i];
	readableChars[128] = '_';
	readableChars[10 + 128] = 10 + 128;
	readableChars[12 + 128] = 12 + 128;
}

char disallowed[] = {'\n', '\f', '\\', '/', '\"', ' ' , ';'};

void RemoveColors(char *name) {
	char *s = name;

	if (!s || !*s)
		return;

	while (*s) {
		*s = readableChars[(unsigned char) *s] & 127;
		if (strchr(disallowed, *s))
			*s = '_';
		s++;
	}
	// get rid of whitespace
	s = name;
	for (s = name; *s == '_'; s++) ;
	memmove(name, s, strlen(s) + 1);

	for (s = name + strlen(name); s > name  &&  (*(s - 1) == '_'); s--) ;

	*s = 0;

	if (!name[0])
		strcpy(name, "_");
}


int FindBestNick (char *s) {
	int i, j, bestplayer = -1, best = -1;
	char name[MAX_SCOREBOARDNAME], *match;

	for (i = 0; i < MAX_CLIENTS; i++) {
		if (cl.players[i].name[0]) {
			strlcpy (name, cl.players[i].name, sizeof(name));
			RemoveColors(name);
			for (j = 0; j < strlen(name); j++)
				name[j] = tolower(name[j]);
			if ((match = strstr(name, s))  &&  (best == -1 || match - name < best)) {
				best = match - name;
				bestplayer = i;
			}
		}
	}
	return bestplayer;
}



void CompleteName(void) {
	char s[MAXCMDLINE], t[MAXCMDLINE], *p, *q;
	int best, diff, i;

	p = q = key_lines[edit_line] + key_linepos;
	while (--p >= key_lines[edit_line] + 1)
		if (!(  (*(signed char *)p >= 32) && !strchr(disallowed, *p) ))
			break;
	p++;
	if (q - p <= 0)
		return;

	strlcpy (s, p, q - p + 1);

	best = FindBestNick (s);
	if (best >= 0) {
		strlcpy (t, cl.players[best].name, sizeof(t));

		for (i = 0; t[i]; i++) {
			if ((127 & t[i]) == ' ') {
				int k;

				if ((k = strlen(t)) < MAXCMDLINE - 2) {
					memmove(t + 1, t, k + 1);
					t[k + 2] = 0;
					t[k + 1] = t[0] = '\"';
				}
				break;
			}
		}
		diff = strlen(t) - strlen(s);

		memmove(q + diff, q, strlen(q) + 1);
		memmove(p, t, strlen(t));
		key_linepos += diff;
		if (!key_lines[edit_line][key_linepos] && key_linepos < MAXCMDLINE - 1) {
			key_lines[edit_line][key_linepos] = ' ';
			key_lines[edit_line][++key_linepos] = 0;
		}
	}
}

//===================================================================

static void AdjustConsoleHeight (int delta)
{
	extern cvar_t scr_consize;
	int		height;

	if (cls.state != ca_active && !cl.intermission)
		return;
	height = (scr_consize.value * vid.height + delta + 5) / 10;
	height *= 10;
	if (delta < 0 && height < 30)
		height = 30;
	if (delta > 0 && height > vid.height - 10)
		height = vid.height - 10;
	Cvar_SetValue (&scr_consize, (float)height / vid.height);
}

// Enter key was pressed in the console, do the appropriate action
static void HandleEnter (void)
{
	enum {COMMAND, CHAT, TEAMCHAT} type;
	char *p;

	// decide whether to treat the text as chat or command
	if (cls.state == ca_disconnected)
		type = COMMAND;
	else if (keydown[K_CTRL])
		type = TEAMCHAT;
	else if (keydown[K_SHIFT])
		type = CHAT;
	else if (key_lines[edit_line][1] == '\\' || key_lines[edit_line][1] == '/')
		type = COMMAND;
	else if (cl_chatmode.value == 1 || (cl_chatmode.value == 2 && !CheckForCommand()))
		type = CHAT;
	else
		type = COMMAND;

	// do appropriate action
	switch (type) {
	case CHAT:
	case TEAMCHAT:
		for (p = key_lines[edit_line] + 1; *p; p++) {
			if (*p != ' ')
				break;
		}
		if (!*p)
			break;		// just whitespace

		Cbuf_AddText(type == TEAMCHAT ? "say_team " : "say ");
		Cbuf_AddText(key_lines[edit_line] + 1);
		Cbuf_AddText("\n");
		break;

	case COMMAND:
		p = key_lines[edit_line] + 1;	// skip the "]" prompt char
		if (*p == '\\' || (*p == '/' && p[1] != '/'))
			p++;
		Cbuf_AddText(p);
		Cbuf_AddText("\n");
		break;
	}

	// echo to the console and cycle command history
	Com_Printf("%s\n", key_lines[edit_line]);
	edit_line = (edit_line + 1) & 31;
	history_line = edit_line;
	key_lines[edit_line][0] = ']';
	key_lines[edit_line][1] = 0;
	key_linepos = 1;

	if (cls.state == ca_disconnected)
		SCR_UpdateScreen();	// force an update, because the command
							// may take some time
}

#ifndef AGRIP
/*
====================
Key_Console

Interactive line editing and console scrollback
====================
*/
void Key_Console (int key)
{
	int i;

	switch (key)
	{
		case K_ENTER:
			HandleEnter ();
			return;

		case K_TAB:
			if (keydown[K_CTRL])
				CompleteName ();
			else
				CompleteCommand ();
			return;

		case K_BACKSPACE:
			if (key_linepos > 1)
			{
				strcpy(key_lines[edit_line] + key_linepos - 1, key_lines[edit_line] + key_linepos);
				key_linepos--;
			}
			return;

		case K_DEL:
			if (key_linepos < strlen(key_lines[edit_line]))
				strcpy(key_lines[edit_line] + key_linepos, key_lines[edit_line] + key_linepos + 1);
			return;

		case K_RIGHTARROW:
			if (keydown[K_CTRL]) {
				// word right
				i = strlen(key_lines[edit_line]);
				while (key_linepos < i && key_lines[edit_line][key_linepos] != ' ')
					key_linepos++;
				while (key_linepos < i && key_lines[edit_line][key_linepos] == ' ')
					key_linepos++;
				return;
			}
			if (key_linepos < strlen(key_lines[edit_line]))
				key_linepos++;
			return;

		case K_LEFTARROW:
			if (keydown[K_CTRL]) {
				// word left
				while (key_linepos > 1 && key_lines[edit_line][key_linepos-1] == ' ')
					key_linepos--;
				while (key_linepos > 1 && key_lines[edit_line][key_linepos-1] != ' ')
					key_linepos--;
				return;
			}
			if (key_linepos > 1)
				key_linepos--;
			return;

		case K_UPARROW:
			if (keydown[K_CTRL]) {
				AdjustConsoleHeight (-10);
				return;
			}
			do {
				history_line = (history_line - 1) & 31;
			} while (history_line != edit_line
					&& !key_lines[history_line][1]);
			if (history_line == edit_line)
				history_line = (edit_line+1)&31;
			strcpy(key_lines[edit_line], key_lines[history_line]);
			key_linepos = strlen(key_lines[edit_line]);
			return;

		case K_DOWNARROW:
			if (keydown[K_CTRL]) {
				AdjustConsoleHeight (10);
				return;
			}
			if (history_line == edit_line) return;
			do {
				history_line = (history_line + 1) & 31;
			} while (history_line != edit_line
				&& !key_lines[history_line][1]);

			if (history_line == edit_line) {
				key_lines[edit_line][0] = ']';
				key_lines[edit_line][1] = 0;
				key_linepos = 1;
			} else {
				strcpy(key_lines[edit_line], key_lines[history_line]);
				key_linepos = strlen(key_lines[edit_line]);
			}
			return;

		case K_PGUP:
		case K_MWHEELUP:
			if (keydown[K_CTRL] && key == K_PGUP)
				Con_Scroll (-(((int)scr_conlines - 22) >> 3));
			else
				Con_Scroll (-2);
			return;

		case K_MWHEELDOWN:
		case K_PGDN:
			if (keydown[K_CTRL] && key == K_PGDN)
				Con_Scroll (((int)scr_conlines - 22) >> 3);
			else
				Con_Scroll (2);
			return;

		case K_HOME:
			if (keydown[K_CTRL])
				Con_ScrollToTop ();
			else
				key_linepos = 1;
			return;

		case K_END:
			if (keydown[K_CTRL])
				Con_ScrollToBottom ();
			else
				key_linepos = strlen(key_lines[edit_line]);
			return;
	}

	if (((key == 'V' || key == 'v') && keydown[K_CTRL])
		|| ((key == K_INS || key == KP_INS) && keydown[K_SHIFT]))
	{
		int  len;
		char *p;
		char *text = Sys_GetClipboardText();
		if (text) {
			for (p = text; *p; p++) {
				if (*p == '\n' || *p == '\r' || *p == '\t')
					*p = ' ';
			}
			len = p - text;
			if (len + strlen(key_lines[edit_line]) > MAXCMDLINE-1)
				len = MAXCMDLINE-1 - strlen(key_lines[edit_line]);

			memmove (key_lines[edit_line] + key_linepos + len,
			         key_lines[edit_line] + key_linepos,
			         strlen(key_lines[edit_line] + key_linepos) + 1 /* move trailing zero */);
			memcpy (key_lines[edit_line] + key_linepos, text, len);
			key_linepos += len;

			Q_free (text);	// Q_malloc'ed by Sys_GetClipboardText
		}
		return;
	}

	if (key < 32 || key > 127)
		return;	// non-printable

	if (keydown[K_CTRL]) {
		if (key >= '0' && key <= '9')
				key = key - '0' + 0x12;	// yellow number
		else switch (key) {
			case '[': key = 0x10; break;
			case ']': key = 0x11; break;
			case 'g': key = 0x86; break;
			case 'r': key = 0x87; break;
			case 'y': key = 0x88; break;
			case 'b': key = 0x89; break;
			case '(': key = 0x80; break;
			case '=': key = 0x81; break;
			case ')': key = 0x82; break;
			case 'a': key = 0x83; break;
			case '<': key = 0x1d; break;
			case '-': key = 0x1e; break;
			case '>': key = 0x1f; break;
			case ',': key = 0x1c; break;
			case '.': key = 0x9c; break;
			case 'B': key = 0x8b; break;
			case 'C': key = 0x8d; break;
		}
	}

	if (keydown[K_ALT])
		key |= 128;		// brown char

	i = strlen(key_lines[edit_line]);
	if (i >= MAXCMDLINE-1)
		return;

	// This also moves the trailing zero
	memmove (key_lines[edit_line]+key_linepos+1, key_lines[edit_line]+key_linepos, i-key_linepos+1);
	key_lines[edit_line][key_linepos] = key;
	key_linepos++;
}
#else // AGRIP
/*
====================
Key_Console -- Accessible Version

Interactive line editing and console scrollback

This has been written as a separate function because putting the accessibility
hooks into the main one, though possible, would result in a lot of #ifdefs and
would therefore be harder to read.
====================
*/
void Key_Console (int key)
{
    int i;

    switch (key)
    {
        case K_ENTER:
            HandleEnter ();
            return;

        case K_TAB:
            if (keydown[K_CTRL])
                CompleteName ();
            else
                CompleteCommand ();
            return;

        case K_BACKSPACE:
            if (key_linepos > 1)
            {
                // Show chopped char...
                Sys_Printf("%c\n", key_lines[edit_line][key_linepos-1]);
                strcpy(key_lines[edit_line] + key_linepos - 1, key_lines[edit_line] + key_linepos);
                key_linepos--;
            }
            else
            {
                // No chars to delete...
                Sys_Printf("!Start of line.\n");
            }
            return;

        case K_DEL:
            if (key_linepos < strlen(key_lines[edit_line]))
            {
                // Show deleted char...
                Sys_Printf("%c\n", key_lines[edit_line][key_linepos]);
                strcpy(key_lines[edit_line] + key_linepos, key_lines[edit_line] + key_linepos + 1);
            }
            else
            {
                // At the end of the line...
                Sys_Printf("!End of line.\n");
            }
            return;

        case K_RIGHTARROW:
            if (keydown[K_CTRL])
            {
                // word right
                i = strlen(key_lines[edit_line]);
                while (key_linepos < i && key_lines[edit_line][key_linepos] != ' ')
                    key_linepos++;
                while (key_linepos < i && key_lines[edit_line][key_linepos] == ' ')
                    key_linepos++;
                return;
            }
            if (key_linepos < strlen(key_lines[edit_line]))
            {
                key_linepos++;
                // Show the char moved to...
                Sys_Printf("%c\n", key_lines[edit_line][key_linepos]);
            }
            else
                Sys_Printf("!End of line.\n");
            return;

        case K_LEFTARROW:
            if (keydown[K_CTRL])
            {
                // word left
                while (key_linepos > 1 && key_lines[edit_line][key_linepos-1] == ' ')
                    key_linepos--;
                while (key_linepos > 1 && key_lines[edit_line][key_linepos-1] != ' ')
                    key_linepos--;
                return;
            }
            if (key_linepos > 1)
            {
                key_linepos--;
                // Show the char moved to...
                Sys_Printf("%c\n", key_lines[edit_line][key_linepos]);
            }
            else
                Sys_Printf("!Start of line.\n");
            return;

        case K_UPARROW:
            if (keydown[K_CTRL])
            {
                AdjustConsoleHeight (-10);
                return;
            }
            if (history_line == ((edit_line+1)&31))
                return;
            do
            {
                history_line = (history_line - 1) & 31;
            } while (history_line != edit_line
                    && !key_lines[history_line][1]);

            if (history_line == edit_line)
            {
                history_line = (edit_line+1)&31;
                Sys_Printf("!No more lines in history.\n");
                strcpy(key_lines[edit_line], key_lines[history_line]);
                key_linepos = strlen(key_lines[edit_line]);
            }
            else
            {
                strcpy(key_lines[edit_line], key_lines[history_line]);
                key_linepos = strlen(key_lines[edit_line]);
                // Show moved-to line...
                Sys_Printf("%s\n", key_lines[edit_line]);
            }
            return;

        case K_DOWNARROW:
            if (keydown[K_CTRL])
            {
                AdjustConsoleHeight (10);
                return;
            }
            if (history_line == edit_line) return;
            do
            {
                history_line = (history_line + 1) & 31;
            } while (history_line != edit_line
                    && !key_lines[history_line][1]);

            if (history_line == edit_line)
            {
                Sys_Printf("!Edit line reached.\n");
                strcpy(key_lines[edit_line], key_lines[(edit_line+1)&31]);
                key_linepos = strlen(key_lines[edit_line]);
            }
            else
            {
                strcpy(key_lines[edit_line], key_lines[history_line]);
                key_linepos = strlen(key_lines[edit_line]);
                // Show moved-to line...
                Sys_Printf("%s\n", key_lines[edit_line]);
            }
            return;

        case K_PGUP:
        case K_MWHEELUP:
            if (keydown[K_CTRL] && key == K_PGUP)
                Con_Scroll (-(((int)scr_conlines - 22) >> 3));
            else
                Con_Scroll (-2);
            return;

        case K_MWHEELDOWN:
        case K_PGDN:
            if (keydown[K_CTRL] && key == K_PGDN)
                Con_Scroll (((int)scr_conlines - 22) >> 3);
            else
                Con_Scroll (2);
            return;

        case K_HOME:
            if (keydown[K_CTRL])
                Con_ScrollToTop ();
            else
                key_linepos = 1;
            Sys_Printf("%c\n", key_lines[edit_line][1]);
            return;

        case K_END:
            if (keydown[K_CTRL])
                Con_ScrollToTop ();
            else
                key_linepos = strlen(key_lines[edit_line]);
            return;
    }

    if (((key == 'V' || key == 'v') && keydown[K_CTRL])
            || ((key == K_INS || key == KP_INS) && keydown[K_SHIFT]))
    {
        int  len;
        char *p;
        char *text = Sys_GetClipboardText();
        if (text)
        {
            for (p = text; *p; p++)
            {
                if (*p == '\n' || *p == '\r' || *p == '\t')
                    *p = ' ';
            }
            len = p - text;
            if (len + strlen(key_lines[edit_line]) > MAXCMDLINE-1)
                len = MAXCMDLINE-1 - strlen(key_lines[edit_line]);

            memmove (key_lines[edit_line] + key_linepos + len,
                    key_lines[edit_line] + key_linepos, strlen(key_lines[edit_line] + key_linepos) + 1 /* move trailing zero */);
            memcpy (key_lines[edit_line] + key_linepos, text, len);
            key_linepos += len;

            Q_free (text);	// Q_malloc'ed by Sys_GetClipboardText
        }
        return;
    }

    if (key < 32 || key > 127)
        return;	// non-printable

    i = strlen(key_lines[edit_line]);
    if (i >= MAXCMDLINE-1)
        return;

    // Print single chars entered...
    Sys_Printf("%c\n", key);

    // This also moves the trailing zero
    memmove (key_lines[edit_line]+key_linepos+1, key_lines[edit_line]+key_linepos, i-key_linepos+1);
    key_lines[edit_line][key_linepos] = key;
    key_linepos++;
}
#endif // AGRIP

//============================================================================

qbool	chat_team;
char	chat_buffer[MAXCMDLINE];
int		chat_linepos = 0;

void Key_Message (int key)
{
	int len;

	switch (key)
	{
	case K_ENTER:
		if (chat_team)
			Cbuf_AddText ("say_team \"");
		else
			Cbuf_AddText ("say \"");
		Cbuf_AddText(chat_buffer);
		Cbuf_AddText("\"\n");

		key_dest = key_game;
		chat_linepos = 0;
		chat_buffer[0] = 0;
		return;

	case K_ESCAPE:
		key_dest = key_game;
		chat_buffer[0] = 0;
		chat_linepos = 0;
		return;

	case K_HOME:
		chat_linepos = 0;
		return;

	case K_END:
		chat_linepos = strlen(chat_buffer);
		return;

	case K_LEFTARROW:
		if (chat_linepos > 0)
			chat_linepos--;
		return;

	case K_RIGHTARROW:
		if (chat_linepos < strlen(chat_buffer))
			chat_linepos++;
		return;

	case K_BACKSPACE:
		if (chat_linepos > 0) {
			strcpy(chat_buffer + chat_linepos - 1, chat_buffer + chat_linepos);
			chat_linepos--;
		}
		return;

	case K_DEL:
		if (chat_buffer[chat_linepos])
			strcpy(chat_buffer + chat_linepos, chat_buffer + chat_linepos + 1);
		return;
	}

	if (((key == 'V' || key == 'v') && keydown[K_CTRL])
		|| ((key == K_INS || key == KP_INS) && keydown[K_SHIFT]))
	{
		int	len;
		char *p;
		char *text = Sys_GetClipboardText();
		if (text) {
			for (p = text; *p; p++) {
				if (*p == '\n' || *p == '\r' || *p == '\t')
					*p = ' ';
			}
			len = p - text;
			if (len + strlen(chat_buffer) > sizeof(chat_buffer)-1)
				len = sizeof(chat_buffer)-1 - strlen(chat_buffer);

			memmove (chat_buffer + chat_linepos + len,
				chat_buffer + chat_linepos, strlen(chat_buffer + chat_linepos) + 1 /* move trailing zero */);
			memcpy (chat_buffer + chat_linepos, text, len);
			chat_linepos += len;

			Q_free (text);	// Q_malloc'ed by Sys_GetClipboardText
		}
		return;
	}

	if (key < 32 || key > 127)
		return;	// non-printable

	len = strlen(chat_buffer);

	if (len >= sizeof(chat_buffer)-1)
		return; // all full

	// This also moves the ending \0
	memmove (chat_buffer+chat_linepos+1, chat_buffer+chat_linepos,
		len-chat_linepos+1);
	chat_buffer[chat_linepos++] = key;
}

//============================================================================


/*
===================
Key_StringToKeynum

Returns a key number to be used to index keybindings[] by looking at
the given string.  Single ascii characters return themselves, while
the K_* names are matched up.
===================
*/
int Key_StringToKeynum (char *str)
{
	keyname_t	*kn;
	int			keynum;

	if (!str || !str[0])
		return -1;
	if (!str[1])
		return (int)(unsigned char)str[0];

	if (str[0] == '#') {
		keynum = Q_atoi(str + 1);
		if (keynum < 32 || keynum > 127)
			return -1;
		return keynum;
	}

	for (kn=keynames ; kn->name ; kn++) {
		if (!Q_stricmp(str,kn->name))
			return kn->keynum;
	}

	return -1;
}

/*
=================================================
Key_KeynumToString

Returns a string for the given keynum.
  (either a single ascii char, or a K_* name)
it uses either the given buffer or a internal one
  (parameter buffer == NULL)
=================================================
*/
char *Key_KeynumToString (int keynum, char *buffer, size_t buf_size)
{
	static char *retval        = NULL;
	keyname_t	*kn            = NULL;
	static	char	tinystr[5] = "\0";

	if (keynum < 0)
		retval = "<KEY NOT FOUND>";
	else
	if (keynum == 0)
		retval = "<NO KEY>";
	if (keynum > 32 && keynum < 127)
	{	// printable ascii
		if (keynum == 34) // treat " special
			sprintf (tinystr, "#%u", keynum);
		else
		{
			tinystr[0] = keynum;
			tinystr[1] = '\0';
		}
		retval = tinystr;
	}
	else
	{
		for (kn = keynames; kn->name; kn++)
		{
			if (keynum == kn->keynum)
			{
				retval = kn->name;
				break;
			}
		}
	}

	if (retval == NULL)
		retval = "<UNKNOWN KEYNUM>";

	// use the buffer if given
	if (buffer != NULL && buf_size > (size_t)0)
	{
		strlcpy (buffer, retval, buf_size);
		return (buffer);
	}

	return retval;
}


/*
===================
Key_SetBinding
===================
*/
void Key_SetBinding (int keynum, char *binding)
{
	if (keynum == -1)
		return;

	// free (and hence Q_free) is safe to call with a NULL argument
	Q_free (keybindings[keynum]);
	keybindings[keynum] = Q_strdup(binding);
}

/*
===================
Key_Unbind
===================
*/
void Key_Unbind (int keynum)
{
	if (keynum == -1)
		return;

	// free (and hence Q_free) is safe to call with a NULL argument
	Q_free (keybindings[keynum]);
	keybindings[keynum] = NULL;
}

/*
===================
Key_Unbind_f
===================
*/
void Key_Unbind_f (void)
{
	int		b;

	if (Cmd_Argc() != 2)
	{
		Com_Printf ("unbind <key> : remove commands from a key\n");
		return;
	}

	b = Key_StringToKeynum (Cmd_Argv(1));
	if (b==-1)
	{
		Com_Printf ("\"%s\" isn't a valid key\n", Cmd_Argv(1));
		return;
	}

	Key_Unbind (b);
}

void Key_Unbindall_f (void)
{
	int		i;

	for (i=0 ; i<256 ; i++)
		if (keybindings[i])
			Key_Unbind (i);
}


/*
===================
Key_Bind_f
===================
*/
void Key_Bind_f (void)
{
	int			c, b;

	c = Cmd_Argc();

	if (c < 2)
	{
		Com_Printf ("bind <key> [command] : attach a command to a key\n");
		return;
	}
	b = Key_StringToKeynum (Cmd_Argv(1));
	if (b==-1)
	{
		Com_Printf ("\"%s\" isn't a valid key\n", Cmd_Argv(1));
		return;
	}

	if (c == 2)
	{
		if (keybindings[b])
			Com_Printf ("\"%s\" = \"%s\"\n", Cmd_Argv(1), keybindings[b] );
		else
			Com_Printf ("\"%s\" is not bound\n", Cmd_Argv(1) );
		return;
	}

// copy the rest of the command line
	Key_SetBinding (b, Cmd_MakeArgs(2));
}


/*
===================
Key_BindList_f
===================
*/
void Key_BindList_f (void)
{
	int		i;

	for (i=0 ; i<256 ; i++)
		if (keybindings[i])
			Com_Printf ("%s \"%s\"\n", Key_KeynumToString(i, NULL, 0), keybindings[i]);
}


/*
============
Key_WriteBindings

Writes lines containing "bind key value"
============
*/
void Key_WriteBindings (FILE *f)
{
	int		i;

	for (i=0 ; i<256 ; i++)
		if (keybindings[i])
		{
			if (i == ';')
				fprintf (f, "bind \";\" \"%s\"\n", keybindings[i]);
			else
				fprintf (f, "bind %s \"%s\"\n", Key_KeynumToString(i, NULL, 0), keybindings[i]);
		}
}


/*
===================
Key_Init
===================
*/
void Key_Init (void)
{
	int		i;

	if (dedicated)
		return;

	for (i=0 ; i<32 ; i++)
	{
		key_lines[i][0] = ']';
		key_lines[i][1] = 0;
	}
	key_linepos = 1;

//
// init ascii characters in console mode
//
	for (i=32 ; i<128 ; i++)
		consolekeys[i] = true;
	consolekeys[K_ENTER] = true;
	consolekeys[K_TAB] = true;
	consolekeys[K_LEFTARROW] = true;
	consolekeys[K_RIGHTARROW] = true;
	consolekeys[K_UPARROW] = true;
	consolekeys[K_DOWNARROW] = true;
	consolekeys[K_BACKSPACE] = true;
	consolekeys[K_INS] = true;
	consolekeys[K_DEL] = true;
	consolekeys[K_HOME] = true;
	consolekeys[K_END] = true;
	consolekeys[K_PGUP] = true;
	consolekeys[K_PGDN] = true;
	consolekeys[K_ALT] = true;
	consolekeys[K_CTRL] = true;
	consolekeys[K_SHIFT] = true;
	consolekeys[K_MWHEELUP] = true;
	consolekeys[K_MWHEELDOWN] = true;
	consolekeys['`'] = false;
	consolekeys['~'] = false;

	for (i=0 ; i<256 ; i++)
		keyshift[i] = i;
	for (i='a' ; i<='z' ; i++)
		keyshift[i] = i - 'a' + 'A';
	keyshift['1'] = '!';
	keyshift['2'] = '@';
	keyshift['3'] = '#';
	keyshift['4'] = '$';
	keyshift['5'] = '%';
	keyshift['6'] = '^';
	keyshift['7'] = '&';
	keyshift['8'] = '*';
	keyshift['9'] = '(';
	keyshift['0'] = ')';
	keyshift['-'] = '_';
	keyshift['='] = '+';
	keyshift[','] = '<';
	keyshift['.'] = '>';
	keyshift['/'] = '?';
	keyshift[';'] = ':';
	keyshift['\''] = '"';
	keyshift['['] = '{';
	keyshift[']'] = '}';
	keyshift['`'] = '~';
	keyshift['\\'] = '|';

	menubound[K_ESCAPE] = true;
	for (i=0 ; i<12 ; i++)
		menubound[K_F1+i] = true;

	InitReadableChars ();

//
// register our functions
//
	Cmd_AddCommand ("bindlist",Key_BindList_f);
	Cmd_AddCommand ("bind",Key_Bind_f);
	Cmd_AddCommand ("unbind",Key_Unbind_f);
	Cmd_AddCommand ("unbindall",Key_Unbindall_f);

	Cvar_Register (&cl_chatmode);
}

/*
===================
Key_Event

Called by the system between frames for both key up and key down events
Should NOT be called during an interrupt!
===================
*/
void Key_EventEx (int key, int shiftkey, qbool down)
{
	char	*kb;
	char	cmd[1024];

//	Com_Printf ("%i : %i\n", key, down); //@@@

	if (key == K_LALT || key == K_RALT)
		Key_EventEx (K_ALT, K_ALT, down);
	else if (key == K_LCTRL || key == K_RCTRL)
		Key_EventEx (K_CTRL, K_CTRL, down);
	else if (key == K_LSHIFT || key == K_RSHIFT)
		Key_EventEx (K_SHIFT, K_SHIFT, down);

	keydown[key] = down;

	if (!down)
		key_repeats[key] = 0;

	key_lastpress = key;

// update auto-repeat status
	if (down)
	{
		key_repeats[key]++;
		if (key_repeats[key] > 1)
		{
			if ((key != K_BACKSPACE && key != K_DEL
				&& key != K_LEFTARROW && key != K_RIGHTARROW
				&& key != K_UPARROW && key != K_DOWNARROW
				&& key != K_PGUP && key != K_PGDN && (key < 32 || key > 126 || key == '`'))
				|| (key_dest == key_game && cls.state == ca_active))
				return;	// ignore most autorepeats
		}
	}

//
// handle escape specially, so the user can never unbind it
//
	if (key == K_ESCAPE)
	{
		if (!down)
			return;
		switch (key_dest)
		{
		case key_message:
			Key_Message (key);
			break;
		case key_menu:
			M_Keydown (key);
			break;
		case key_game:
			M_ToggleMenu_f ();
			break;
		case key_console:
			if (cls.state == ca_active || cl.intermission)
				Con_ToggleConsole_f ();
			else
				M_ToggleMenu_f ();
			break;
		default:
			assert(!"Bad key_dest");
		}
		return;
	}

//
// key up events only generate commands if the game key binding is
// a button command (leading + sign).  These will occur even in console mode,
// to keep the character from continuing an action started before a console
// switch.  Button commands include the keynum as a parameter,
// so multiple downs can be matched with ups
//
	if (!down)
	{
		kb = keybindings[key];
		if (kb && kb[0] == '+' && keyactive[key])
		{
			sprintf (cmd, "-%s %i\n", kb+1, key);
			Cbuf_AddText (cmd);
			keyactive[key] = false;
		}
		if (shiftkey != key)
		{
			kb = keybindings[shiftkey];
			if (kb && kb[0] == '+' && keyactive[keyshift[key]])
			{
				sprintf (cmd, "-%s %i\n", kb+1, key);
				Cbuf_AddText (cmd);
				keyactive[keyshift[key]] = false;
			}
		}
		return;
	}

//
// during demo playback, most keys bring up the main menu
//
#if 0
	if (cls.demoplayback && down && consolekeys[key] && key_dest == key_game
		&& key != K_ALT && key != K_CTRL && key != K_SHIFT
		&& key != K_INS && key != K_DEL && key != K_HOME
		&& key != K_END && key != K_TAB)
	{
		M_ToggleMenu_f ();
		return;
	}
#endif

//
// if not a consolekey, send to the interpreter no matter what mode is
//
	if ( (key_dest == key_menu && menubound[key])
	|| ((key_dest == key_console || key_dest == key_message) && !consolekeys[key])
	|| (key_dest == key_game && ( cls.state == ca_active || !consolekeys[key] ) ) )
	{
		kb = keybindings[key];
		if (kb)
		{
			if (kb[0] == '+')
			{	// button commands add keynum as a parm
				sprintf (cmd, "%s %i\n", kb, key);
				Cbuf_AddText (cmd);
				keyactive[key] = true;
			}
			else
			{
				Cbuf_AddText (kb);
				Cbuf_AddText ("\n");
			}
		}
		return;
	}

	if (!down)
		return;		// other systems only care about key down events

	key = shiftkey;

	switch (key_dest)
	{
	case key_message:
		Key_Message (key);
		break;
	case key_menu:
		M_Keydown (key);
		break;

	case key_game:
	case key_console:
		Key_Console (key);
		break;
	default:
		assert(!"Bad key_dest");
	}
}

void Key_Event (int key, qbool down)
{
	if (keydown[K_SHIFT])
		Key_EventEx (key, keyshift[key], down);
	else
		Key_EventEx (key, key, down);
}

/*
===================
Key_ClearStates
===================
*/
void Key_ClearStates (void)
{
	int		i;

	for (i = 0; i < 256; i++)
	{
		keydown[i] = false;
		key_repeats[i] = false;
		keyactive[i] = false;
	}
}

