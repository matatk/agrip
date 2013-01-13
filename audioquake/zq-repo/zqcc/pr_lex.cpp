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

int		 pr_source_line;

char		*pr_file_p;
char		*pr_line_start;		// start of current source line

int			pr_bracelevel;

char		pr_token[2048];
token_type_t	pr_token_type;
type_t		*pr_immediate_type;
eval_t		pr_immediate;

char	pr_immediate_string[2048];

int		pr_error_count;

/* structure for preprocessor defines: */
static define_t	 pr_defines[MAX_DEFINES];
static int		 hash_defines[HASH_SIZE];
static int		 num_defines	= 0;

/* nested #ifdefs */
static int		 ifdefdepth		= 0;
static int		 ignoredepth	= 0;

char	*pr_punctuation[] =
// longer symbols must be before a shorter partial match
{"&&", "||", "<=", ">=","==", "!=", ";", ",", "!", "*", "/", "(", ")", "-", "+", "=", "[", "]", "{", "}", "...", ".", "<", ">" , "#" , "&" , "|" , NULL};

// simple types.  function types are dynamically allocated
type_t	type_void = {ev_void};
type_t	type_string = {ev_string};
type_t	type_float = {ev_float};
type_t	type_vector = {ev_vector};
type_t	type_entity = {ev_entity};
type_t	type_field = {ev_field};
type_t	type_function = {ev_function, &type_void};	// type_function is a void() function used for state defs
type_t	type_pointer = {ev_pointer};
type_t	type_floatfield = {ev_field, &type_float};

type_t	type_const_string = {ev_string, NULL, true};
type_t	type_const_float = {ev_float, NULL, true};
type_t	type_const_vector = {ev_vector, NULL, true};

def_t	def_void = {&type_void, "temp"};
def_t	def_string = {&type_string, "temp"};
def_t	def_float = {&type_float, "temp"};
def_t	def_vector = {&type_vector, "temp"};
def_t	def_entity = {&type_entity, "temp"};
def_t	def_field = {&type_field, "temp"};
def_t	def_function = {&type_function, "temp"};
def_t	def_pointer = {&type_pointer, "temp"};

def_t	def_ret, def_parms[MAX_PARMS];

int		type_size[8] = {1,1,1,3,1,1,1,1};
type_t	*type_for_etype[8] = {&type_void, &type_string, &type_float, &type_vector, &type_entity, &type_field, &type_function, &type_pointer};
def_t	*def_for_type[8] = {&def_void, &def_string, &def_float, &def_vector, &def_entity, &def_field, &def_function, &def_pointer};


static void		 PR_LexWhitespace (void);


// don't take const into account
bool CompareType (type_t *t1, type_t *t2)
{
	if (t1->type != t2->type
	|| t1->aux_type != t2->aux_type
	|| t1->num_parms != t2->num_parms)
		return false;

	if (t1->type != ev_function)
		return true;

	for (int i = 0; i < (t1->num_parms & VA_MASK); i++)
		if (t1->parm_types[i] != t2->parm_types[i])
			return false;

	return true;
}

/*
==============
PR_PrintNextLine
==============
*/
void PR_PrintNextLine (void)
{
	char	*t;

	printf ("%3i:",pr_source_line);
	for (t=pr_line_start ; *t && *t != '\n' ; t++)
		printf ("%c",*t);
	printf ("\n");
}

/*
==============
PR_NewLine

Call at start of file and when *pr_file_p == '\n'
==============
*/
void PR_NewLine (void)
{
	bool m;

	if (*pr_file_p == '\n')
	{
		pr_file_p++;
		m = true;
	}
	else
		m = false;

	pr_source_line++;
	pr_line_start = pr_file_p;

	if (opt_dumpasm)
		PR_PrintNextLine ();

	if (m)
		pr_file_p--;
}

/*
==============
PR_LexString

Parses a quoted string
==============
*/
void PR_LexString (void)
{
	int		c;
	int		len;

	len = 0;
	pr_file_p++;
	do
	{
		c = *pr_file_p++;
		if (!c)
			PR_ParseError ("EOF inside quote");
		if (c=='\n')
			PR_ParseError ("newline inside quote");
		if (c=='\\')
		{	// escape char
			c = *pr_file_p++;
			if (!c)
				PR_ParseError ("EOF inside quote");
			if (c == 'n')
				c = '\n';
			else if (c == '"')
				c = '"';
			else
				PR_ParseError ("unknown escape char");
		}
		else if (c=='\"')
		{
			pr_token[len] = 0;
			pr_token_type = tt_immediate;
			pr_immediate_type = &type_const_string;
			strlcpy (pr_immediate_string, pr_token, sizeof(pr_immediate_string));
			return;
		}
		pr_token[len] = c;
		len++;
	} while (1);
}

/*
==============
PR_LexNumber
==============
*/
float PR_LexNumber (void)
{
	bool	neg = false;
	bool	dot = false;

	char *token_start = pr_file_p;

	if (*pr_file_p == '-') {
		neg = true;
		pr_file_p++;
	}

	// check for hex
	if (pr_file_p[0] == '0' && (pr_file_p[1] == 'x' || pr_file_p[1] == 'X') )
	{
		int ival = 0;

		pr_file_p += 2;
		while (1)
		{
			int c = (int)(unsigned char)*pr_file_p;

			if ( isdigit(c) )
				ival = (ival << 4) + (c - (int)'0');
			else if ( isxdigit(c) )
				ival = (ival << 4) + (tolower(c) - (int)'a') + 10;
			else if ( isalpha(c) )
				PR_ParseError ("syntax error : '%c'", c);
			else
				break;	// found a legal non-numeric char

			// FIXME, raise error on 0x, etc ("hex constants must have at least one hex digit")

			pr_file_p++;
		}

		int len = pr_file_p - token_start;
		if (len > (int)sizeof(pr_token))
			PR_ParseError ("constant too long");
		memcpy (pr_token, token_start, len);
		pr_token[len] = 0;

		return neg ? -(float)ival : (float)ival;
	}

	// parse decimal
	while (1)
	{
		int c = (int)(unsigned char)*pr_file_p;

		if ( isdigit(c) ) {
		}
		else if (c == '.' && !dot)
			dot = true;
		else if ( isalpha(c) )
			PR_ParseError ("syntax error : '%c'", c);
		else
			break;	// found a legal non-numeric char

		pr_file_p++;
	}

	int len = pr_file_p - token_start;
	if (len > (int)sizeof(pr_token))
		PR_ParseError ("constant too long");
	memcpy (pr_token, token_start, len);
	pr_token[len] = 0;

	return atof(pr_token);
}

/*
==============
PR_LexVector

Parses a single quoted vector
==============
*/
void PR_LexVector (void)
{
	int		i;

	pr_file_p++;
	pr_token_type = tt_immediate;
	pr_immediate_type = &type_const_vector;

	// FIXME, we'd better not allow any whitespace but space chars and tabs inside vector immediates...
	PR_LexWhitespace ();
	for (i=0 ; i<3 ; i++)
	{
		pr_immediate.vector[i] = PR_LexNumber ();
		PR_LexWhitespace ();
	}
	if (*pr_file_p != '\'')
		PR_ParseError ("bad vector");
	pr_file_p++;
}

/*
==============
PR_LexName

Parses an identifier
==============
*/
void PR_LexName (void)
{
	int		c;
	int		len;

	len = 0;
	c = (int)(unsigned char)*pr_file_p;
	do
	{
		pr_token[len] = c;
		len++;
		pr_file_p++;
		c = *pr_file_p;
	} while ( isalpha(c) || c == '_' || isdigit(c) );
	pr_token[len] = 0;
	pr_token_type = tt_name;
}

/*
==============
PR_LexPunctuation
==============
*/
void PR_LexPunctuation (void)
{
	int		i;
	int		len;
	char	*p;

	pr_token_type = tt_punct;

	for (i=0 ; (p = pr_punctuation[i]) != NULL ; i++)
	{
		len = strlen(p);
		if (!strncmp(p, pr_file_p, len) )
		{
			strlcpy (pr_token, p, sizeof(pr_token));
			if (p[0] == '{')
				pr_bracelevel++;
			else if (p[0] == '}')
				pr_bracelevel--;
			pr_file_p += len;
			return;
		}
	}

	PR_ParseError ("unknown character '0x%02x'", (byte)*pr_file_p);
}


/*
==============
PR_LexWhitespace
==============
*/
static void	 PR_LexWhitespace (void)
{
	int		c;

	while (1)
	{
	// skip whitespace
		while ( (c = *pr_file_p) <= ' ')
		{
			if (c=='\n')
				PR_NewLine ();
			if (c == 0)
				return;		// end of file
			pr_file_p++;
		}

	// skip // comments
		if (c=='/' && pr_file_p[1] == '/')
		{
			while (*pr_file_p && *pr_file_p != '\n')
				pr_file_p++;
			PR_NewLine();
			pr_file_p++;
			continue;
		}

	// skip /* */ comments
		if (c=='/' && pr_file_p[1] == '*')
		{
			do
			{
				pr_file_p++;
				if (pr_file_p[0]=='\n')
					PR_NewLine();
				if (pr_file_p[1] == 0)
					return;
			} while (pr_file_p[-1] != '*' || pr_file_p[0] != '/');
			pr_file_p++;
			continue;
		}

		break;		// a real character has been found
	}
}

//============================================================================

const int MAX_FRAMES = 256;

char	pr_framemacros[MAX_FRAMES][16];
int		pr_nummacros;

void PR_ClearGrabMacros (void)
{
	pr_nummacros = 0;
}

void PR_FindMacro (void)
{
	int		i;

	for (i=0 ; i<pr_nummacros ; i++)
		if (!strcmp (pr_token, pr_framemacros[i]))
		{
			sprintf (pr_token,"%d", i);
			pr_token_type = tt_immediate;
			pr_immediate_type = &type_const_float;
			pr_immediate._float = i;
			return;
		}
	PR_ParseError ("unknown frame macro $%s", pr_token);
}

// just parses text, returning false if an eol is reached
bool PR_SimpleGetToken (void)
{
	int		c;
	int		i;

// skip whitespace
	while ( (c = *pr_file_p) <= ' ')
	{
		if (c=='\n' || c == 0)
			return false;
		pr_file_p++;
	}

	i = 0;
	while ( (c = *pr_file_p) > ' ' && c != ',' && c != ';')
	{
		pr_token[i] = c;
		i++;
		pr_file_p++;
	}
	pr_token[i] = 0;
	return true;
}


void PR_ParseFrame (void)
{
	while (PR_SimpleGetToken ())
	{
		strlcpy (pr_framemacros[pr_nummacros], pr_token, sizeof(pr_framemacros[pr_nummacros]));
		pr_nummacros++;
	}
}

/*
==============
PR_LexGrab

Deals with counting sequence numbers and replacing frame macros
==============
*/
void PR_LexGrab (void)
{
	pr_file_p++;	// skip the $
	if (!PR_SimpleGetToken ())
		PR_ParseError ("hanging $");

// check for $frame
	if (!strcmp (pr_token, "frame"))
	{
		PR_ParseFrame ();
		PR_Lex ();
	}
// ignore other known $commands
	else if (!strcmp (pr_token, "cd")
	|| !strcmp (pr_token, "origin")
	|| !strcmp (pr_token, "base")
	|| !strcmp (pr_token, "flags")
	|| !strcmp (pr_token, "scale")
	|| !strcmp (pr_token, "skin") )
	{	// skip to end of line
		while (PR_SimpleGetToken ())
		;
		PR_Lex ();
	}
// look for a frame name macro
	else
		PR_FindMacro ();
}


//============================================================================

/*
========================
PR_LexPrecomp

parses and executes directives
  with a leading '#':
  #define
  #undef
  #ifdef
  #ifndef
  #else
  #endif
  #error
  #message
  #pragma message
========================
*/
void          PR_LexPrecomp (void)
{
	// yeah it isn't quite Precompiler is it?
	pr_file_p++;  // skip the hash
	if (!PR_SimpleGetToken ())
		PR_ParseError ("Q534: Invalid preprocessor command"); // that's not possible

	if (!strcmp(pr_token, "ifdef"))
	{
		if (ifdefdepth > ignoredepth)
		{
			// inside another ignored "ifdef"/"ifndef"
			// -> ignore statements
			ifdefdepth++;
			return;
		}
		ifdefdepth++;
		ignoredepth = ifdefdepth;
		PR_Lex();
		if (!PR_FindDefine(pr_token, true))
		{
			// not defined
			// -> ignore statements until endif or else
			ignoredepth--;
			while(ifdefdepth > ignoredepth)
				PR_Lex();
			return;
		}
		// defined
		// -> parse statements
		PR_Lex();
		return;
	}
	else
	if (!strcmp(pr_token, "ifndef"))
	{
		if (ifdefdepth > ignoredepth)
		{
			// inside another ignored ifdef
			// -> ignore statements
			ifdefdepth++;
			return;
		}
		ifdefdepth++;
		ignoredepth = ifdefdepth;
		PR_Lex();
		if (PR_FindDefine(pr_token, true))
		{
			// defined
			// -> ignore statements
			ignoredepth--;
			while(ifdefdepth > ignoredepth)
				PR_Lex();
			return;
		}
		PR_Lex();
		return;
	}
	else
	if (!strcmp(pr_token, "endif"))
	{
		ifdefdepth--;
		if (ifdefdepth < 0)
		  PR_ParseError ("Q119: Too many #endifs");
		PR_Lex();
		return;
	}
	else
	if (!strcmp(pr_token, "else"))
	{
		if (ifdefdepth == (ignoredepth + 1))
		{
			// the "ifdef" or "ifndef" part has not been entered
			// -> parse the statements inside "else"
			//print("parsing statment %s in else on %s(%ld)", pr_token, s_file + strings, pr_source_line);
			ignoredepth = ifdefdepth;
			pr_token_type = tt_name;
			PR_Lex();
			return;
		}

		// "ifdef" or "ifndef" part has already been entered
		// -> ignore statements in "else" part
		ignoredepth--;
		while (ifdefdepth > ignoredepth)
			PR_Lex();
		return;
	}
	else
	if (ifdefdepth > ignoredepth)
	{
		//print("ignored %s on %s(%ld)", pr_token, s_file + strings, pr_source_line);
		return;
	}
	else
	if (PR_Check("error"))
	{
		if (pr_immediate_type != &type_string && pr_immediate_type != &type_const_string)
		  PR_ParseError ("Q541: Error must be a string");
		PR_ParseError ("User Error on %s(%ld): %s", s_file + strings, pr_source_line, pr_immediate_string);
		PR_Lex();
		return;
	}
	else
	if (PR_Check("message"))
	{
		if (pr_immediate_type != &type_string && pr_immediate_type != &type_const_string)
		  PR_ParseError ("Q541: Message must be a string");
		printf ("Message on %s(%ld): %s\n", s_file + strings, (long)pr_source_line, pr_immediate_string);
		PR_Lex();
		return;
	}
	else
	if (PR_Check("pragma"))
	{
		if (PR_Check("message"))
		{
			if (pr_immediate_type != &type_string && pr_immediate_type != &type_const_string)
				PR_ParseError ("Q541: Message must be a string");
			printf ("Message on %s(%ld): %s\n", s_file + strings, (long)pr_source_line, pr_immediate_string);
			PR_Lex();
			return;
		}

		// unknown pragma directive
		printf ("Warning on %s(%ld): unknown #pragma \"%s\" (will be ignored)", s_file + strings, (long)pr_source_line, pr_token);

		// skip to the end of the line
		while (PR_SimpleGetToken ())
			;

		PR_Lex();
		return;
	}
	else
	if (PR_Check("define"))
	{
		char	define_name[2048];

		if (pr_token_type != tt_name)
			PR_ParseError ("Q543: #define: Invalid name");

		// predefine it:
		strlcpy (define_name, pr_token, sizeof(define_name));

		if (PR_AddDefine (define_name, &type_const_float, NULL, false) <= 0)
			PR_ParseError ("Q544: #define \"%s\": creation failed", define_name);

		// get the value of the define
		PR_Lex();
		if (pr_token_type == tt_immediate)
		{
			if (pr_immediate_type != &type_float && pr_immediate_type != &type_const_float)
				PR_ParseError ("Q545: #define \"%s\": Invalid type of value", define_name);

         // finally fix the define (with given value)
			if (PR_AddDefine (define_name, pr_immediate_type, &pr_immediate, false) <= 0)
				PR_ParseError ("Q544: #define \"%s\": creation failed", define_name);

			PR_Lex();
		}
		else
		{
			eval_t   value;

			value._float = 1;

			// finally fix the define (with default-value)
			if (PR_AddDefine (define_name, &type_const_float, &value, false) <= 0)
				PR_ParseError ("Q544: #define \"%s\": creation failed", define_name);
		}

		return;
	}
	else
	if (PR_Check("undef"))
	{
		if (pr_token_type != tt_name)
			PR_ParseError ("Q544: #undef: Invalid name");

		PR_DelDefine (pr_token, false);

		PR_Lex();
		return;
	}
} // END_FUNC PR_LexPrecomp


//============================================================================

/*
==============
PR_Lex

Sets pr_token, pr_token_type, and possibly pr_immediate and pr_immediate_type
==============
*/
void PR_Lex (void)
{
	int		c;

	pr_token[0] = 0;

	if (!pr_file_p)
	{
		pr_token_type = tt_eof;
		return;
	}

	PR_LexWhitespace ();

	c = *pr_file_p;
	if (!c)
	{
		pr_token_type = tt_eof;
		return;
	}

// handle quoted strings as a unit
	if (c == (int)'\"')
	{
		PR_LexString ();
		return;
	}

// handle quoted vectors as a unit
	if (c == (int)'\'')
	{
		PR_LexVector ();
		return;
	}

// if the first character is a valid identifier, parse until a non-id
// character is reached
	if ( isdigit(c) ||
		( c == (int)'.' && isdigit((int)(unsigned char)pr_file_p[1]) ) ||
		( c == (int)'-' && (isdigit((int)(unsigned char)pr_file_p[1]) || pr_file_p[1] == '.') )
		)
	{
		pr_token_type = tt_immediate;
		pr_immediate_type = &type_const_float;
		pr_immediate._float = PR_LexNumber ();
		return;
	}

	if ( isalpha(c) || c == (int)'_' )
	{
		PR_LexName ();
		return;
	}

	if (c == (int)'$')
	{
		PR_LexGrab ();
		return;
	}

   if (c == (int)'#')
   {
      if ( isalpha((int)(unsigned char)pr_file_p[1]) || pr_file_p[1] == '_' )
      {
         PR_LexPrecomp();
         return;
      }
   }

// parse symbol strings until a non-symbol is found
	PR_LexPunctuation ();
}

//=============================================================================

/*
============
PR_ParseError

Aborts the current file load
============
*/
void PR_ParseError (char *text, ...)
{
	va_list		argptr;
	char		string[1024];

	va_start (argptr, text);
	vsprintf (string, text,argptr);
	va_end (argptr);

	printf ("%s(%i): error: %s\n", strings + s_file, pr_source_line, string);

	longjmp (pr_parse_abort, 1);
}

/*
============
PR_Warning

Prints a warning if level <= pr_warnlevel
Lower level value is higher importance
============
*/
void PR_Warning (int level, char *text, ...)
{
	va_list		argptr;
	char		string[1024];

	va_start (argptr, text);
	vsprintf (string, text, argptr);
	va_end (argptr);

//	if (level <= pr_warnlevel)
		printf ("%s(%i): warning: %s\n", strings + s_file, pr_source_line, string);
}

/*
=============
PR_Expect

Issues an error if the current token isn't equal to string
Gets the next token
=============
*/
void PR_Expect (char *string)
{
	if (strcmp (string, pr_token))
		PR_ParseError ("expected %s, found %s",string, pr_token);
	PR_Lex ();
}


/*
=============
PR_Check

Returns true and gets the next token if the current token equals string
Returns false and does nothing otherwise
=============
*/
bool PR_Check (char *string)
{
	if (strcmp (string, pr_token))
		return false;

	PR_Lex ();
	return true;
}

/*
============
PR_ParseName

Checks to see if the current token is a valid name
============
*/
char *PR_ParseName (void)
{
	static char	ident[MAX_NAME];

	if (pr_token_type != tt_name)
		PR_ParseError ("'%s' : not a name", pr_token);
	if (strlen(pr_token) >= MAX_NAME-1)
		PR_ParseError ("name too long");
	strlcpy (ident, pr_token, sizeof(ident));
	PR_Lex ();

	return ident;
}

/*
============
PR_GetType

Returns a preexisting complex type that matches the parm, or allocates
a new one and copies it out.
============
*/
type_t *PR_GetType (type_t *type)
{
	type_t	*check;
	int		i;

	for (check = pr.types ; check ; check = check->next)
	{
		if (check->type != type->type
		|| check->aux_type != type->aux_type
		|| check->num_parms != type->num_parms
		|| check->constant != type->constant)
			continue;

		for (i = 0; i < (type->num_parms & VA_MASK); i++)
			if (check->parm_types[i] != type->parm_types[i])
				break;

		if (i == (type->num_parms & VA_MASK))
			return check;
	}

// allocate a new one
	check = (type_t *) malloc (sizeof (*check));
	*check = *type;
	check->next = pr.types;
	pr.types = check;

	return check;
}


/*
============
PR_SkipToSemicolon

For error recovery, also pops out of nested braces
============
*/
void PR_SkipToSemicolon (void)
{
	do
	{
		if (!pr_bracelevel && PR_Check (";"))
			return;
		PR_Lex ();
	} while (pr_token[0]);	// eof will return a null token
}


/*
============
PR_ParseFunctionType

Parses parms in a function declaration , after '(' and till ')'
============
*/
char pr_parm_names[MAX_PARMS][MAX_NAME];

type_t *PR_ParseFunctionType (type_t *returnType)
{
	type_t	newtype;
	memset (&newtype, 0, sizeof(newtype));
	newtype.type = ev_function;
	newtype.aux_type = returnType;
	newtype.num_parms = 0;

	if (PR_Check (")")) {
		// empty args
		return PR_GetType (&newtype);
	}

	do {
		if (PR_Check ("...")) {
			// variable args
			PR_Expect (")");
			newtype.num_parms |= VA_BIT;
			return PR_GetType (&newtype);
		}

		if (newtype.num_parms >= MAX_PARMS)
			PR_ParseError ("too many parameters (max. %d allowed)", (int)MAX_PARMS);

		type_t *type = PR_ParseType ();
		char *name = PR_ParseName ();
		strlcpy (pr_parm_names[newtype.num_parms], name, sizeof(pr_parm_names[newtype.num_parms]));
		newtype.parm_types[newtype.num_parms] = type;
		newtype.num_parms++;
	} while (PR_Check (","));

	PR_Expect (")");

	return PR_GetType(&newtype);
}

/*
============
PR_ParseType

Parses a variable type, including field and functions types
============
*/
type_t *PR_ParseType (void)
{
	if (PR_Check ("."))
	{
		type_t	newtype;
		memset (&newtype, 0, sizeof(newtype));
		newtype.type = ev_field;
		newtype.aux_type = PR_ParseType ();
		return PR_GetType (&newtype);
	}

	type_t	*type;

	bool constant = PR_Check ("const");

	if (!strcmp (pr_token, "float") )
		type = constant ? &type_const_float : &type_float;
	else if (!strcmp (pr_token, "vector") )
		type = constant ? &type_const_vector : &type_vector;
	else if (!strcmp (pr_token, "entity") )
		type = &type_entity;
	else if (!strcmp (pr_token, "string") )
		type = constant ? &type_const_string : &type_string;
	else if (!strcmp (pr_token, "void") )
		type = &type_void;
	else
	{
		PR_ParseError ("\"%s\" is not a type", pr_token);
		type = &type_void;	// shut up compiler warning
	}
	PR_Lex ();

	if (PR_Check("(")) {
		// function type

		// go back to non-const types
		// FIXME: don't bother?  Or force const types instead?
		if (type == &type_const_float)
			type = &type_float;
		else if (type == &type_const_vector)
			type = &type_vector;
		else if (type == &type_const_string)
			type = &type_string;

		return PR_ParseFunctionType(type);
	}

	return type;
}


//=============================================================================

/*
========================
PR_InitDefines

(Re-)initialize the defines structures
========================
*/
void		 PR_InitDefines (void)
{
	int		 i;

	for (i = 0; i < HASH_SIZE; i++)
		hash_defines[i] = 0;
	for (i = 0; i < MAX_DEFINES; i++)
	{
		if (i > 0 && i < num_defines)
			free (pr_defines[i].name);
		pr_defines[i].name		= NULL;
		pr_defines[i].defined	= false;
		pr_defines[i].type		= NULL;
		pr_defines[i].reserved	= false;
	}

	num_defines = 0;
}  // END_FUNC PR_InitDefines


/*
========================
PR_AddDefine

Add a new define
if value and type are both set,
  the define will be "activated",
  otherwise it's only "predefined".
reserved defines may not be changed
  or deleted.
========================
*/
int			 PR_AddDefine (const char *name, const type_t *type, const eval_t *value, bool reserved)
{
	int		 i	= 0;

	if (!name)
		return 0;

	i = PR_FindDefine (name, false);
	if (i <= 0)
	{
		// add new define
		i = ++num_defines;
		if (num_defines >= MAX_DEFINES)
			Error ("num_defines >= MAX_DEFINES (%d)", (int)MAX_DEFINES);

		hash_defines[Com_HashKey(name)] = i;
		pr_defines[i].name = (char *)SafeMalloc (strlen(name) + 1);
		strcpy(pr_defines[i].name, name);

		printf ("Additional %s#define: %s\n", reserved ? "reserved " : "", name);
	}
	else 
	if (pr_defines[i].reserved && pr_defines[i].defined)
	{
		// a reserved constant shall be modified
		// -> this is not allowed
		PR_ParseError ("\"%s\" is a reserved #define and must not be changed!", name);
		return 0;
	}

	// modify value of define
	pr_defines[i].type         = (type_t *)type;
	if (value)
		memcpy (&(pr_defines[i].value), value, sizeof(eval_t));
	pr_defines[i].reserved = reserved;

	if (type && value)
		pr_defines[i].defined = true;
	else
		pr_defines[i].defined = false;

	return i;
} // END_FUNC PR_AddDefine


/*
========================
PR_DelDefine

delete an existing define
========================
*/
void		 PR_DelDefine (const char *name, bool overrideReserved)
{
	int     i  = 0;
	int     j  = 0;

	if (!name)
		return;

	i = PR_FindDefine (name, false);
	if (i <= 0)
		return;

	if (pr_defines[i].reserved && pr_defines[i].defined && !overrideReserved)
	{
		PR_ParseError ("\"%s\" is a reserved #define and must not be deleted!", name);
		return;
	}


	printf ("Removed #define: %s\n", pr_defines[i].name);

	free (pr_defines[i].name);

	num_defines--;
	for (j = i; j <= num_defines; j++)
		memcpy (&(pr_defines[j]), &(pr_defines[j + 1]), sizeof(define_t));
	for (j = 0; j < HASH_SIZE; j++)
	{
		if (hash_defines[j] > i)
			hash_defines[j]--;
		else
		if (hash_defines[j] == i)
			hash_defines[j] = 0;
	}

	return;
} // END_FUNC PR_DelDefine


/*
========================
PR_FindDefine

search for an exiting
  define and give back
  the index (starting
  with 1)
  or 0 if not found.
========================
*/
int			 PR_FindDefine (const char *name, bool fullDefined)
{
	int		 i;
	int		 h;

	h = Com_HashKey(name);
	i = hash_defines[h];
	if (i > 0 &&
	    !strcmp(name, pr_defines[i].name) &&
	    (!fullDefined || pr_defines[i].defined))
		return i;
	for (i = num_defines; i > 0; i--)
	{
		if (!strcmp(name, pr_defines[i].name))
		{
			hash_defines[h] = i;

			if (!fullDefined || pr_defines[i].defined)
				return i;
		}
	}
	return 0;
} // END_FUNC PR_FindDefine

/* vi: set noet ts=4 sts=4 ai sw=4: */
