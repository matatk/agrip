/*  Copyright (C) 1996-1997  Id Software, Inc.

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

#include "qcc.h"
#include <stdio.h>
#include <string.h>

#ifdef _WIN32
#include <io.h>
#include <direct.h>
#else
#include <unistd.h>
#endif

static char	destfile[1024];

float		pr_globals[MAX_REGS];
int			numpr_globals;

char		strings[MAX_STRINGS];
int			strofs;

dstatement_t	statements[MAX_STATEMENTS];
int			numstatements;
int			statement_linenums[MAX_STATEMENTS];

dfunction_t	functions[MAX_FUNCTIONS];
int			numfunctions;

ddef_t		globals[MAX_GLOBALS];
int			numglobaldefs;

ddef_t		fields[MAX_FIELDS];
int			numfielddefs;


// CopyString returns an offset from the string heap
int		 CopyString (char *str)
{
	int		 old;

	old = strofs;
	strcpy (strings+strofs, str);
	strofs += strlen(str)+1;
	return old;
}

void	 PrintStrings (void)
{
	int		i, l, j;

	for (i=0 ; i<strofs ; i += l)
	{
		l = strlen(strings+i) + 1;
		printf ("%5i : ",i);
		for (j=0 ; j<l ; j++)
		{
			if (strings[i+j] == '\n')
			{
				putchar ('\\');
				putchar ('n');
			}
			else
				putchar (strings[i+j]);
		}
		printf ("\n");
	}
}


void	 PrintFunctions (void)
{
	int		i,j;
	dfunction_t	*d;

	for (i=0 ; i<numfunctions ; i++)
	{
		d = &functions[i];
		printf ("%s : %s : %i %i (", strings + d->s_file, strings + d->s_name, d->first_statement, d->parm_start);
		for (j=0 ; j<d->numparms ; j++)
			printf ("%i ",d->parm_size[j]);
		printf (")\n");
	}
}

void	 PrintFields (void)
{
	int		i;
	ddef_t	*d;

	for (i=0 ; i<numfielddefs ; i++)
	{
		d = &fields[i];
		printf ("%5i : (%i) %s\n", d->ofs, d->type, strings + d->s_name);
	}
}

void	 PrintGlobals (void)
{
	int		i;
	ddef_t	*d;

	for (i=0 ; i<numglobaldefs ; i++)
	{
		d = &globals[i];
		printf ("%5i : (%i) %s\n", d->ofs, d->type, strings + d->s_name);
	}
}


void	 InitData (void)
{
	int		i;

	numstatements = 1;
	strofs = 1;
	numfunctions = 1;
	numglobaldefs = 1;
	numfielddefs = 1;

	def_ret.ofs = OFS_RETURN;
	for (i = 0; i < MAX_PARMS; i++)
		def_parms[i].ofs = OFS_PARM0 + 3 * i;

	// Initialize the preprocessor define-structures:
	PR_InitDefines();
}


void	 WriteData (int crc)
{
	def_t		*def;
	ddef_t		*dd;
	dprograms_t	progs;
	FILE		*f;
	int			i;

	for (def = pr.def_head.next; def; def = def->next)
	{
		if (def->type->type == ev_function)
		{
//			df = &functions[numfunctions];
//			numfunctions++;

		}
		else if (def->type->type == ev_field)
		{
			dd = &fields[numfielddefs];
			numfielddefs++;
			dd->type = def->type->aux_type->type;
			dd->s_name = CopyString (def->name);
			dd->ofs = G_INT(def->ofs);
		}
		dd = &globals[numglobaldefs];
		numglobaldefs++;
		dd->type = def->type->type;
		if ( !def->initialized &&
			 def->type->type != ev_function &&
			 def->type->type != ev_field &&
			 def->scope == NULL)
			dd->type |= DEF_SAVEGLOBGAL;
		dd->s_name = CopyString (def->name);
		dd->ofs = def->ofs;
	}

	//PrintStrings ();
	//PrintFunctions ();
	//PrintFields ();
	//PrintGlobals ();
	strofs = (strofs+3)&~3;

	printf ("%6i strofs\n", strofs);
	printf ("%6i numstatements\n", numstatements);
	printf ("%6i numfunctions\n", numfunctions);
	printf ("%6i numglobaldefs\n", numglobaldefs);
	printf ("%6i numfielddefs\n", numfielddefs);
	printf ("%6i numpr_globals\n", numpr_globals);

	f = SafeOpenWrite (destfile);
	SafeWrite (f, &progs, sizeof(progs));

	progs.ofs_strings = ftell(f);
	progs.numstrings = strofs;
	SafeWrite (f, strings, strofs);

	progs.ofs_statements = ftell(f);
	progs.numstatements = numstatements;
	for (i = 0; i < numstatements; i++)
	{
		statements[i].op = (unsigned short)(LittleShort((short)statements[i].op));
		statements[i].a = (unsigned short)(LittleShort((short)statements[i].a));
		statements[i].b = (unsigned short)(LittleShort((short)statements[i].b));
		statements[i].c = (unsigned short)(LittleShort((short)statements[i].c));
	}
	SafeWrite (f, statements, numstatements*sizeof(dstatement_t));

	progs.ofs_functions = ftell(f);
	progs.numfunctions = numfunctions;
	for (i = 0; i < numfunctions; i++)
	{
		functions[i].first_statement = LittleLong (functions[i].first_statement);
		functions[i].parm_start = LittleLong (functions[i].parm_start);
		functions[i].s_name = LittleLong (functions[i].s_name);
		functions[i].s_file = LittleLong (functions[i].s_file);
		functions[i].numparms = LittleLong (functions[i].numparms);
		functions[i].locals = LittleLong (functions[i].locals);
	}
	SafeWrite (f, functions, numfunctions*sizeof(dfunction_t));

	progs.ofs_globaldefs = ftell(f);
	progs.numglobaldefs = numglobaldefs;
	for (i = 0; i < numglobaldefs; i++)
	{
		globals[i].type = LittleShort (globals[i].type);
		globals[i].ofs = LittleShort (globals[i].ofs);
		globals[i].s_name = LittleLong (globals[i].s_name);
	}
	SafeWrite (f, globals, numglobaldefs*sizeof(ddef_t));

	progs.ofs_fielddefs = ftell(f);
	progs.numfielddefs = numfielddefs;
	for (i = 0; i < numfielddefs; i++)
	{
		fields[i].type = LittleShort (fields[i].type);
		fields[i].ofs = LittleShort (fields[i].ofs);
		fields[i].s_name = LittleLong (fields[i].s_name);
	}
	SafeWrite (f, fields, numfielddefs*sizeof(ddef_t));

	progs.ofs_globals = ftell(f);
	progs.numglobals = numpr_globals;
	for (i = 0; i < numpr_globals; i++)
		((int *)pr_globals)[i] = LittleLong (((int *)pr_globals)[i]);
	SafeWrite (f, pr_globals, numpr_globals*4);

	printf ("%6ld TOTAL SIZE\n", ftell(f));

	progs.entityfields = pr.size_fields;

	progs.version = PROG_VERSION;
	progs.crc = crc;

	// byte swap the header and write it out
	for (i = 0; i < (int)sizeof(progs)/4; i++)
		((int *)&progs)[i] = LittleLong ( ((int *)&progs)[i] );
	fseek (f, 0, SEEK_SET);
	SafeWrite (f, &progs, sizeof(progs));
	fclose (f);
}


/*
===============
PR_String

Returns a string suitable for printing (no newlines, max 60 chars length)
===============
*/
char	*PR_String (char *string)
{
	static char buf[80];
	char	*s;

	s = buf;
	*s++ = '"';
	while (string && *string)
	{
		if (s == buf + sizeof(buf) - 2)
			break;
		if (*string == '\n')
		{
			*s++ = '\\';
			*s++ = 'n';
		}
		else if (*string == '"')
		{
			*s++ = '\\';
			*s++ = '"';
		}
		else
			*s++ = *string;
		string++;
		if (s - buf > 60)
		{
			*s++ = '.';
			*s++ = '.';
			*s++ = '.';
			break;
		}
	}
	*s++ = '"';
	*s++ = 0;
	return buf;
}


def_t	*PR_DefForFieldOfs (gofs_t ofs)
{
	def_t	*d;

	for (d=pr.def_head.next ; d ; d=d->next)
	{
		if (d->type->type != ev_field)
			continue;
		if (*((int *)&pr_globals[d->ofs]) == ofs)
			return d;
	}
	Error ("PR_DefForFieldOfs: couldn't find %i",ofs);
	return NULL;
}


/*
============
PR_ValueString

Returns a string describing *data in a type specific manner
=============
*/
char	*PR_ValueString (etype_t type, void *val)
{
	static char	line[256];
	def_t		*def;
	dfunction_t	*f;

	switch (type)
	{
	case ev_string:
		sprintf (line, "%s", PR_String(strings + *(int *)val));
		break;
	case ev_entity:
		sprintf (line, "entity %i", *(int *)val);
		break;
	case ev_function:
		f = functions + *(int *)val;
		if (!f)
			sprintf (line, "undefined function");
		else
			sprintf (line, "%s()", strings + f->s_name);
		break;
	case ev_field:
		def = PR_DefForFieldOfs ( *(int *)val );
		sprintf (line, ".%s", def->name);
		break;
	case ev_void:
		sprintf (line, "void");
		break;
	case ev_float:
		sprintf (line, "%5.1f", *(float *)val);
		break;
	case ev_vector:
		sprintf (line, "'%5.1f %5.1f %5.1f'", ((float *)val)[0], ((float *)val)[1], ((float *)val)[2]);
		break;
	case ev_pointer:
		sprintf (line, "pointer");
		break;
	default:
		sprintf (line, "bad type %i", type);
		break;
	}

	return line;
}


/*
============
PR_GlobalString

Returns a string with a description and the contents of a global,
padded to 20 field width
============
*/
char	*PR_GlobalStringNoContents (gofs_t ofs)
{
	int		i;
	def_t	*def;
	void	*val;
	static char	line[128];

	val = (void *)&pr_globals[ofs];
	def = pr_global_defs[ofs];
	if (!def)
//		Error ("PR_GlobalString: no def for %i", ofs);
		sprintf (line,"%i(?""?""?)", ofs);	// separate '?''s to stop gcc complaining about trigraphs
	else
		sprintf (line,"%i(%s)", ofs, def->name);

	i = strlen(line);
	for ( ; i<16 ; i++)
		strcat (line," ");
	strcat (line," ");

	return line;
}


char	*PR_GlobalString (gofs_t ofs)
{
	char	*s;
	int		i;
	def_t	*def;
	void	*val;
	static char	line[128];

	val = (void *)&pr_globals[ofs];
	def = pr_global_defs[ofs];
	if (!def)
		return PR_GlobalStringNoContents(ofs);
	if (def->initialized && def->type->type != ev_function)
	{
		s = PR_ValueString (def->type->type, &pr_globals[ofs]);
		sprintf (line,"%i(%s)", ofs, s);
	}
	else
		sprintf (line,"%i(%s)", ofs, def->name);

	i = strlen(line);
	for ( ; i<16 ; i++)
		strcat (line," ");
	strcat (line," ");

	return line;
}


/*
============
PR_PrintOfs
============
*/
void	 PR_PrintOfs (gofs_t ofs)
{
	printf ("%s\n",PR_GlobalString(ofs));
}


/*
=================
PR_PrintStatement
=================
*/
void	 PR_PrintStatement (dstatement_t *s)
{
	int		i;

	printf ("%4i : %4i : %s ", (int)(s - statements), statement_linenums[s-statements], pr_opcodes[s->op].opname);
	i = strlen(pr_opcodes[s->op].opname);
	for ( ; i<10 ; i++)
		printf (" ");

	if (s->op == OP_IF || s->op == OP_IFNOT)
		printf ("%sbranch %i",PR_GlobalString(s->a),s->b);
	else if (s->op == OP_GOTO)
	{
		printf ("branch %i",s->a);
	}
	else if ( (unsigned)(s->op - OP_STORE_F) < 6)
	{
		printf ("%s",PR_GlobalString(s->a));
		printf ("%s", PR_GlobalStringNoContents(s->b));
	}
	else
	{
		if (s->a)
			printf ("%s",PR_GlobalString(s->a));
		if (s->b)
			printf ("%s",PR_GlobalString(s->b));
		if (s->c)
			printf ("%s", PR_GlobalStringNoContents(s->c));
	}
	printf ("\n");
}


/*
============
PR_PrintDefs
============
*/
void	 PR_PrintDefs (void)
{
	def_t	*d;

	for (d=pr.def_head.next ; d ; d=d->next)
		PR_PrintOfs (d->ofs);
}


/*
==============
PR_BeginCompilation

called before compiling a batch of files, clears the pr struct
==============
*/
void	 PR_BeginCompilation (void *memory, int memsize)
{
	int		 i;

	pr.memory = (char *) memory;
	pr.max_memory = memsize;

	numpr_globals = RESERVED_OFS;
	pr.def_tail = &pr.def_head;
	for (i = 0; i < HASH_SIZE; i++)
		pr.def_hash_tail[i] = &pr.def_hash_head[i];

	for (i=0 ; i<RESERVED_OFS ; i++)
		pr_global_defs[i] = &def_void;

// link the function type in so state forward declarations match proper type
	pr.types = &type_function;
	type_function.next = NULL;
	pr_error_count = 0;
}


/*
==============
PR_FinishCompilation

called after all files are compiled to check for errors
Returns false if errors were detected.
==============
*/
bool	 PR_FinishCompilation (void)
{
	def_t		*d;
	bool		errors;

	errors = false;

// check to make sure all functions prototyped have code
	for (d=pr.def_head.next ; d ; d=d->next)
	{
		if (d->type->type == ev_function && !d->isParm) // function parms are ok
		{
//			f = G_FUNCTION(d->ofs);
//			if (!f || (!f->code && !f->builtin) )
			if (!d->initialized)
			{
				printf ("function %s was not defined\n", d->name);
				errors = true;
			}
		}
	}

	return !errors;
}


//=============================================================================

// FIXME: byte swap?

// this is a 16 bit, non-reflected CRC using the polynomial 0x1021
// and the initial and final xor values shown below...  in other words, the
// CCITT standard CRC used by XMODEM

#define CRC_INIT_VALUE	0xffff
#define CRC_XOR_VALUE	0x0000

static unsigned short crctable[256] =
{
	0x0000,	0x1021,	0x2042,	0x3063,	0x4084,	0x50a5,	0x60c6,	0x70e7,
	0x8108,	0x9129,	0xa14a,	0xb16b,	0xc18c,	0xd1ad,	0xe1ce,	0xf1ef,
	0x1231,	0x0210,	0x3273,	0x2252,	0x52b5,	0x4294,	0x72f7,	0x62d6,
	0x9339,	0x8318,	0xb37b,	0xa35a,	0xd3bd,	0xc39c,	0xf3ff,	0xe3de,
	0x2462,	0x3443,	0x0420,	0x1401,	0x64e6,	0x74c7,	0x44a4,	0x5485,
	0xa56a,	0xb54b,	0x8528,	0x9509,	0xe5ee,	0xf5cf,	0xc5ac,	0xd58d,
	0x3653,	0x2672,	0x1611,	0x0630,	0x76d7,	0x66f6,	0x5695,	0x46b4,
	0xb75b,	0xa77a,	0x9719,	0x8738,	0xf7df,	0xe7fe,	0xd79d,	0xc7bc,
	0x48c4,	0x58e5,	0x6886,	0x78a7,	0x0840,	0x1861,	0x2802,	0x3823,
	0xc9cc,	0xd9ed,	0xe98e,	0xf9af,	0x8948,	0x9969,	0xa90a,	0xb92b,
	0x5af5,	0x4ad4,	0x7ab7,	0x6a96,	0x1a71,	0x0a50,	0x3a33,	0x2a12,
	0xdbfd,	0xcbdc,	0xfbbf,	0xeb9e,	0x9b79,	0x8b58,	0xbb3b,	0xab1a,
	0x6ca6,	0x7c87,	0x4ce4,	0x5cc5,	0x2c22,	0x3c03,	0x0c60,	0x1c41,
	0xedae,	0xfd8f,	0xcdec,	0xddcd,	0xad2a,	0xbd0b,	0x8d68,	0x9d49,
	0x7e97,	0x6eb6,	0x5ed5,	0x4ef4,	0x3e13,	0x2e32,	0x1e51,	0x0e70,
	0xff9f,	0xefbe,	0xdfdd,	0xcffc,	0xbf1b,	0xaf3a,	0x9f59,	0x8f78,
	0x9188,	0x81a9,	0xb1ca,	0xa1eb,	0xd10c,	0xc12d,	0xf14e,	0xe16f,
	0x1080,	0x00a1,	0x30c2,	0x20e3,	0x5004,	0x4025,	0x7046,	0x6067,
	0x83b9,	0x9398,	0xa3fb,	0xb3da,	0xc33d,	0xd31c,	0xe37f,	0xf35e,
	0x02b1,	0x1290,	0x22f3,	0x32d2,	0x4235,	0x5214,	0x6277,	0x7256,
	0xb5ea,	0xa5cb,	0x95a8,	0x8589,	0xf56e,	0xe54f,	0xd52c,	0xc50d,
	0x34e2,	0x24c3,	0x14a0,	0x0481,	0x7466,	0x6447,	0x5424,	0x4405,
	0xa7db,	0xb7fa,	0x8799,	0x97b8,	0xe75f,	0xf77e,	0xc71d,	0xd73c,
	0x26d3,	0x36f2,	0x0691,	0x16b0,	0x6657,	0x7676,	0x4615,	0x5634,
	0xd94c,	0xc96d,	0xf90e,	0xe92f,	0x99c8,	0x89e9,	0xb98a,	0xa9ab,
	0x5844,	0x4865,	0x7806,	0x6827,	0x18c0,	0x08e1,	0x3882,	0x28a3,
	0xcb7d,	0xdb5c,	0xeb3f,	0xfb1e,	0x8bf9,	0x9bd8,	0xabbb,	0xbb9a,
	0x4a75,	0x5a54,	0x6a37,	0x7a16,	0x0af1,	0x1ad0,	0x2ab3,	0x3a92,
	0xfd2e,	0xed0f,	0xdd6c,	0xcd4d,	0xbdaa,	0xad8b,	0x9de8,	0x8dc9,
	0x7c26,	0x6c07,	0x5c64,	0x4c45,	0x3ca2,	0x2c83,	0x1ce0,	0x0cc1,
	0xef1f,	0xff3e,	0xcf5d,	0xdf7c,	0xaf9b,	0xbfba,	0x8fd9,	0x9ff8,
	0x6e17,	0x7e36,	0x4e55,	0x5e74,	0x2e93,	0x3eb2,	0x0ed1,	0x1ef0
};

void	 CRC_Init(unsigned short *crcvalue)
{
	*crcvalue = CRC_INIT_VALUE;
}


void	 CRC_ProcessByte(unsigned short *crcvalue, byte data)
{
	*crcvalue = (*crcvalue << 8) ^ crctable[(*crcvalue >> 8) ^ data];
}


unsigned short	 CRC_Value(unsigned short crcvalue)
{
	return crcvalue ^ CRC_XOR_VALUE;
}


//=============================================================================

/*
============
PR_WriteProgdefs

Writes the global and entity structures out
Returns a crc of the header, to be stored in
the progs file for comparison at load time.
============
*/
int		 PR_WriteProgdefs (char *filename)
{
	def_t	*d;
	char	buf[65536], *out;	// FIXME, add buffer size checks
	unsigned short		crc;

	out = buf;

	// print global vars until the first field is defined
	out += sprintf (out, "\n/* file generated by qcc, do not modify */\n\n");
	out += sprintf (out, "typedef struct\n{\tint\tpad[%i];\n", RESERVED_OFS);
	for (d = pr.def_head.next; d; d = d->next)
	{
		if (!strcmp (d->name, "end_sys_globals"))
			break;

		switch (d->type->type)
		{
			case ev_float:
				out += sprintf (out, "\tfloat\t%s;\n",d->name);
				break;
			case ev_vector:
				out += sprintf (out, "\tvec3_t\t%s;\n",d->name);
				d=d->next->next->next;	// skip the elements
				break;
			case ev_string:
				out += sprintf (out, "\tstring_t\t%s;\n",d->name);
				break;
			case ev_function:
				out += sprintf (out, "\tfunc_t\t%s;\n",d->name);
				break;
			case ev_entity:
				out += sprintf (out, "\tint\t%s;\n",d->name);
				break;
			default:
				out += sprintf (out, "\tint\t%s;\n",d->name);
				break;
		}
	}
	out += sprintf (out, "} globalvars_t;\n\n");

	// print all fields
	out += sprintf (out, "typedef struct\n{\n");
	for (d=pr.def_head.next ; d ; d=d->next)
	{
		if (!strcmp (d->name, "end_sys_fields"))
			break;

		if (d->type->type != ev_field)
			continue;

		switch (d->type->aux_type->type)
		{
			case ev_float:
				out += sprintf (out, "\tfloat\t%s;\n", d->name);
				break;
			case ev_vector:
				out += sprintf (out, "\tvec3_t\t%s;\n", d->name);
				d = d->next->next->next;	// skip the elements
				break;
			case ev_string:
				out += sprintf (out, "\tstring_t\t%s;\n", d->name);
				break;
			case ev_function:
				out += sprintf (out, "\tfunc_t\t%s;\n", d->name);
				break;
			case ev_entity:
				out += sprintf (out, "\tint\t%s;\n", d->name);
				break;
			default:
				out += sprintf (out, "\tint\t%s;\n", d->name);
				break;
		}
	}
	out += sprintf (out, "} entvars_t;\n\n");

	// do a crc of the buffer
	CRC_Init (&crc);
	for (char *p = buf; p < out; p++)
		CRC_ProcessByte (&crc, *p);

	out += sprintf (out, "#define PROGHEADER_CRC %i\n", crc);

	if (CheckParm("progdefs", 0, true, true))
	{
		printf ("writing %s\n", filename);
		FILE *f = fopen (filename, "w");

		// print header with GNU copyleft notice:
		fprintf (f, "/*\nCopyright (C) 1996-1997 Id Software, Inc.\n\n");
	    fprintf (f, "This program is free software; you can redistribute it and/or\n");
	    fprintf (f, "modify it under the terms of the GNU General Public License\n");
	    fprintf (f, "as published by the Free Software Foundation; either version 2\n");
	    fprintf (f, "of the License, or (at your option) any later version.\n\n");
	    fprintf (f, "This program is distributed in the hope that it will be useful,\n");
	    fprintf (f, "but WITHOUT ANY WARRANTY; without even the implied warranty of\n");
	    fprintf (f, "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.\n\n");

	    fprintf (f, "See the GNU General Public License for more details.\n\n");

	    fprintf (f, "You should have received a copy of the GNU General Public License\n");
	    fprintf (f, "along with this program; if not, write to the Free Software\n");
	    fprintf (f, "Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.\n*/\n\n");

	    fprintf (f, "#ifndef _PROGDEFS_H_\n#define _PROGDEFS_H_\n\n");

		fwrite (buf, out - buf, 1, f);

		fprintf (f, "\n#endif /* _PROGDEFS_H_ */\n\n");

		fclose (f);
	}

	return crc;
}


void	 PR_PrintFunction (char *name)
{
	int				 i;
	dstatement_t	*ds	= NULL;
	dfunction_t		*df	= NULL;

	for (i=0 ; i<numfunctions ; i++)
		if (!strcmp (name, strings + functions[i].s_name))
			break;
	if (i==numfunctions)
		Error ("No function named \"%s\"", name);
	df = functions + i;

	printf ("Statements for %s:\n", name);
	ds = statements + df->first_statement;
	while (1)
	{
		PR_PrintStatement (ds);
		if (!ds->op)
			break;
		ds++;
	}
}


//============================================================================

bool	 opt_idcomp			= false;
bool	 opt_dumpasm		= false;
bool	 opt_mergeconstants	= false;

/*
============
main
============
*/
int		 main (int argc, char **argv)
{
	char	*src;
	char	*src2;
	int		 arg, crc;
	char	 sourcedir[1024];
// Mavericks crash
// Not really sure about the root cause, but this works :-/
#if __APPLE__
	char     progssrc[512];
#else
	char     progssrc[1024];
#endif
	char	 filename[1024];
	eval_t	 zqcc_value;

	myargc = argc;
	myargv = argv;

	if (CheckParm ("?", 0, true, false) || CheckParm ("h", 0, true, false))
	{
		printf ("Usage: zqcc [<options>]\n");
		printf ("Where <options> may be one or more of the following:\n");
		printf ("  -srcdir <dir>   zqcc looks for progs.src in given <dir> instead of current\n");
		printf ("  -idcomp         enable vanilla id software code compatibility\n");
		printf ("  -progdefs       dump progdefs.h after successful compile\n");
		printf ("  -D<name>        #define <name>\n");
		printf ("  -progs <file>   zqcc reads <file> instead of \"progs.src\"\n");
		printf ("  -dest <file>    force writing to <file> instead of the one given in progs.src\n");
		printf ("  -asm <f1> [<f2>...] print pseudo-assembler code for function(s) to stdout\n");
		return 0;	// or should I return 1?
	}

	if (CheckParm ("idcomp", 0, true, true))
	{
		printf ("Compiling in id compatibility mode\n");
		opt_idcomp = true;
	}

	strcpy (sourcedir, "");
	arg = CheckParm ("src", 0, true, true);
	if (arg > 0 && arg < argc-1 )
	{
		char *p;

		strlcpy (sourcedir, argv[arg + 1], sizeof(sourcedir));
		p = sourcedir + strlen(sourcedir) - 1;
		if ( *p != PATHSEPARATOR)
		{
			*++p = PATHSEPARATOR;
			*++p = 0;
		}
		printf ("Source directory:  %s\n", sourcedir);
	}

	strlcpy (progssrc, "progs.src", sizeof(progssrc) - 1 );
	arg = CheckParm ("progs", 0, true, true);
	if (arg > 0 && arg < argc-1)
	{
		ExtractFileName (argv[arg+1], progssrc, sizeof(progssrc) - 1);
		printf ("Progs-Sourcefile:  %s\n", progssrc);
	}

	strcpy (destfile, "");
	arg = CheckParm ("dest", 0, true, true);
	if (arg > 0 && arg < argc-1)
	{
		strlcpy (destfile, argv[arg+1], sizeof(destfile) - 1);
		printf ("Forced Outputfile: %s\n", destfile);
	}

	InitData ();

	// set the define _ZQCC, so that it's possible to detect the compiler
	//   with #ifdef _ZQCC
	zqcc_value._float = 1;
	if (PR_AddDefine((const char *)"_ZQCC", &type_const_float, &zqcc_value, true) <= 0)
		Error ("unable to create the internal #define \"_ZQCC\"\n");

	// check for commandline defines:
	arg = 0;
	while ( (arg = CheckParm ("D", arg+1, true, true)) > 0 )
	{
		char	*name = NULL;
		if ( argv[arg][1] != 'D' )
		{
			if ( arg < (argc - 1) )
				name = argv[++arg]; // argv matches completely -> name is an extra parameter
			else
				Error ("incomplete command line parameter #%d, missing <name> for #define\n", arg);
		}
		else
			name = argv[arg] + 2; // current argv includes the name
		if (PR_AddDefine((const char *)name, &type_const_float, &zqcc_value, false) <= 0)
			Error ("ERROR: unable to create the #define \"%s\"\n", name);
	}

	sprintf (filename, "%s%s", sourcedir, progssrc);
	filename[sizeof(filename) - 1] = '\0';

	LoadFile (filename, (void **)&src);


	// first valid line in progs.src is the output file:
	pr_source_line = 0;
	src = COM_Parse (src);
	if (!src)
		Error ("No destination filename.  zqcc -help for info.\n");
	if (destfile[0] == '\0') // not set as commandline parameter
	{
		strlcpy (destfile, com_token, sizeof(destfile) - 1);
		printf ("Outputfile:       %s\n", destfile);
	}

	PR_BeginCompilation (malloc (0x100000), 0x100000);

// compile all the files
	do
	{
		src = COM_Parse(src);
		if (!src)
			break;

		// this is a hack to enable #defines in progs.src:
		if ( com_token[0] == '#' )
		{
			pr_file_p = src - strlen(com_token);
			s_file = CopyString (filename);

			PR_LexPrecomp();
		}
		else
		{
			sprintf (filename, "%s%s", sourcedir, com_token);
			printf ("Compiling %s\n", filename);
			LoadFile (filename, (void **)&src2);

			if (!PR_CompileFile (src2, filename) )
				exit (1);
		}

	} while (1);

	if (!PR_FinishCompilation ())
		Error ("compilation errors");

	arg = CheckParm ("asm", 0, true, true);
	if (arg)
	{
		for (arg++; arg < argc; arg++)
		{
			if (argv[arg][0] == '-')
				break;
			PR_PrintFunction (argv[arg]);
		}
	}


// write progdefs.h
	crc = PR_WriteProgdefs ("progdefs.h");

// write data file
	WriteData (crc);

	return 0;
}

/* vi: set ts=4 sts=4 sw=4 ai noet ic: */

