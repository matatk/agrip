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
// q_shared.c -- functions shared by all subsystems

#include "q_shared.h"

/*
============================================================================

					LIBRARY REPLACEMENT FUNCTIONS

============================================================================
*/

int Q_atoi (char *str)
{
	int		val;
	int		sign;
	int		c;
	
	if (*str == '-')
	{
		sign = -1;
		str++;
	}
	else
		sign = 1;
		
	val = 0;

//
// check for hex
//
	if (str[0] == '0' && (str[1] == 'x' || str[1] == 'X') )
	{
		str += 2;
		while (1)
		{
			c = (int)(unsigned char)*str++;
			if ( isdigit(c) )
				val = (val<<4) + c - '0';
			else if ( isxdigit(c) )
				val = (val<<4) + tolower(c) - 'a' + 10;
			else
				return val*sign;
		}
	}
	
//
// check for character
//
	if (str[0] == '\'')
	{
		return sign * str[1];
	}
	
//
// assume decimal
//
	while (1)
	{
		c = (int)(unsigned char)*str++;
		if ( !isdigit(c) )
			return val*sign;
		val = val*10 + c - '0';
	}
	
	return 0;
}


float Q_atof (char *str)
{
	double	val;
	int		sign;
	int		c;
	int		decimal, total;
	
	if (*str == '-')
	{
		sign = -1;
		str++;
	}
	else
		sign = 1;
		
	val = 0;

//
// check for hex
//
	if (str[0] == '0' && (str[1] == 'x' || str[1] == 'X') )
	{
		str += 2;
		while (1)
		{
			c = (int)(unsigned char)*str++;
			if ( isdigit(c) )
				val = (val*16) + c - '0';
			else if ( isxdigit(c) )
				val = (val*16) + tolower(c) - 'a' + 10;
			else
				return val*sign;
		}
	}
	
//
// check for character
//
	if (str[0] == '\'')
	{
		return sign * str[1];
	}
	
//
// assume decimal
//
	decimal = -1;
	total = 0;
	while (1)
	{
		c = *str++;
		if (c == '.')
		{
			decimal = total;
			continue;
		}
		if ( !isdigit(c) )
			break;
		val = val*10 + c - '0';
		total++;
	}

	if (decimal == -1)
		return val*sign;
	while (total > decimal)
	{
		val /= 10;
		total--;
	}
	
	return val*sign;
}


// removes trailing zeros
char *Q_ftos (float value)
{
	static char str[128];
	int	i;

	Q_snprintfz (str, sizeof(str), "%f", value);

	for (i=strlen(str)-1 ; i>0 && str[i]=='0' ; i--)
		str[i] = 0;
	if (str[i] == '.')
		str[i] = 0;

	return str;
}


#ifndef HAVE_STRLCPY
size_t strlcpy (char *dst, const char *src, size_t size)
{
	int len = strlen (src);

	if (len < size) {
		// it'll fit
		memcpy (dst, src, len + 1);
		return len;
	}

	if (size == 0)
		return len;

	assert (size >= 0);		// if a negative size was passed, then we're fucked

	memcpy (dst, src, size - 1);
	dst[size - 1] = 0;

	return len;
}
#endif

#ifndef HAVE_STRLCAT
size_t strlcat (char *dst, const char *src, size_t size)
{
	int dstlen = strlen(dst);
	int srclen = strlen(src);
	int len = dstlen + srclen;

	if (len < size) {
		// it'll fit
		memcpy (dst + dstlen, src, srclen + 1);
		return len;
	}

	if (dstlen >= size - 1)
		return srclen + size;

	if (size == 0)
		return srclen;

	assert (size >= 0);		// if a negative size was passed, then we're fucked

	memcpy (dst + dstlen, src, size - 1 - dstlen);
	dst[size - 1] = 0;

	return len;
}
#endif


void Q_snprintfz (char *dest, size_t size, char *fmt, ...)
{
	va_list		argptr;

	va_start (argptr, fmt);
#ifdef _WIN32
	_vsnprintf (dest, size, fmt, argptr);
#else
	vsnprintf (dest, size, fmt, argptr);
#endif
	va_end (argptr);

	dest[size-1] = 0;
}


/*
==============
Q_glob_match_after_star
==============
*/
static qbool Q_glob_match_after_star (const char *pattern, const char *text)
{
	char c, c1;
	const char *p = pattern, *t = text;

	while ((c = *p++) == '?' || c == '*') {
		if (c == '?' && *t++ == '\0')
			return false;
	}

	if (c == '\0')
		return true;

	for (c1 = ((c == '\\') ? *p : c); ; ) {
		if (tolower(*t) == c1 && Q_glob_match (p - 1, t))
			return true;
		if (*t++ == '\0')
			return false;
	}
}

/*
==============
Q_glob_match

Match a pattern against a string.
Based on Vic's Q_WildCmp, which is based on Linux glob_match.
Works like glob_match, except that sets ([]) are not supported.

A match means the entire string TEXT is used up in matching.

In the pattern string, `*' matches any sequence of characters,
`?' matches any character. Any other character in the pattern
must be matched exactly.

To suppress the special syntactic significance of any of `*?\'
and match the character exactly, precede it with a `\'.
==============
*/
qbool Q_glob_match (const char *pattern, const char *text)
{
	char c;

	while ((c = *pattern++) != '\0') {
		switch (c) {
			case '?':
				if (*text++ == '\0')
					return false;
				break;
			case '\\':
				if (tolower(*pattern++) != tolower(*text++))
					return false;
				break;
			case '*':
				return Q_glob_match_after_star(pattern, text);
			default:
				if (tolower(c) != tolower(*text++))
					return false;
		}
	}

	return (*text == '\0');
}


/*
==========
Com_HashKey
==========
*/
int Com_HashKey (char *name)
{
	int	v;
	unsigned char c;

	v = 0;
	while ( (c = *name++) != 0 )
		v += c &~ 32;	// make it case insensitive

	return v % 32;
}


/*
============================================================================

					BYTE ORDER FUNCTIONS

============================================================================
*/

short ShortSwap (short l)
{
	byte    b1,b2;

	b1 = l&255;
	b2 = (l>>8)&255;

	return (b1<<8) + b2;
}

int LongSwap (int l)
{
	byte    b1,b2,b3,b4;

	b1 = l&255;
	b2 = (l>>8)&255;
	b3 = (l>>16)&255;
	b4 = (l>>24)&255;

	return ((int)b1<<24) + ((int)b2<<16) + ((int)b3<<8) + b4;
}

float FloatSwap (float f)
{
	union
	{
		float	f;
		byte	b[4];
	} dat1, dat2;
	
	dat1.f = f;
	dat2.b[0] = dat1.b[3];
	dat2.b[1] = dat1.b[2];
	dat2.b[2] = dat1.b[1];
	dat2.b[3] = dat1.b[0];
	return dat2.f;
}

//===========================================================================

void SZ_Init (sizebuf_t *buf, byte *data, int length)
{
	memset (buf, 0, sizeof(*buf));
	buf->data = data;
	buf->maxsize = length;
}

void SZ_Clear (sizebuf_t *buf)
{
	buf->cursize = 0;
	buf->overflowed = false;
}

void *SZ_GetSpace (sizebuf_t *buf, int length)
{
	void	*data;
	
	if (buf->cursize + length > buf->maxsize)
	{
		if (!buf->allowoverflow)
			Sys_Error ("SZ_GetSpace: overflow without allowoverflow set (%d)", buf->maxsize);
		
		if (length > buf->maxsize)
			Sys_Error ("SZ_GetSpace: %i is > full buffer size", length);
			
		Sys_Printf ("SZ_GetSpace: overflow\n");	// because Com_Printf may be redirected
		SZ_Clear (buf); 
		buf->overflowed = true;
	}

	data = buf->data + buf->cursize;
	buf->cursize += length;
	
	return data;
}

void SZ_Write (sizebuf_t *buf, const void *data, int length)
{
	memcpy (SZ_GetSpace(buf,length),data,length);		
}

void SZ_Print (sizebuf_t *buf, const char *data)
{
	int		len;
	
	len = strlen(data)+1;

	if (!buf->cursize || buf->data[buf->cursize-1])
		memcpy ((byte *)SZ_GetSpace(buf, len),data,len); // no trailing 0
	else
		memcpy ((byte *)SZ_GetSpace(buf, len-1)-1,data,len); // write over trailing 0
}


//============================================================================

/*
** Q_malloc
**
** Use it instead of malloc so that if memory allocation fails,
** the program exits with a message saying there's not enough memory
** instead of crashing after trying to use a NULL pointer
*/
void *Q_malloc (size_t size)
{
	void *p = malloc(size);
	if (!p)
		Sys_Error ("Not enough memory free; check disk space");
	return p;
}

char *Q_strdup (const char *src)
{
	char *p = strdup(src);
	if (!p)
		Sys_Error ("Not enough memory free; check disk space");
	return p;
}


//============================================================================
