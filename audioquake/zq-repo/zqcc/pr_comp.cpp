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


pr_info_t	pr;
def_t		*pr_global_defs[MAX_REGS];	// to find def for a global variable
int			pr_edict_size;

//========================================

def_t		*pr_scope;		// the function being parsed, or NULL
string_t	s_file;			// filename for function definition

int			locals_end;		// for tracking local variables vs temps

jmp_buf		pr_parse_abort;		// longjump with this on parse error

void PR_ParseDefs (void);

//========================================


opcode_t pr_opcodes[] =
{
 {"<DONE>", "DONE", -1, false, ev_entity, ev_field, ev_void},

 {"*", "MUL_F", 2, false, ev_float, ev_float, ev_float},
 {"*", "MUL_V", 2, false, ev_vector, ev_vector, ev_float},
 {"*", "MUL_FV", 2, false, ev_float, ev_vector, ev_vector},
 {"*", "MUL_VF", 2, false, ev_vector, ev_float, ev_vector},

 {"/", "DIV", 2, false, ev_float, ev_float, ev_float},

 {"+", "ADD_F", 3, false, ev_float, ev_float, ev_float},
 {"+", "ADD_V", 3, false, ev_vector, ev_vector, ev_vector},

 {"-", "SUB_F", 3, false, ev_float, ev_float, ev_float},
 {"-", "SUB_V", 3, false, ev_vector, ev_vector, ev_vector},

 {"==", "EQ_F", 4, false, ev_float, ev_float, ev_float},
 {"==", "EQ_V", 4, false, ev_vector, ev_vector, ev_float},
 {"==", "EQ_S", 4, false, ev_string, ev_string, ev_float},
 {"==", "EQ_E", 4, false, ev_entity, ev_entity, ev_float},
 {"==", "EQ_FNC", 4, false, ev_function, ev_function, ev_float},

 {"!=", "NE_F", 4, false, ev_float, ev_float, ev_float},
 {"!=", "NE_V", 4, false, ev_vector, ev_vector, ev_float},
 {"!=", "NE_S", 4, false, ev_string, ev_string, ev_float},
 {"!=", "NE_E", 4, false, ev_entity, ev_entity, ev_float},
 {"!=", "NE_FNC", 4, false, ev_function, ev_function, ev_float},

 {"<=", "LE", 4, false, ev_float, ev_float, ev_float},
 {">=", "GE", 4, false, ev_float, ev_float, ev_float},
 {"<", "LT", 4, false, ev_float, ev_float, ev_float},
 {">", "GT", 4, false, ev_float, ev_float, ev_float},

 {".", "INDIRECT", 1, false, ev_entity, ev_field, ev_float},
 {".", "INDIRECT", 1, false, ev_entity, ev_field, ev_vector},
 {".", "INDIRECT", 1, false, ev_entity, ev_field, ev_string},
 {".", "INDIRECT", 1, false, ev_entity, ev_field, ev_entity},
 {".", "INDIRECT", 1, false, ev_entity, ev_field, ev_field},
 {".", "INDIRECT", 1, false, ev_entity, ev_field, ev_function},

 {".", "ADDRESS", 1, false, ev_entity, ev_field, ev_pointer},

 {"=", "STORE_F", 5, true, ev_float, ev_float, ev_float},
 {"=", "STORE_V", 5, true, ev_vector, ev_vector, ev_vector},
 {"=", "STORE_S", 5, true, ev_string, ev_string, ev_string},
 {"=", "STORE_ENT", 5, true, ev_entity, ev_entity, ev_entity},
 {"=", "STORE_FLD", 5, true, ev_field, ev_field, ev_field},
 {"=", "STORE_FNC", 5, true, ev_function, ev_function, ev_function},

 {"=", "STOREP_F", 5, true, ev_pointer, ev_float, ev_float},
 {"=", "STOREP_V", 5, true, ev_pointer, ev_vector, ev_vector},
 {"=", "STOREP_S", 5, true, ev_pointer, ev_string, ev_string},
 {"=", "STOREP_ENT", 5, true, ev_pointer, ev_entity, ev_entity},
 {"=", "STOREP_FLD", 5, true, ev_pointer, ev_field, ev_field},
 {"=", "STOREP_FNC", 5, true, ev_pointer, ev_function, ev_function},

 {"<RETURN>", "RETURN", -1, false, ev_void, ev_void, ev_void},

 {"!", "NOT_F", -1, false, ev_float, ev_void, ev_float},
 {"!", "NOT_V", -1, false, ev_vector, ev_void, ev_float},
 {"!", "NOT_S", -1, false, ev_vector, ev_void, ev_float},
 {"!", "NOT_ENT", -1, false, ev_entity, ev_void, ev_float},
 {"!", "NOT_FNC", -1, false, ev_function, ev_void, ev_float},

  {"<IF>", "IF", -1, false, ev_float, ev_float, ev_void},
  {"<IFNOT>", "IFNOT", -1, false, ev_float, ev_float, ev_void},

// calls returns REG_RETURN
 {"<CALL0>", "CALL0", -1, false, ev_function, ev_void, ev_void},
 {"<CALL1>", "CALL1", -1, false, ev_function, ev_void, ev_void},
 {"<CALL2>", "CALL2", -1, false, ev_function, ev_void, ev_void},
 {"<CALL3>", "CALL3", -1, false, ev_function, ev_void, ev_void},
 {"<CALL4>", "CALL4", -1, false, ev_function, ev_void, ev_void},
 {"<CALL5>", "CALL5", -1, false, ev_function, ev_void, ev_void},
 {"<CALL6>", "CALL6", -1, false, ev_function, ev_void, ev_void},
 {"<CALL7>", "CALL7", -1, false, ev_function, ev_void, ev_void},
 {"<CALL8>", "CALL8", -1, false, ev_function, ev_void, ev_void},

 {"<STATE>", "STATE", -1, false, ev_float, ev_float, ev_void},

 {"<GOTO>", "GOTO", -1, false, ev_float, ev_void, ev_void},

 {"&&", "AND", 6, false, ev_float, ev_float, ev_float},
 {"||", "OR", 6, false, ev_float, ev_float, ev_float},

 {"&", "BITAND", 2, false, ev_float, ev_float, ev_float},
 {"|", "BITOR", 2, false, ev_float, ev_float, ev_float},

 {NULL}
};

const int TOP_PRIORITY = 6;
const int NOT_PRIORITY = 4;

def_t *PR_Expression (int priority);

def_t	junkdef;

//===========================================================================


/*
============
PR_Statement

Emits a primitive statement, returning the var it places it's value in
============
*/
def_t *PR_Statement ( opcode_t *op, def_t *var_a, def_t *var_b)
{
	dstatement_t	*statement	= NULL;
	def_t			*var_c		= NULL;

	statement = &statements[numstatements];
	numstatements++;

	statement_linenums[statement-statements] = pr_source_line;
	statement->op = (unsigned short)(op - pr_opcodes);
	statement->a = var_a ? (unsigned short)var_a->ofs : (unsigned short)0;
	statement->b = var_b ? (unsigned short)var_b->ofs : (unsigned short)0;
	if (op->type_c == ev_void || op->right_associative)
	{
		var_c = NULL;
		statement->c = (unsigned short)0;  // ifs, gotos, and assignments
		                                   // don't need vars allocated
	}
	else
	{	// allocate result space
		var_c = (def_t *) malloc (sizeof(def_t));
		memset (var_c, 0, sizeof(def_t));
		var_c->ofs = numpr_globals;
		var_c->type = type_for_etype[op->type_c];

		statement->c = (unsigned short)numpr_globals;
		numpr_globals += type_size[op->type_c];

		if (numpr_globals > MAX_REGS)
			Error ("numpr_globals > MAX_REGS");
	}

	if (op->right_associative)
		return var_a;
	return var_c;
}

def_t *PR_NewDef (int hash)
{
	// allocate new def
	def_t *def = (def_t *) malloc (sizeof(def_t));
	memset (def, 0, sizeof(*def));

	// link into defs list
//	def->next = NULL;
	pr.def_tail->next = def;
	pr.def_tail = def;

	// link into hash bucket
//	def->hash_next = NULL;
	pr.def_hash_tail[hash]->hash_next = def;
	pr.def_hash_tail[hash] = def;

	return def;
}

/*
============
PR_GetImmediate

Return a preexisting constant if possible, or allocate a new def
============
*/
def_t *PR_GetImmediate (type_t *type, eval_t val, char *string = NULL /* for ev_string only */)
{
	def_t	*def;

	assert (type == &type_const_string || type == &type_const_float || type == &type_const_vector);

	char *name = "IMMEDIATE";
	int hash = Com_HashKey (name);

	if (opt_mergeconstants) {
		// check for any constant with the same value
		for (def=pr.def_head.next ; def ; def=def->next)
		{
			if (def->type != type || !def->initialized)
				continue;

			if (type == &type_const_string) {
				if (!strcmp(G_STRING(def->ofs), string) )
					return def;
			}
			else if (type == &type_const_float) {
				if ( G_FLOAT(def->ofs) == val._float )
					return def;
			}
			else /*if (type == &type_const_vector)*/ {
				if ( ( G_FLOAT(def->ofs) == val.vector[0] )
				&& ( G_FLOAT(def->ofs+1) == val.vector[1] )
				&& ( G_FLOAT(def->ofs+2) == val.vector[2] ) ) {
					return def;
				}
			}
		}
	} else {
		// check for an immediate with the same value
		for (def = pr.def_hash_head[hash].hash_next ; def ; def=def->hash_next)
		{
			if (def->type != type || !def->initialized)
				continue;

			if (strcmp(def->name, name))	// is it indeed an immediate?
				continue;

			if (type == &type_const_string) {
				if (!strcmp(G_STRING(def->ofs), string) )
					return def;
			}
			else if (type == &type_const_float) {
				if ( G_FLOAT(def->ofs) == val._float )
					return def;
			}
			else /*if (type == &type_const_vector)*/ {
				if ( ( G_FLOAT(def->ofs) == val.vector[0] )
				&& ( G_FLOAT(def->ofs+1) == val.vector[1] )
				&& ( G_FLOAT(def->ofs+2) == val.vector[2] ) ) {
					return def;
				}
			}
		}
	}

// allocate a new def
	def = PR_NewDef(hash);

	def->name = name;
	def->type = type;
	def->initialized = 1;
	def->scope = def->visscope = NULL;	// always share immediates

// copy the immediate to the global area
	if (numpr_globals + type_size[type->type] > MAX_REGS)
		Error ("numpr_globals > MAX_REGS");
	def->ofs = numpr_globals;
	pr_global_defs[def->ofs] = def;
	numpr_globals += type_size[type->type];
	if (type == &type_const_string)
		val.string = CopyString (string);

	memcpy (pr_globals + def->ofs, &val, 4*type_size[type->type]);

	return def;
}

/*
============
PR_ParseImmediate

Allocates the immediate if needed and gets next token
============
*/
def_t *PR_ParseImmediate (void)
{
	assert (pr_immediate_type == &type_const_float ||
			pr_immediate_type == &type_const_string ||
			pr_immediate_type == &type_const_vector);

	def_t *def = PR_GetImmediate (pr_immediate_type, pr_immediate, pr_immediate_string);
	PR_Lex ();

	return def;
}

/*
============
PR_ParseFunctionCall
============
*/
def_t *PR_ParseFunctionCall (def_t *func)
{
	def_t		*e;
	int			 arg;
	type_t		*t;

	t = func->type;

	if (t->type != ev_function)
		PR_ParseError ("not a function");

	// copy the arguments to the global parameter variables
	arg = 0;
	if (!PR_Check(")"))
	{
		do
		{
			if (arg >= t->num_parms || arg >= MAX_PARMS /* works properly with varargs */)
				PR_ParseError ("too many parameters");
			e = PR_Expression (TOP_PRIORITY);

			if (arg < (t->num_parms & VA_MASK) && !CompareType(e->type, t->parm_types[arg]))
				PR_ParseError ("type mismatch on parm %i", arg);
			// a vector copy will copy everything
			def_parms[arg].type = t->parm_types[arg];
			PR_Statement (&pr_opcodes[OP_STORE_V], e, &def_parms[arg]);
			arg++;
		} while (PR_Check (","));

		if (arg < (t->num_parms & VA_MASK))
			PR_ParseError ("too few parameters");
		PR_Expect (")");
	}
	if (arg > MAX_PARMS)
		PR_ParseError ("more than %d parameters", (int)MAX_PARMS);

	PR_Statement (&pr_opcodes[OP_CALL0+arg], func, 0);

	def_ret.type = t->aux_type;
	return &def_ret;
}


/*
============
PR_ParseValue

Returns the global ofs for the current token
============
*/
def_t	*PR_ParseValue (void)
{
	def_t		*d;
	char		*name;

// if the token is an immediate, allocate a constant for it
	if (pr_token_type == tt_immediate)
		return PR_ParseImmediate ();

	name = PR_ParseName ();

// look through the defs
	d = PR_FindDef (name, pr_scope);
	if (!d)
		PR_ParseError ("'%s' : undeclared identifier", name);
	return d;
}


/*
============
PR_Term
============
*/
def_t *PR_Term (void)
{
	if (pr_token_type != tt_punct)
		return PR_ParseValue ();

	def_t	*e, *e2;
	etype_t	t;

	if (PR_Check ("!"))
	{
		e = PR_Expression (NOT_PRIORITY);
		t = e->type->type;
		if (t == ev_float)
			e2 = PR_Statement (&pr_opcodes[OP_NOT_F], e, 0);
		else if (t == ev_string)
			e2 = PR_Statement (&pr_opcodes[OP_NOT_S], e, 0);
		else if (t == ev_entity)
			e2 = PR_Statement (&pr_opcodes[OP_NOT_ENT], e, 0);
		else if (t == ev_vector)
			e2 = PR_Statement (&pr_opcodes[OP_NOT_V], e, 0);
		else if (t == ev_function)
			e2 = PR_Statement (&pr_opcodes[OP_NOT_FNC], e, 0);
		else {
			PR_ParseError ("type mismatch for !");
			return NULL;	// shut up compiler
		}
		return e2;
	}

	if (PR_Check ("("))
	{
		e = PR_Expression (TOP_PRIORITY);
		PR_Expect (")");
		return e;
	}

	if (PR_Check("-")) {
		e = PR_Expression (1 /* FIXME, correct? */);
		t = e->type->type;
		if (t == ev_float) {
			eval_t v;
			v._float = 0;
			def_t *imm = PR_GetImmediate (&type_const_float, v);
			e2 = PR_Statement (&pr_opcodes[OP_SUB_F], imm, e);
		} else if (t == ev_vector) {
			eval_t v;
			v.vector[0] = v.vector[1] = v.vector[2] = 0;
			def_t *imm = PR_GetImmediate (&type_const_vector, v);
			e2 = PR_Statement (&pr_opcodes[OP_SUB_V], imm, e);
		} else {
			PR_ParseError ("type mismatch for -");
			return NULL;	// shut up compiler
		}
		return e2;
	}

	if (PR_Check("+")) {
		e = PR_Expression (1 /* FIXME, correct? */);
		t = e->type->type;
		if (t != ev_float && t != ev_vector) {
			PR_ParseError ("type mismatch for +");
			return NULL;	// shut up compiler
		}
		return e;
	}

	PR_ParseError ("syntax error : '%s'", pr_token);
	return NULL;	// shut up compiler
}


bool PR_Calc (int opcode, const eval_t *a, const eval_t *b, eval_t *c)
{
	switch (opcode) {
	case OP_ADD_F:
		c->_float = a->_float + b->_float;
		break;
	case OP_ADD_V:
		c->vector[0] = a->vector[0] + b->vector[0];
		c->vector[1] = a->vector[1] + b->vector[1];
		c->vector[2] = a->vector[2] + b->vector[2];
		break;
	case OP_SUB_F:
		c->_float = a->_float - b->_float;
		break;
	case OP_SUB_V:
		c->vector[0] = a->vector[0] - b->vector[0];
		c->vector[1] = a->vector[1] - b->vector[1];
		c->vector[2] = a->vector[2] - b->vector[2];
		break;
	case OP_MUL_F:
		c->_float = a->_float * b->_float;
		break;
	case OP_MUL_V:
		c->_float = a->vector[0]*b->vector[0] + a->vector[1]*b->vector[1] + a->vector[2]*b->vector[2];
		break;
	case OP_MUL_FV:
		c->vector[0] = a->_float * b->vector[0];
		c->vector[1] = a->_float * b->vector[1];
		c->vector[2] = a->_float * b->vector[2];
		break;
	case OP_MUL_VF:
		c->vector[0] = b->_float * a->vector[0];
		c->vector[1] = b->_float * a->vector[1];
		c->vector[2] = b->_float * a->vector[2];
		break;
	case OP_DIV_F:
		c->_float = a->_float / b->_float;		// FIXME, check b->_float
		break;
	case OP_BITAND:
		c->_float = (int)a->_float & (int)b->_float;
		break;
	case OP_BITOR:
		c->_float = (int)a->_float | (int)b->_float;
		break;
	case OP_GE:
		c->_float = a->_float >= b->_float;
		break;
	case OP_LE:
		c->_float = a->_float <= b->_float;
		break;
	case OP_GT:
		c->_float = a->_float > b->_float;
		break;
	case OP_LT:
		c->_float = a->_float < b->_float;
		break;
	case OP_AND:
		c->_float = a->_float && b->_float;
		break;
	case OP_OR:
		c->_float = a->_float || b->_float;
		break;
	case OP_EQ_F:
		c->_float = a->_float == b->_float;
		break;
	case OP_EQ_V:
		c->_float = (a->vector[0] == b->vector[0]) &&
					(a->vector[1] == b->vector[1]) &&
					(a->vector[2] == b->vector[2]);
		break;
	case OP_NE_F:
		c->_float = a->_float != b->_float;
		break;
	case OP_NE_V:
		c->_float = (a->vector[0] != b->vector[0]) ||
					(a->vector[1] != b->vector[1]) ||
					(a->vector[2] != b->vector[2]);
		break;
	default:
		return false;
	}

	return true;
}


/*
==============
PR_Expression
==============
*/
def_t *PR_Expression (int priority)
{
	opcode_t	*op, *oldop;
	def_t		*e, *e2;
	etype_t		type_a, type_b, type_c;

	if (priority == 0)
		return PR_Term ();

	e = PR_Expression (priority-1);

	while (1)
	{
		if (priority == 1 && PR_Check ("(") )
			return PR_ParseFunctionCall (e);

		for (op=pr_opcodes ; op->name ; op++)
		{
			if (op->priority != priority)
				continue;
			if (!PR_Check (op->name))
				continue;

			if (op->name[0] == '.')
			{
				char *name = PR_ParseName ();

				if (e->type != &type_entity)
					PR_ParseError ("left of '.%s' must have entity type", name);

				e2 = PR_FindDef (name, pr_scope);
				if (!e2 || e2->type->type != ev_field)
					PR_ParseError ("'%s' is not a field", name);

				type_c = e2->type->aux_type->type;

				// we still allow ".void foo" so need to check
				if (type_c == ev_void)
					PR_ParseError ("tried to access a 'void' field");

				assert (type_c != ev_pointer && type_c != ev_void);
				while (type_c != op->type_c) {
					op++;
					assert (op->name);
				}

				e = PR_Statement (op, e, e2);

				// field access gets type from field
				e->type = e2->type->aux_type;
				break;
			}

			if (op->right_associative)
			{
				if (e->type->constant)
					PR_ParseError ("assignment to constant");

			// if last statement is an indirect, change it to an address of
				if ( (unsigned)(statements[numstatements-1].op - OP_LOAD_F) < 6 )
				{
					statements[numstatements-1].op = (unsigned short)OP_ADDRESS;
					def_pointer.type->aux_type = e->type;
					e->type = def_pointer.type;
				}
				e2 = PR_Expression (priority);
			}
			else
				e2 = PR_Expression (priority-1);

		// type check
			type_a = e->type->type;
			type_b = e2->type->type;

			oldop = op;
			while (type_a != op->type_a || type_b != op->type_b )
			{
				op++;
				if (!op->name || strcmp (op->name , oldop->name))
					PR_ParseError ("type mismatch for %s", oldop->name);
			}

			if (type_a == ev_pointer && type_b != e->type->aux_type->type)
				PR_ParseError ("type mismatch for %s", op->name);

#if 0
			if (e->type->constant && e2->type->constant) {
				// try to calculate the expression at compile time
				eval_t result;
				if (PR_Calc(op - pr_opcodes, (eval_t *)(pr_globals + e->ofs),
						(eval_t *)(pr_globals + e2->ofs), &result))
				{
//					printf ("line %i: folding %s %s %s into %s\n", pr_source_line, e->name, op->name, e2->name,
//						PR_ValueString(op->type_c, &val));

					type_t *resulttype;
					switch (op->type_c) {
						case ev_float: resulttype = &type_const_float; break;
						//case ev_string: resulttype = &type_const_string; break;
						case ev_vector: resulttype = &type_const_vector; break;
						default: assert (false);
					}

					e = PR_GetImmediate (resulttype, result);
					break;
				}
			}
#endif

			if (op->right_associative)
				e = PR_Statement (op, e2, e);
			else
				e = PR_Statement (op, e, e2);

			break;
		}
		if (!op->name)
			break;	// next token isn't at this priority level
	}

	return e;
}


/*
============
PR_ParseStatement

============
*/
void PR_ParseStatement (void)
{
	def_t			*e		= NULL;
	dstatement_t	*patch1	= NULL;
	dstatement_t	*patch2	= NULL;

	if (PR_Check(";"))
		return;

	if (PR_Check ("{"))
	{
		while (!PR_Check ("}"))
			PR_ParseStatement ();
		return;
	}

	if (PR_Check("return"))
	{
		if (PR_Check (";"))
		{
			PR_Statement (&pr_opcodes[OP_RETURN], 0, 0);
			return;
		}
		e = PR_Expression (TOP_PRIORITY);
		PR_Expect (";");
		PR_Statement (&pr_opcodes[OP_RETURN], e, 0);
		return;
	}

	if (PR_Check("while"))
	{
		PR_Expect ("(");
		patch2 = &statements[numstatements];
		e = PR_Expression (TOP_PRIORITY);
		PR_Expect (")");
		patch1 = &statements[numstatements];
		PR_Statement (&pr_opcodes[OP_IFNOT], e, 0);
		PR_ParseStatement ();
		junkdef.ofs = patch2 - &statements[numstatements];
		PR_Statement (&pr_opcodes[OP_GOTO], &junkdef, 0);
		patch1->b = (unsigned short)(&statements[numstatements] - patch1);
		return;
	}

	if (PR_Check("do"))
	{
		patch1 = &statements[numstatements];
		PR_ParseStatement ();
		PR_Expect ("while");
		PR_Expect ("(");
		e = PR_Expression (TOP_PRIORITY);
		PR_Expect (")");
		PR_Expect (";");
		junkdef.ofs = patch1 - &statements[numstatements];
		PR_Statement (&pr_opcodes[OP_IF], e, &junkdef);
		return;
	}

	if ( PR_Check("local") || !strcmp(pr_token, "const") || !strcmp(pr_token, "float") || !strcmp(pr_token, "vector")
		|| !strcmp(pr_token, "entity") || !strcmp(pr_token, "string") || !strcmp(pr_token, "void"))
	{
		PR_ParseDefs ();
		locals_end = numpr_globals;
		return;
	}

	if (PR_Check("if"))
	{
		PR_Expect ("(");
		e = PR_Expression (TOP_PRIORITY);
		PR_Expect (")");

		patch1 = &statements[numstatements];
		PR_Statement (&pr_opcodes[OP_IFNOT], e, 0);

		PR_ParseStatement ();

		if (PR_Check ("else"))
		{
			patch2 = &statements[numstatements];
			PR_Statement (&pr_opcodes[OP_GOTO], 0, 0);
			patch1->b = (unsigned short)(&statements[numstatements] - patch1);
			PR_ParseStatement ();
			patch2->a = (unsigned short)(&statements[numstatements] - patch2);
		}
		else
			patch1->b = (unsigned short)(&statements[numstatements] - patch1);

		return;
	}

	if (PR_Check("else"))
		PR_ParseError ("illegal else without matching if");

	PR_Expression (TOP_PRIORITY);
	PR_Expect (";");
}


/*
==============
PR_ParseState

States are special functions made for convenience.  They automatically
set frame, nextthink (implicitly), and think (allowing forward definitions).

// void() name = [framenum, nextthink] {code}
// expands to:
// function void name ()
// {
//		self.frame=framenum;
//		self.nextthink = time + 0.1;
//		self.think = nextthink
//		<code>
// };
==============
*/
void PR_ParseState (void)
{
	char	*name;
	def_t	*s1, *def;

	if (pr_token_type != tt_immediate || pr_immediate_type != &type_const_float)
		PR_ParseError ("state frame must be a number");
	s1 = PR_ParseImmediate ();

	PR_Expect (",");

	name = PR_ParseName ();
	def = PR_GetDef (&type_function, name, NULL, NULL);

	PR_Expect ("]");

	PR_Statement (&pr_opcodes[OP_STATE], s1, def);
}


/*
============
PR_ParseImmediateStatements

Parse a function body
============
*/
function_t *PR_ParseImmediateStatements (type_t *type)
{
	int			i;
	function_t	*f;
	def_t		*defs[MAX_PARMS];

	f = (function_t *) malloc (sizeof(function_t));

//
// check for builtin function definition #1, #2, etc
//
	if (PR_Check ("#"))
	{
		if (pr_token_type != tt_immediate
		|| pr_immediate_type != &type_const_float
		|| pr_immediate._float != (int)pr_immediate._float)
			PR_ParseError ("bad builtin immediate");
		f->builtin = (int)pr_immediate._float;
		PR_Lex ();
		return f;
	}

	f->builtin = 0;
//
// define the parms
//
	for (i = 0; i < (type->num_parms & VA_MASK); i++)
	{
		defs[i] = PR_GetDef (type->parm_types[i], pr_parm_names[i], pr_scope, pr_scope, true);
		f->parm_ofs[i] = defs[i]->ofs;
		if (i > 0 && f->parm_ofs[i] < f->parm_ofs[i-1])
			Error ("bad parm order");
	}

	f->code = numstatements;

//
// check for a state opcode
//
	if (PR_Check ("["))
		PR_ParseState ();

//
// parse regular statements
//
	PR_Expect ("{");

	while (!PR_Check("}"))
		PR_ParseStatement ();

// emit an end of statements opcode
	PR_Statement (pr_opcodes, 0,0);


	return f;
}


/*
============
PR_FindDef

Returns NULL if no matching def is found
============
*/
def_t *PR_FindDef (char *name, def_t *scope)
{
	int	hash = Com_HashKey (name);

	if (scope) {
		// search local defs first
		for (def_t *def = pr.def_hash_head[hash].hash_next ; def ; def = def->hash_next) {
			if (def->visscope != scope)
				continue;		// in a different function, or global

			if (strcmp(def->name, name))
				continue;

			// found it
			return def;
		}
	}

	// search global defs
	for (def_t *def = pr.def_hash_head[hash].hash_next ; def ; def = def->hash_next) {
		if (def->visscope)
			continue;		// a local def

		if (strcmp(def->name, name))
			continue;

		// found it
		return def;
	}

	return NULL;
}


/*
============
PR_FindDef2

Returns NULL if no matching def is found
Doesn't take scope visibility into account
============
*/
def_t *PR_FindDef2 (char *name, def_t *scope, int hash)
{
	assert ((unsigned int)hash < (unsigned int)HASH_SIZE);

	if (scope) {
		// search local defs first
		for (def_t *def = pr.def_hash_head[hash].hash_next ; def ; def = def->hash_next) {
			if (def->scope != scope)
				continue;		// in a different function, or global

			if (strcmp(def->name, name))
				continue;

			// found it
			return def;
		}
	}

	// search global defs
	for (def_t *def = pr.def_hash_head[hash].hash_next ; def ; def = def->hash_next) {
		if (def->scope)
			continue;		// a local def

		if (strcmp(def->name, name))
			continue;

		// found it
		return def;
	}

	return NULL;
}


/*
============
PR_GetDef

A new def will be allocated if it can't be found
============
*/
def_t *PR_GetDef (type_t *type, char *name, def_t *scope, def_t *visscope, bool isParm)
{
	def_t	*def;
	char	element[MAX_NAME];
	int		hash;

	hash = Com_HashKey (name);

// see if the name is already in use
	def = PR_FindDef2 (name, scope, hash);

	if (def) {
		if (def->scope != scope) {
			if (!opt_idcomp)
				goto allocNew;		// a local def overrides global (ok)
			else
				PR_Warning (WARN_HIGH, "'%s' already declared on global scope", name);
		}

		if (def->type != type)
			PR_ParseError ("type mismatch on redeclaration of %s", name);

		if (def->isParm && !isParm)
			if (!opt_idcomp)
				PR_ParseError ("redefinition of formal parameter '%s'", name);
			else
				PR_Warning (WARN_HIGH, "redefinition of formal parameter '%s'", name);

		// fixup visibility scope
		if (def->visscope)
			def->visscope = visscope;

		return def;
	}

// allocate a new def
allocNew:
	def = PR_NewDef (hash);

	def->name = (char *) malloc (strlen(name)+1);
	strcpy (def->name, name);
	def->type = type;
	def->isParm = isParm;
	def->scope = scope;
	def->visscope = visscope;

	if (numpr_globals + type_size[type->type] > MAX_REGS)
		Error ("numpr_globals > MAX_REGS");

	def->ofs = numpr_globals;
	pr_global_defs[numpr_globals] = def;

//
// make automatic defs for the vectors elements
// .origin can be accessed as .origin_x, .origin_y, and .origin_z
//
	if (type->type == ev_vector)
	{
		sprintf (element, "%s_x",name);
		PR_GetDef (&type_float, element, scope, visscope, isParm);

		sprintf (element, "%s_y",name);
		PR_GetDef (&type_float, element, scope, visscope, isParm);

		sprintf (element, "%s_z",name);
		PR_GetDef (&type_float, element, scope, visscope, isParm);
	}
	else
		numpr_globals += type_size[type->type];

	if (type->type == ev_field)
	{
		assert (scope == NULL && visscope == NULL);

		*(int *)&pr_globals[def->ofs] = pr.size_fields;

		if (type->aux_type->type == ev_vector)
		{
			sprintf (element, "%s_x",name);
			PR_GetDef (&type_floatfield, element, NULL, NULL, isParm);

			sprintf (element, "%s_y",name);
			PR_GetDef (&type_floatfield, element, NULL, NULL, isParm);

			sprintf (element, "%s_z",name);
			PR_GetDef (&type_floatfield, element, NULL, NULL, isParm);
		}
		else
			pr.size_fields += type_size[type->aux_type->type];
	}

	if (opt_dumpasm)
		PR_PrintOfs (def->ofs);

	return def;
}


/*
================
PR_ParseFunctionBody
================
*/
void PR_ParseFunctionBody (type_t *type, char *name, def_t *def)
{
	function_t	*f;
	dfunction_t	*df;
	int			locals_start;

	if (pr_scope)
		PR_ParseError ("'%s': local function definitions are illegal", name);

	if (def->initialized)
		PR_ParseError ("function '%s' already has a body", name);

	locals_start = locals_end = numpr_globals;
	pr_scope = def;
	f = PR_ParseImmediateStatements (type);
	pr_scope = NULL;
	def->initialized = 1;
	G_FUNCTION(def->ofs) = numfunctions;
	f->def = def;

//	if (opt_dumpasm)
//		PR_PrintFunction (def);

// fill in the dfunction
	df = &functions[numfunctions];
	numfunctions++;
	if (f->builtin)
		df->first_statement = -f->builtin;
	else
		df->first_statement = f->code;
	df->s_name = CopyString (f->def->name);
	df->s_file = s_file;
	// id's qcc would set numparms to -1 for varargs functions
	// but non-builtin varargs functions don't make sense anyway so don't bother checking
	df->numparms = f->def->type->num_parms & VA_MASK;
	df->locals = locals_end - locals_start;
	df->parm_start = locals_start;
	for (int i=0 ; i<df->numparms ; i++)
		df->parm_size[i] = type_size[f->def->type->parm_types[i]->type];
}


/*
================
PR_ParseInitialization

"<type> <name> = " was parsed, parse the rest
================
*/
void PR_ParseInitialization (type_t *type, char *name, def_t *def)
{
	if (def->initialized)
		PR_ParseError ("%s redeclared", name);

	if (pr_token_type != tt_immediate && pr_token_type != tt_name)
		PR_ParseError ("syntax error : '%s'", pr_token);

	if (pr_token_type == tt_name) {
		PR_ParseError ("initializer is not a constant");
	}

	if (!CompareType(pr_immediate_type, type))
		PR_ParseError ("wrong immediate type for %s", name);

	def->initialized = 1;
	if (type == &type_const_string || type == &type_string)
		pr_immediate.string = CopyString (pr_immediate_string);
	memcpy (pr_globals + def->ofs, &pr_immediate, 4*type_size[pr_immediate_type->type]);
	PR_Lex ();
}


/*
================
PR_ParseDefs

Called at the outer layer and when a local statement is hit
================
*/
void PR_ParseDefs (void)
{
	type_t *type = PR_ParseType ();

	if (pr_scope && type->type == ev_field)
		PR_ParseError ("'%s': local field definitions are illegal", pr_token);

	int	c_defs = 0;
	bool qc_style_function_def = false;

	// functions are always global
	def_t *defscope = (type->type == ev_function) ? NULL : pr_scope;

	do
	{
		char *name = PR_ParseName ();

		if (type->type != ev_function && PR_Check("(")) {
			// C-style function declaration

			char functionName[MAX_NAME];

			if (strlen(name) >= (size_t)MAX_NAME)
				PR_ParseError ("name of function \"%s\" is too long (max. %d chars)", name, (int)(MAX_NAME - 1));

			strcpy (functionName, name);

			type_t *functionType = PR_ParseFunctionType (type);

			def_t *def = PR_GetDef (functionType, functionName, NULL, pr_scope);

			if ((!c_defs && !strcmp(pr_token, "{")) || PR_Check("=")) {
				// C-style function definition (including builtin function definition #1, #2, etc.)
				PR_ParseFunctionBody (functionType, functionName, def);
				while (PR_Check(";"))
					;	// skip redundant semicolons
				return;
			}

			continue;
		}

		def_t *def = PR_GetDef (type, name, defscope, pr_scope);

		if (type->type == ev_void) {
			// end_sys_globals and end_sys_fields are special flags for structure dumping
			if (strcmp(name, "end_sys_globals") && strcmp(name, "end_sys_fields"))
				PR_ParseError ("'%s' : illegal use of type 'void'", name);
		}

		// check for an initialization
		if (PR_Check("=")) {
			if (type->type == ev_function) {
				// QuakeC-style function definition
				qc_style_function_def = true;
				PR_ParseFunctionBody (type, name, def);
			}
			else
				// variable initialization
				PR_ParseInitialization (type, name, def);
		}

	} while (c_defs++, PR_Check (","));

	if (qc_style_function_def && c_defs == 1)
		;	// allow void() func = {} without semicolon
	else
		PR_Expect (";");

	while (PR_Check(";"))
		;	// skip redundant semicolons
}


/*
============
PR_CompileFile

compiles the 0 terminated text, adding defintions to the pr structure
============
*/
bool PR_CompileFile (char *string, char *filename)
{
	if (!pr.memory)
		Error ("PR_CompileFile: Didn't clear");

	PR_ClearGrabMacros ();	// clear the frame macros

	pr_file_p = string;
	s_file = CopyString (filename);

	pr_source_line = 0;

	PR_NewLine ();

	PR_Lex ();	// read first token

	while (PR_Check(";"))
		;	// skip redundant semicolons

	while (pr_token_type != tt_eof)
	{
		if (setjmp(pr_parse_abort))
		{
			if (++pr_error_count > MAX_ERRORS)
				return false;
			PR_SkipToSemicolon ();
			if (pr_token_type == tt_eof)
				return false;
		}

		pr_scope = NULL;	// outside all functions

		PR_ParseDefs ();
	}

	return (pr_error_count == 0);
}
