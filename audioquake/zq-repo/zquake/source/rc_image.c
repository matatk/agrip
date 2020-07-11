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
#include "rc_image.h"

/*
=========================================================

TARGA LOADING

=========================================================
*/

typedef struct _TargaHeader {
	unsigned char 	id_length, colormap_type, image_type;
	unsigned short	colormap_index, colormap_length;
	unsigned char	colormap_size;
	unsigned short	x_origin, y_origin, width, height;
	unsigned char	pixel_size, attributes;
} TargaHeader;

/*
=============
LoadTGA
=============
*/
void LoadTGA (char *filename, byte **out, int *width, int *height)
{
	int		columns, rows, numPixels;
	byte	*pixbuf, *tgabuf;
	int		row, column;
	TargaHeader targa_header;

	*out = NULL;
	tgabuf = FS_LoadTempFile (filename);
	if (!tgabuf)
	{
		Com_DPrintf ("LoadTGA: Could not open %s\n", filename);
		return;
	}

	targa_header.id_length = *(byte *)tgabuf++;
	targa_header.colormap_type = *(byte *)tgabuf++;
	targa_header.image_type = *(byte *)tgabuf++;

	targa_header.colormap_index = LittleShort (*(short *)tgabuf); tgabuf += 2;
	targa_header.colormap_length = LittleShort (*(short *)tgabuf); tgabuf += 2;
	targa_header.colormap_size = *(byte *)tgabuf++;
	targa_header.x_origin = LittleShort (*(short *)tgabuf); tgabuf += 2;
	targa_header.y_origin = LittleShort (*(short *)tgabuf); tgabuf += 2;
	targa_header.width = LittleShort (*(short *)tgabuf); tgabuf += 2;
	targa_header.height = LittleShort (*(short *)tgabuf); tgabuf += 2;
	targa_header.pixel_size = *(byte *)tgabuf++;
	targa_header.attributes = *(byte *)tgabuf++;

	if (targa_header.image_type != 2 && targa_header.image_type != 10)
	{
		Com_DPrintf ("LoadTGA: Only type 2 and 10 targa RGB images supported\n");
		return;
	}

	if (targa_header.colormap_type != 0 || (targa_header.pixel_size != 32 && targa_header.pixel_size != 24))
	{
		Com_DPrintf ("LoadTGA: Only 32 or 24 bit images supported (no colormaps)\n");
		return;
	}

	columns = targa_header.width;
	rows = targa_header.height;
	numPixels = columns * rows;

	if (width)
		*width = columns;
	if (height)
		*height = rows;

	*out = Q_malloc (numPixels*4 + 128000 /* !!!!TESTING */);

	if (targa_header.id_length != 0)
		tgabuf += targa_header.id_length;

	if (targa_header.image_type==2) {  // Uncompressed, RGB images
		for (row = rows - 1; row >= 0; row--) {
			pixbuf = *out + ((targa_header.attributes & 0x20) ? rows-1-row : row) * columns * 4;
			for(column=0; column<columns; column++) {
				unsigned char red,green,blue,alphabyte;
				switch (targa_header.pixel_size) {
					case 24:
						
							blue = *(byte *)tgabuf++;
							green = *(byte *)tgabuf++;
							red = *(byte *)tgabuf++;
							*pixbuf++ = red;
							*pixbuf++ = green;
							*pixbuf++ = blue;
							*pixbuf++ = 255;
							break;
					case 32:
							blue = *(byte *)tgabuf++;
							green = *(byte *)tgabuf++;
							red = *(byte *)tgabuf++;
							alphabyte = *(byte *)tgabuf++;
							*pixbuf++ = red;
							*pixbuf++ = green;
							*pixbuf++ = blue;
							*pixbuf++ = alphabyte;
							break;
				}
			}
		}
	}
	else if (targa_header.image_type==10) {   // Runlength encoded RGB images
		unsigned char red = 0,green = 0,blue = 0,alphabyte = 0,packetHeader = 0,packetSize = 0,j = 0;
		for (row = rows - 1; row >= 0; row--) {
			pixbuf = *out + ((targa_header.attributes & 0x20) ? rows-1-row : row) * columns * 4;
			for(column=0; column<columns; ) {
				packetHeader = *(byte *)tgabuf++;
				packetSize = 1 + (packetHeader & 0x7f);
				if (packetHeader & 0x80) {        // run-length packet
					switch (targa_header.pixel_size) {
						case 24:
								blue = *(byte *)tgabuf++;
								green = *(byte *)tgabuf++;
								red = *(byte *)tgabuf++;
								alphabyte = 255;
								break;
						case 32:
								blue = *(byte *)tgabuf++;
								green = *(byte *)tgabuf++;
								red = *(byte *)tgabuf++;
								alphabyte = *(byte *)tgabuf++;
								break;
					}

					for(j=0;j<packetSize;j++) {
						*pixbuf++=red;
						*pixbuf++=green;
						*pixbuf++=blue;
						*pixbuf++=alphabyte;
						column++;
						if (column==columns) { // run spans across rows
							column=0;
							if (row>0)
								row--;
							else
								goto breakOut;
							pixbuf = *out + row*columns*4;
						}
					}
				}
				else {                            // non run-length packet
					for(j=0;j<packetSize;j++) {
						switch (targa_header.pixel_size) {
							case 24:
									blue = *(byte *)tgabuf++;
									green = *(byte *)tgabuf++;
									red = *(byte *)tgabuf++;
									*pixbuf++ = red;
									*pixbuf++ = green;
									*pixbuf++ = blue;
									*pixbuf++ = 255;
									break;
							case 32:
									blue = *(byte *)tgabuf++;
									green = *(byte *)tgabuf++;
									red = *(byte *)tgabuf++;
									alphabyte = *(byte *)tgabuf++;
									*pixbuf++ = red;
									*pixbuf++ = green;
									*pixbuf++ = blue;
									*pixbuf++ = alphabyte;
									break;
						}
						column++;
						if (column==columns) { // pixel packet run spans across rows
							column=0;
							if (row>0)
								row--;
							else
								goto breakOut;
							pixbuf = *out + row*columns*4;
						}
					}
				}
			}
			breakOut:;
		}
	}
}

/*
=================================================================

  PCX Loading

=================================================================
*/

typedef struct
{
    char	manufacturer;
    char	version;
    char	encoding;
    char	bits_per_pixel;
    unsigned short	xmin,ymin,xmax,ymax;
    unsigned short	hres,vres;
    unsigned char	palette[48];
    char	reserved;
    char	color_planes;
    unsigned short	bytes_per_line;
    unsigned short	palette_type;
    char	filler[58];
    unsigned char	data;			// unbounded
} pcx_t;

/*
============
LoadPCX
============
*/
void LoadPCX (char *filename, byte **pic, int *width, int *height)
{
	pcx_t	*pcx;
	byte	*pcxbuf, *out, *pix;
	int		x, y;
	int		dataByte, runLength;

	*pic = NULL;
	pcxbuf = FS_LoadTempFile (filename);
	if (!pcxbuf)
	{
		Com_DPrintf ("LoadPCX: Could not open %s\n", filename);
		return;
	}

//
// parse the PCX file
//
	pcx = (pcx_t *)pcxbuf;
	pcx->xmax = LittleShort (pcx->xmax);
	pcx->xmin = LittleShort (pcx->xmin);
	pcx->ymax = LittleShort (pcx->ymax);
	pcx->ymin = LittleShort (pcx->ymin);
	pcx->hres = LittleShort (pcx->hres);
	pcx->vres = LittleShort (pcx->vres);
	pcx->bytes_per_line = LittleShort (pcx->bytes_per_line);
	pcx->palette_type = LittleShort (pcx->palette_type);

	pix = &pcx->data;

	if (pcx->manufacturer != 0x0a
		|| pcx->version != 5
		|| pcx->encoding != 1
		|| pcx->bits_per_pixel != 8
		|| pcx->xmax >= 640
		|| pcx->ymax >= 480)
	{
		Com_DPrintf ("LoadPCX: Bad pcx file %s\n", filename);
		return;
	}

	if (width)
		*width = pcx->xmax+1;
	if (height)
		*height = pcx->ymax+1;

	*pic = out = Q_malloc ((pcx->xmax+1) * (pcx->ymax+1));

	for (y=0 ; y<=pcx->ymax ; y++, out += pcx->xmax+1)
	{
		for (x=0 ; x<=pcx->xmax ; )
		{
			if (pix - (byte *)pcx > fs_filesize)
			{
				Q_free (*pic);
				*pic = NULL;
				Com_DPrintf ("LoadPCX: %s is malformed\n", filename);
				return;
			}

			dataByte = *pix++;

			if((dataByte & 0xC0) == 0xC0)
			{
				runLength = dataByte & 0x3F;
				if (pix - (byte *)pcx > fs_filesize)
				{
					Q_free (*pic);
					*pic = NULL;
					Com_DPrintf ("LoadPCX: %s is malformed\n", filename);
					return;
				}
				dataByte = *pix++;
			}
			else
				runLength = 1;

			// sanity check
			if (runLength + x > pcx->xmax + 2)
			{
				Q_free (*pic);
				*pic = NULL;
				Com_DPrintf ("LoadPCX: %s is malformed\n", filename);
				return;
			}

			while (runLength-- > 0)
				out[x++] = dataByte;
		}
	}

	if (pix - (byte *)pcx > fs_filesize)
	{
		Q_free (*pic);
		*pic = NULL;
		Com_DPrintf ("LoadPCX: %s is malformed\n", filename);
	}
}

void WritePCX (byte *data, int width, int height, int rowbytes, byte *palette,	// [in]
				byte **pcxdata, int *pcxsize)									// [out]
{
	int		i, j;
	pcx_t	*pcx;
	byte	*pack;

	assert (pcxdata != NULL);
	assert (pcxsize != NULL);

	pcx = Hunk_TempAlloc (width*height*2+1000);
	if (!pcx) {
		Com_Printf ("WritePCX: not enough memory\n");
		*pcxdata = NULL;
		*pcxsize = 0;
		return;
	}

	pcx->manufacturer = 0x0a;	// PCX id
	pcx->version = 5;			// 256 color
	pcx->encoding = 1;			// uncompressed
	pcx->bits_per_pixel = 8;	// 256 color
	pcx->xmin = 0;
	pcx->ymin = 0;
	pcx->xmax = LittleShort((short)(width-1));
	pcx->ymax = LittleShort((short)(height-1));
	pcx->hres = LittleShort((short)width);
	pcx->vres = LittleShort((short)height);
	memset (pcx->palette, 0, sizeof(pcx->palette));
	pcx->color_planes = 1;				// chunky image
	pcx->bytes_per_line = LittleShort((short)width);
	pcx->palette_type = LittleShort(2);	// not a grey scale
	memset (pcx->filler, 0, sizeof(pcx->filler));

	// pack the image
	pack = &pcx->data;

	for (i=0 ; i<height ; i++)
	{
		for (j=0 ; j<width ; j++)
		{
			if ( (*data & 0xc0) != 0xc0)
				*pack++ = *data++;
			else
			{
				*pack++ = 0xc1;
				*pack++ = *data++;
			}
		}
		data += rowbytes - width;
	}

	// write the palette
	*pack++ = 0x0c; // palette ID byte
	for (i=0 ; i<768 ; i++)
		*pack++ = *palette++;

	// fill results
	*pcxdata = (byte *) pcx;
	*pcxsize = pack - (byte *)pcx;
}

/* vi: set noet ts=4 sts=4 ai sw=4: */
