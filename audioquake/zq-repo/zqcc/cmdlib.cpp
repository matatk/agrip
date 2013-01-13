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
// cmdlib.c

#include "cmdlib.h"
#include <time.h>
#ifdef _WIN32
#include <io.h>
#include <fcntl.h>
#else
#include <unistd.h>
#endif

// set these before calling CheckParm
int myargc;
char **myargv;

char	com_token[1024];
int		com_eof;

/*
==============
COM_Parse

Parse a token out of a string
==============
*/
char *COM_Parse (char *data)
{
	int		c;
	int		len;
	
	len = 0;
	com_token[0] = 0;
	
	if (!data)
		return NULL;
		
// skip whitespace
skipwhite:
	while ( (c = *data) <= ' ')
	{
		if (c == 0)
		{
			com_eof = true;
			return NULL;			// end of file;
		}
		data++;
	}
	
// skip // comments
	if (c=='/' && data[1] == '/')
	{
		while (*data && *data != '\n')
			data++;
		goto skipwhite;
	}
	

// handle quoted strings specially
	if (c == '\"')
	{
		data++;
		do
		{
			c = *data++;
			if (c=='\"')
			{
				com_token[len] = 0;
				return data;
			}
			com_token[len] = c;
			len++;
		} while (1);
	}

// parse single characters
	if (c=='{' || c=='}'|| c==')'|| c=='(' || c=='\'' || c==':')
	{
		com_token[len] = c;
		len++;
		com_token[len] = 0;
		return data+1;
	}

// parse a regular word
	do
	{
		com_token[len] = c;
		data++;
		len++;
		c = *data;
	if (c=='{' || c=='}'|| c==')'|| c=='(' || c=='\'' || c==':')
			break;
	} while (c>32);
	
	com_token[len] = 0;
	return data;
}




char *strupr (char *start)
{
	char	*in;
	in = start;
	while (*in)
	{
		*in = toupper(*in);
		in++;
	}
	return start;
}

char *strlower (char *start)
{
	char	*in;
	in = start;
	while (*in)
	{
		*in = tolower(*in);
		in++;
	}
	return start;
}




/*
=============================================================================

						MISC FUNCTIONS

=============================================================================
*/

/*
=================
Error

For abnormal program terminations
=================
*/
void Error (char *error, ...)
{
	va_list argptr;

	printf ("\n************ ERROR ************\n");

	va_start (argptr, error);
	vprintf (error, argptr);
	va_end (argptr);
	printf ("\n");
	exit (1);
}


/*
=================
CheckParm

Checks for the given parameter in the program's command line arguments
  starting with startarg (or with first argument if <= 0)
Returns the argument number (1 to argc-1) or 0 if not present.
if option is true, it removes leading '/' and '-' before testing.
it checks the beginning of the argument strings, therefore
  the argument "/help" matches the checkstring "/h"
=================
*/
int			 CheckParm (char *check, int startarg, qboolean optioncheck, qboolean casesensitive)
{
	int		 i, j;

	if (startarg <= 0)
		startarg = 1;

	for (i = startarg;i < myargc; i++)
	{
		/* were looking for an option and remove all leading '-' or '/' will be removed */
		j = 0;
		while ( optioncheck && j < (int)strlen(myargv[i]) && (myargv[i][j] == '-' || myargv[i][j] == '/') )
			j++;

		if (casesensitive)
		{
			if ( !strncmp(myargv[i] + j, check, strlen(check)) )
				return i;
		}
		else
		{
			if ( !Q_strnicmp(myargv[i] + j, check, strlen(check)) )
				return i;
		}
	}

	return 0;
}


FILE *SafeOpenWrite (const char *filename)
{
	FILE *f;

	f = fopen (filename, "wb");

	if (!f)
		Error ("Error opening %s for writing: %s", filename, strerror(errno));

	return f;
}

FILE *SafeOpenRead (const char *filename)
{
	FILE *f;

	f = fopen (filename, "rb");

	if (!f)
		Error ("Error opening %s for reading: %s", filename, strerror(errno));

	return f;
}


void SafeRead (FILE *f, void *buffer, long count)
{
	if (fread(buffer, count, 1, f) != 1)
		Error ("File read failure: %s", strerror(errno));
}


void SafeWrite (FILE *f, const void *buffer, long count)
{
	if (fwrite(buffer, count, 1, f) != 1)
		Error ("File write failure: %s", strerror(errno));
}


void *SafeMalloc (long size)
{
	void *ptr;

	ptr = malloc (size);

	if (!ptr)
		Error ("Malloc failure for %lu bytes: %s", (unsigned long)size, strerror(errno));

	return ptr;
}


/*
==============
LoadFile
==============
*/
long LoadFile (char *filename, void **bufferptr)
{
	FILE	*f;;
	long    length;
	void    *buffer;

	f = SafeOpenRead (filename);

	fseek (f, 0, SEEK_END);
	length = ftell(f);
	fseek (f, 0, SEEK_SET);
	buffer = SafeMalloc (length+1);
	((byte *)buffer)[length] = 0;
	SafeRead (f, buffer, length);
	fclose (f);

	*bufferptr = buffer;
	return length;
}


/*
==============
SaveFile
==============
*/
void SaveFile (char *filename, const void *buffer, long count)
{
	FILE	*f;

	f = SafeOpenWrite (filename);
	SafeWrite (f, buffer, count);
	fclose (f);
}



void DefaultExtension (char *path, char *extension)
{
	char    *src;

	//
	// if path doesn't have a .EXT, append extension
	// (extension should include the .)
	//
	src = path + strlen(path) - 1;

	while (*src != PATHSEPARATOR && src != path)
	{
		if (*src == '.')
			return;                 // it has an extension
		src--;
	}

	strcat (path, extension);
}


void DefaultPath (char *path, char *basepath)
{
	char    temp[128];

	if (path[0] == PATHSEPARATOR)
		return;                   // absolute path location
	strlcpy (temp, path, sizeof(temp) - 1);
	strcpy (path, basepath);
	strcat (path, temp);
}


void StripFilename (char *path)
{
	int             length;

	length = strlen(path)-1;
	while (length > 0 && path[length] != PATHSEPARATOR)
		length--;
	path[length] = 0;
}

void StripExtension (char *path)
{
	int             length;

	length = strlen(path)-1;
	while (length > 0 && path[length] != '.')
	{
		length--;
		if (path[length] == '/')
			return;		// no extension
	}
	if (length)
		path[length] = 0;
}


/*
====================
Extract file parts
====================
*/
void ExtractFilePath (const char *path, char *dest, size_t max_size)
{
	const char *src;
	size_t      siz;

	src = path + strlen(path) - 1;

//
// back up until a \ or the start
//
	if (*src != PATHSEPARATOR)
	{
		while (src != path && *(src-1) != PATHSEPARATOR)
			src--;
	}

	siz = (size_t)(src - path);
	if ( (size_t)(src - path) > max_size )
		siz = max_size;

	memcpy (dest, path, siz);
	dest[siz] = 0;
}

void ExtractFileName (const char *path, char *dest, size_t max_size)
{
	const char *src;

	src = path + strlen(path) - 1;

//
// back up until a \ or the start
//
	while (src != path && *(src-1) != PATHSEPARATOR)
		src--;

	memcpy (dest, src, max_size);
	dest[max_size] = 0;
}

void ExtractFileBase (const char *path, char *dest, size_t max_size)
{
	char *src;

	ExtractFileName (path, dest, max_size);

	src = dest + strlen(dest) - 1;

//
// search for a . in the name:
//
	while (src != dest && *src != '.')
		src--;

	if (*src == '.')
		*src = 0;
}

void ExtractFileExtension (const char *path, char *dest, size_t max_size)
{
	const char *src;

	src = path + strlen(path) - 1;

//
// back up until a . or the start
//
	while (src != path && *(src-1) != '.')
		src--;
	if (src == path)
	{
		*dest = 0;	// no extension
		return;
	}

	strlcpy (dest, src, max_size);
}


/*
==============
ParseNum / ParseHex
==============
*/
long ParseHex (char *hex)
{
	char    *str;
	long    num;

	num = 0;
	str = hex;

	while (*str)
	{
		int  c = (int)(unsigned char)*str;

		num <<= 4;
		if ( isdigit(c) )
			num += c - (int)'0';
		else if ( isxdigit(c) )
			num += 10 + tolower(c) - (int)'a';
		else
			Error ("Bad hex number: %s", hex);
		str++;
	}

	return num;
}


long ParseNum (char *str)
{
	if (str[0] == '$')
		return ParseHex (str+1);
	if (str[0] == '0' && str[1] == 'x')
		return ParseHex (str+2);
	return atol (str);
}


/*
** Com_HashKey
*/
int Com_HashKey (const char *name)
{
	int	v;
	unsigned char c;

	v = 0;
	while ( (c = *name++) != 0 )
		v += c;

	return (unsigned int)v % HASH_SIZE;
}

#ifndef HAVE_STRLCPY
size_t strlcpy (char *dst, const char *src, size_t size)
{
	size_t len = strlen (src);

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
	size_t dstlen = strlen(dst);
	size_t srclen = strlen(src);
	size_t len = dstlen + srclen;

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


/*
============================================================================

					BYTE ORDER FUNCTIONS

============================================================================
*/

#ifdef __BIG_ENDIAN__

short   LittleShort (short l)
{
	byte    b1,b2;

	b1 = l&255;
	b2 = (l>>8)&255;

	return (b1<<8) + b2;
}

short   BigShort (short l)
{
	return l;
}


long    LittleLong (long l)
{
	byte    b1,b2,b3,b4;

	b1 = l&255;
	b2 = (l>>8)&255;
	b3 = (l>>16)&255;
	b4 = (l>>24)&255;

	return ((long)b1<<24) + ((long)b2<<16) + ((long)b3<<8) + b4;
}

long    BigLong (long l)
{
	return l;
}


float	LittleFloat (float l)
{
	union {byte b[4]; float f;} in, out;
	
	in.f = l;
	out.b[0] = in.b[3];
	out.b[1] = in.b[2];
	out.b[2] = in.b[1];
	out.b[3] = in.b[0];
	
	return out.f;
}

float	BigFloat (float l)
{
	return l;
}


#else


short   BigShort (short l)
{
	byte    b1,b2;

	b1 = l&255;
	b2 = (l>>8)&255;

	return (b1<<8) + b2;
}

short   LittleShort (short l)
{
	return l;
}


long    BigLong (long l)
{
	byte    b1,b2,b3,b4;

	b1 = l&255;
	b2 = (l>>8)&255;
	b3 = (l>>16)&255;
	b4 = (l>>24)&255;

	return ((long)b1<<24) + ((long)b2<<16) + ((long)b3<<8) + b4;
}

long    LittleLong (long l)
{
	return l;
}

float	BigFloat (float l)
{
	union {byte b[4]; float f;} in, out;
	
	in.f = l;
	out.b[0] = in.b[3];
	out.b[1] = in.b[2];
	out.b[2] = in.b[1];
	out.b[3] = in.b[0];
	
	return out.f;
}

float	LittleFloat (float l)
{
	return l;
}



#endif
