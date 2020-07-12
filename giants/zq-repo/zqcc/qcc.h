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

#include "cmdlib.h"
#include <stdio.h>
#include <setjmp.h>

#include "pr_comp.h"

/*

TODO:

"stopped at 10 errors"

other pointer types for models and clients?

compact string heap?

always initialize all variables to something safe

the def->type->type arrangement is really silly.

return type checking

parm count type checking

immediate overflow checking

pass the first two parms in call->b and call->c

*/

/*

comments
--------
// comments discard text until the end of line
/ *  * / comments discard all enclosed text (spaced out on this line because this documentation is in a regular C comment block, and typing them in normally causes a parse error)

code structure
--------------
A definition is:
	<type> <name> [ = <immediate>] {, <name> [ = <immediate>] };


types
-----
simple types: void, float, vector, string, or entity
	float		width, height;
	string		name;
	entity		self, other;

vector types:
	vector		org;	// also creates org_x, org_y, and org_z float defs


A function type is specified as: 	simpletype ( type name {,type name} )
The names are ignored except when the function is initialized.
	void()		think;
	entity()	FindTarget;
	void(vector destination, float speed, void() callback)	SUB_CalcMove;
	void(...)	dprint;		// variable argument builtin

A field type is specified as:  .type
	.vector		origin;
	.string		netname;
	.void()		think, touch, use;


names
-----
Names are a maximum of 64 characters, must begin with A-Z,a-z, or _, and can continue with those characters or 0-9.

There are two levels of scoping: global, and function.  The parameter list of a function and any vars declared inside a function with the "local" statement are only visible within that function,


immediates
----------
Float immediates must begin with 0-9 or minus sign.  .5 is illegal.

A parsing ambiguity is present with negative constants. "a-5" will be parsed as "a", then "-5", causing an error.  Seperate the - from the digits with a space "a - 5" to get the proper behavior.
	12
	1.6
	0.5
	-100

Vector immediates are three float immediates enclosed in single quotes.
	'0 0 0'
	'20.5 -10 0.00001'

String immediates are characters enclosed in double quotes.  The string cannot contain explicit newlines, but the escape character \n can embed one.  The \" escape can be used to include a quote in the string.
	"maps/jrwiz1.bsp"
	"sound/nin/pain.wav"
	"ouch!\n"

Code immediates are statements enclosed in {} braces.
statement:
	{ <multiple statements> }
	<expression>;
	local <type> <name> [ = <immediate>] {, <name> [ = <immediate>] };
	return <expression>;
	if ( <expression> ) <statement> [ else <statement> ];
	while ( <expression> ) <statement>;
	do <statement> while ( <expression> );
	<function name> ( <function parms> );

expression:
	combiations of names and these operators with standard C precedence:
	"&&", "||", "<=", ">=","==", "!=", "!", "*", "/", "-", "+", "=", ".", "<", ">", "&", "|"
	Parenthesis can be used to alter order of operation.
	The & and | operations perform integral bit ops on floats

A built in function immediate is a number sign followed by an integer.
	#1
	#12


compilation
-----------
Source files are processed sequentially without dumping any state, so if a defs file is the first one processed, the definitions will be available to all other files.

The language is strongly typed and there are no casts.

Anything that is initialized is assumed to be constant, and will have immediates folded into it.  If you change the value, your program will malfunction.  All uninitialized globals will be saved to savegame files.

Functions cannot have more than eight parameters.

Error recovery during compilation is minimal.  It will skip to the next global definition, so you will never see more than one error at a time in a given function.  All compilation aborts after ten error messages.

Names can be defined multiple times until they are defined with an initialization, allowing functions to be prototyped before their definition.

void()	MyFunction;			// the prototype

void()	MyFunction =		// the initialization
{
	dprint ("we're here\n");
};


entities and fields
-------------------


execution
---------
Code execution is initiated by C code in quake from two main places:  the timed think routines for periodic control, and the touch function when two objects impact each other.

There are three global variables that are set before beginning code execution:
	entity	world;		// the server's world object, which holds all global
						// state for the server, like the deathmatch flags
						// and the body ques.
	entity	self;		// the entity the function is executing for
	entity	other;		// the other object in an impact, not used for thinks
	float	time;		// the current game time.  Note that because the
						// entities in the world are simulated sequentially,
						// time is NOT strictly increasing.  An impact late
						// in one entity's time slice may set time higher
						// than the think function of the next entity.
						// The difference is limited to 0.1 seconds.
Execution is also caused by a few uncommon events, like the addition of a new client to an existing server.

There is a runnaway counter that stops a program if 100000 statements are executed, assuming it is in an infinite loop.

It is acceptable to change the system set global variables.  This is usually done to pose as another entity by changing self and calling a function.

The interpretation is fairly efficient, but it is still over an order of magnitude slower than compiled C code.  All time consuming operations should be made into built in functions.

A profile counter is kept for each function, and incremented for each interpreted instruction inside that function.  The "profile" console command in Quake will dump out the top 10 functions, then clear all the counters.  The "profile all" command will dump sorted stats for every function that has been executed.


afunc ( 4, bfunc(1,2,3));
will fail because there is a shared parameter marshaling area, which will cause the 1 from bfunc to overwrite the 4 already placed in parm0.  When a function is called, it copies the parms from the globals into it's privately scoped variables, so there is no collision when calling another function.

total = factorial(3) + factorial(4);
Will fail because the return value from functions is held in a single global area.  If this really gets on your nerves, tell me and I can work around it at a slight performance and space penalty by allocating a new register for the function call and copying it out.


built in functions
------------------
void(string text)	dprint;
Prints the string to the server console.

void(entity client, string text)	cprint;
Prints a message to a specific client.

void(string text)	bprint;
Broadcast prints a message to all clients on the current server.

entity()	spawn;
Returns a totally empty entity.  You can manually set everything up, or just set the origin and call one of the existing entity setup functions.

entity(entity start, .string field, string match) find;
Searches the server entity list beginning at start, looking for an entity that has entity.field = match.  To start at the beginning of the list, pass world.  World is returned when the end of the list is reached.

<FIXME: define all the other functions...>


gotchas
-------

The && and || operators DO NOT EARLY OUT like C!

Don't confuse single quoted vectors with double quoted strings

The function declaration syntax takes a little getting used to.

Don't forget the ; after the trailing brace of a function initialization.

Don't forget the "local" before defining local variables.

There are no ++ / -- operators, or operate/assign operators.

*/

//=============================================================================

// offsets are always multiplied by 4 before using
typedef int	gofs_t;				// offset in global data block
struct		def_t;

// varargs bit is hacked into type->num_parms
const int	 VA_BIT = 16;
const int	 VA_MASK = 15;


struct type_t
{
	etype_t		type;
	type_t		*aux_type;		// return type or field type
	bool		constant;

// function types are more complex
	int			num_parms;		// number of required parms ( + VA_BIT if variable parms)
	type_t		*parm_types[MAX_PARMS];	// only [num_parms] allocated

	type_t		*next;
};

struct def_t
{
	type_t		*type;
	char		*name;
	def_t		*next;
	def_t		*hash_next;
	gofs_t		ofs;
	bool		isParm;			// if true, the def is a function parameter
	def_t		*scope;			// function the def was defined in, or NULL
	def_t		*visscope;		// scope the def is visible in
	bool		initialized;	// true when a declaration included "= immediate"
};

//============================================================================

// pr_loc.h -- program local defs

const int MAX_ERRORS = 10;

const int MAX_NAME = 64;		// chars long

const int MAX_REGS = 65536;

//=============================================================================

union eval_t
{
	string_t			string;
	float				_float;
	float				vector[3];
	func_t				function;
	int					_int;
	union eval_s		*ptr;
};

extern int		type_size[8];
extern type_t	*type_for_etype[8];
extern def_t	*def_for_type[8];

extern type_t	type_void, type_string, type_float, type_vector, type_entity, type_field, type_function, type_pointer, type_floatfield;
extern type_t	type_const_string, type_const_float, type_const_vector;

extern def_t	def_void, def_string, def_float, def_vector, def_entity, def_field, def_function, def_pointer;

struct function_t
{
	int			builtin;	// if non 0, call an internal function
	int			code;		// first statement
	char		*file;		// source file with definition
	int			file_line;
	def_t		*def;
	int			parm_ofs[MAX_PARMS];	// always contiguous, right?
};


//
// output generated by prog parsing
//
struct pr_info_t
{
	char		*memory;
	int			max_memory;
	int			current_memory;
	type_t		*types;

	def_t		def_head;		// unused head of linked list
	def_t		*def_tail;		// add new defs after this and move it

	def_t		def_hash_head[HASH_SIZE];
	def_t		*def_hash_tail[HASH_SIZE];

	int			size_fields;
};

extern pr_info_t	pr;

struct opcode_t
{
	char		*name;
	char		*opname;
	float		priority;
	bool		right_associative;
	etype_t		type_a, type_b, type_c;
};

typedef struct	 define_s
{
	char		*name;
	bool		 defined;
	eval_t		 value;
	type_t		*type;
	bool		 reserved;
}				 define_t;

//============================================================================


extern opcode_t		pr_opcodes[99];		// sized by initialization

extern def_t		*pr_global_defs[MAX_REGS];	// to find def for a global variable

enum token_type_t
{
	tt_eof,			// end of file reached
	tt_name, 		// an alphanumeric name token
	tt_punct, 		// code punctuation
	tt_immediate,	// string, float, vector
};

extern char			pr_token[2048];
extern token_type_t	pr_token_type;
extern type_t		*pr_immediate_type;
extern eval_t		pr_immediate;

void PR_PrintStatement (dstatement_t *s);

void PR_Lex (void);
void PR_LexPrecomp (void);
// reads the next token into pr_token and classifies its type

type_t *PR_ParseType (void);
type_t *PR_ParseFunctionType (type_t *returnType);
char *PR_ParseName (void);

// compilation warning level for PR_Warning
enum {
	WARN_HIGH,
	WARN_MEDIUM,
	WARN_LOW,
	WARN_LOWEST
};

bool PR_Check (char *string);
void PR_Expect (char *string);
void PR_ParseError (char *error, ...);
void PR_Warning (int level, char *text, ...);


extern jmp_buf		pr_parse_abort;		// longjump with this on parse error
extern int			pr_source_line;
extern char			*pr_file_p;


extern def_t	*pr_scope;
extern int		pr_error_count;

void PR_NewLine (void);
def_t *PR_FindDef (char *name, def_t *scope);
def_t *PR_GetDef (type_t *type, char *name, def_t *scope, def_t *visscope, bool isParm = false);

void PR_PrintDefs (void);
void PR_PrintOfs (gofs_t ofs);
void PR_PrintFunction (char *name);

void PR_SkipToSemicolon (void);

extern char		pr_parm_names[MAX_PARMS][MAX_NAME];
extern bool		pr_trace;

#define	G_FLOAT(o) (pr_globals[o])
#define	G_INT(o) (*(int *)&pr_globals[o])
#define	G_VECTOR(o) (&pr_globals[o])
#define	G_STRING(o) (strings + *(string_t *)&pr_globals[o])
#define	G_FUNCTION(o) (*(func_t *)&pr_globals[o])

char *PR_ValueString (etype_t type, void *val);

void PR_ClearGrabMacros (void);

bool PR_CompileFile (char *string, char *filename);

extern string_t	s_file;			// filename for function definition

extern def_t	def_ret, def_parms[MAX_PARMS];

//=============================================================================

const int MAX_STRINGS		= 500000;
const int MAX_GLOBALS		= 16384;
const int MAX_FIELDS		= 1024;
const int MAX_STATEMENTS	= 65536;
const int MAX_FUNCTIONS		= 8192;

const int MAX_DEFINES		= 128;

const int MAX_SOUNDS		= 1024;
const int MAX_MODELS		= 1024;
const int MAX_FILES			= 1024;
const int MAX_DATA_PATH		= 64;

extern char		strings[MAX_STRINGS];
extern int		strofs;

extern dstatement_t	statements[MAX_STATEMENTS];
extern int		numstatements;
extern int		statement_linenums[MAX_STATEMENTS];

extern dfunction_t	functions[MAX_FUNCTIONS];
extern int		numfunctions;

extern float		pr_globals[MAX_REGS];
extern int		numpr_globals;

extern char		pr_immediate_string[2048];

int	CopyString (char *str);

/* Functions for Preprocessor defines */
void	 PR_InitDefines (void);
int		 PR_AddDefine (const char *name, const type_t *type, const eval_t *value, bool reserved);
void	 PR_DelDefine (const char *name, bool overrideReserved);
int		 PR_FindDefine (const char *name, bool fullDefined);

// don't take const into account
bool	CompareType (type_t *t1, type_t *t2);

// compilation options
extern bool		opt_idcomp;			// to allow vanilla id Software code to compile
extern bool		opt_dumpasm;
extern bool		opt_mergeconstants;
