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
// net_wins.c

#include "common.h"
#include "winquake.h"

netadr_t	net_from;
netadr_t	net_null = {NA_NULL};
netadr_t	net_local_adr;	// FIXME: make this work!

sizebuf_t	net_message;

byte		net_message_buffer[MAX_BIG_MSGLEN];

WSADATA		winsockdata;

#define	MAX_LOOPBACK	4	// must be a power of two

typedef struct
{
	byte	data[MAX_BIG_MSGLEN];
	int		datalen;
} loopmsg_t;

typedef struct
{
	loopmsg_t	msgs[MAX_LOOPBACK];
	unsigned int	get, send;
} loopback_t;

loopback_t	loopbacks[2];
int			ip_sockets[2] = { -1, -1 };

//=============================================================================

void NetadrToSockadr (netadr_t *a, struct sockaddr_in *s)
{
	memset (s, 0, sizeof(*s));
	s->sin_family = AF_INET;

	*(int *)&s->sin_addr = *(int *)&a->ip;
	s->sin_port = a->port;
}

void SockadrToNetadr (struct sockaddr_in *s, netadr_t *a)
{
	a->type = NA_IP;
	*(int *)&a->ip = *(int *)&s->sin_addr;
	a->port = s->sin_port;
}

qbool NET_CompareBaseAdr (netadr_t a, netadr_t b)
{
	if (a.type != b.type)
		return false;
	if (a.type == NA_LOOPBACK)
		return true;
	if (a.ip[0] == b.ip[0] && a.ip[1] == b.ip[1] && a.ip[2] == b.ip[2] && a.ip[3] == b.ip[3])
		return true;
	return false;
}

qbool NET_CompareAdr (netadr_t a, netadr_t b)
{
	if (a.type != b.type)
		return false;
	if (a.type == NA_LOOPBACK)
		return true;
	if (a.ip[0] == b.ip[0] && a.ip[1] == b.ip[1] && a.ip[2] == b.ip[2] && a.ip[3] == b.ip[3] && a.port == b.port)
		return true;
	return false;
}

qbool NET_IsLocalAddress (netadr_t a)
{
	if ((*(unsigned *)a.ip == *(unsigned *)net_local_adr.ip
		|| *(unsigned *)a.ip == htonl(INADDR_LOOPBACK)) )
		return true;
	
	return false;
}

char *NET_AdrToString (netadr_t a)
{
	static	char	s[64];

	if (a.type == NA_NULL)
		return "null";
	if (a.type == NA_LOOPBACK)
		return "loopback";

	sprintf (s, "%i.%i.%i.%i:%i", a.ip[0], a.ip[1], a.ip[2], a.ip[3], ntohs(a.port));

	return s;
}

char *NET_BaseAdrToString (netadr_t a)
{
	static	char	s[64];
	
	if (a.type == NA_NULL)
		return "null";
	if (a.type == NA_LOOPBACK)
		return "loopback";

	sprintf (s, "%i.%i.%i.%i", a.ip[0], a.ip[1], a.ip[2], a.ip[3]);

	return s;
}

/*
=============
NET_StringToAdr

idnewt
idnewt:28000
192.246.40.70
192.246.40.70:28000
=============
*/
qbool NET_StringToAdr (char *s, netadr_t *a)
{
	struct hostent	*h;
	struct sockaddr_in sadr;
	char	*colon;
	char	copy[128];

	if (!strcmp(s, "local"))
	{
		memset(a, 0, sizeof(*a));
		a->type = NA_LOOPBACK;
		return true;
	}
	
	memset (&sadr, 0, sizeof(sadr));
	sadr.sin_family = AF_INET;
	
	sadr.sin_port = 0;

	strcpy (copy, s);
	// strip off a trailing :port if present
	for (colon = copy ; *colon ; colon++)
		if (*colon == ':')
		{
			*colon = 0;
			sadr.sin_port = htons((short)atoi(colon+1));	
		}
	
	if ( isdigit((int)(unsigned char)copy[0]) )
	{
		*(int *)&sadr.sin_addr = inet_addr(copy);
	}
	else
	{
		if ((h = gethostbyname(copy)) == 0)
			return 0;
		*(int *)&sadr.sin_addr = *(int *)h->h_addr_list[0];
	}
	
	SockadrToNetadr (&sadr, a);

	return true;
}


/*
=============================================================================

LOOPBACK BUFFERS FOR LOCAL PLAYER

=============================================================================
*/

qbool NET_GetLoopPacket (netsrc_t sock)
{
	int		i;
	loopback_t	*loop;

	loop = &loopbacks[sock];

	if (loop->send - loop->get > MAX_LOOPBACK)
		loop->get = loop->send - MAX_LOOPBACK;

	if ((int)(loop->send - loop->get) <= 0)
		return false;

	i = loop->get & (MAX_LOOPBACK-1);
	loop->get++;

	memcpy (net_message.data, loop->msgs[i].data, loop->msgs[i].datalen);
	net_message.cursize = loop->msgs[i].datalen;
	memset (&net_from, 0, sizeof(net_from));
	net_from.type = NA_LOOPBACK;
	return true;

}


void NET_SendLoopPacket (netsrc_t sock, int length, void *data, netadr_t to)
{
	int		i;
	loopback_t	*loop;

	loop = &loopbacks[sock^1];

	i = loop->send & (MAX_LOOPBACK-1);
	loop->send++;

	if (length > sizeof(loop->msgs[i].data))
		Sys_Error ("NET_SendLoopPacket: length > MAX_BIG_MSGLEN");

	memcpy (loop->msgs[i].data, data, length);
	loop->msgs[i].datalen = length;
}


void NET_ClearLoopback (void)
{
	loopbacks[0].send = loopbacks[0].get = 0;
	loopbacks[1].send = loopbacks[1].get = 0;
}

//=============================================================================

qbool NET_GetPacket (netsrc_t sock)
{
	int 	ret;
	struct sockaddr_in	from;
	int		fromlen;
	int		net_socket;

	if (NET_GetLoopPacket (sock))
		return true;

	net_socket = ip_sockets[sock];
	if (net_socket == -1)
		return false;

	fromlen = sizeof(from);
	ret = recvfrom (net_socket, (char *)net_message_buffer, sizeof(net_message_buffer), 0, (struct sockaddr *)&from, &fromlen);
	SockadrToNetadr (&from, &net_from);

	if (ret == -1)
	{
		int err = WSAGetLastError();

		if (err == WSAEWOULDBLOCK)
			return false;
		if (err == WSAEMSGSIZE) {
			Com_Printf ("Warning:  Oversize packet from %s\n",
				NET_AdrToString (net_from));
			return false;
		}
		if (err == 10054) {
			Com_DPrintf ("NET_GetPacket: Error 10054 from %s\n", NET_AdrToString (net_from));
			return false;
		}

		Sys_Error ("NET_GetPacket: %s", strerror(err));
	}

	net_message.cursize = ret;
	if (ret == sizeof(net_message_buffer) )
	{
		Com_Printf ("Oversize packet from %s\n", NET_AdrToString (net_from));
		return false;
	}

	return ret;
}

//=============================================================================

void NET_SendPacket (netsrc_t sock, int length, void *data, netadr_t to)
{
	int		ret;
	struct sockaddr_in	addr;
	int		net_socket;

	if (to.type == NA_NULL)
		return;

	if (to.type == NA_LOOPBACK)	{
		NET_SendLoopPacket (sock, length, data, to);
		return;
	}

	net_socket = ip_sockets[sock];
	if (net_socket == -1)
		return;

	NetadrToSockadr (&to, &addr);

	ret = sendto (net_socket, data, length, 0, (struct sockaddr *)&addr, sizeof(addr));
	if (ret == -1)
	{
		int err = WSAGetLastError();

// wouldblock is silent
        if (err == WSAEWOULDBLOCK)
	        return;

#ifndef SERVERONLY
		if (err == WSAEADDRNOTAVAIL)
			Com_DPrintf ("NET_SendPacket Warning: %i\n", err);
		else
#endif
			Com_Printf ("NET_SendPacket ERROR: %i\n", err);
	}
}

//=============================================================================

int UDP_OpenSocket (int port)
{
	int			newsocket;
	struct		sockaddr_in address;
	unsigned long _true = true;
	int i;

	if ((newsocket = socket (PF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
		Sys_Error ("UDP_OpenSocket: socket:", strerror(errno));

	if (ioctlsocket (newsocket, FIONBIO, &_true) == -1)
		Sys_Error ("UDP_OpenSocket: ioctl FIONBIO:", strerror(errno));

	address.sin_family = AF_INET;

// check for interface binding option
	if ((i = COM_CheckParm("-ip")) != 0 && i < com_argc) {
		address.sin_addr.s_addr = inet_addr(com_argv[i+1]);
		Com_Printf ("Binding to IP Interface Address of %s\n",
				inet_ntoa(address.sin_addr));
	} else
		address.sin_addr.s_addr = INADDR_ANY;

	address.sin_port = htons((short)port);

	if (bind (newsocket, (void *)&address, sizeof(address)) == -1)
		return -1;

	return newsocket;
}


/*
====================
NET_ClientConfig
====================
*/
void NET_ClientConfig (qbool enable)
{
	if (enable)
	{
		if (ip_sockets[NS_CLIENT] == -1)
		{
			// try the default port first
			ip_sockets[NS_CLIENT] = UDP_OpenSocket (PORT_CLIENT);
			if (ip_sockets[NS_CLIENT] == -1)
				ip_sockets[NS_CLIENT] = UDP_OpenSocket (0);	// any dynamic port
			if (ip_sockets[NS_CLIENT] == -1)
				Sys_Error ("Couldn't allocate client socket");
		}
	}
	else
	{
		if (ip_sockets[NS_CLIENT] != -1) {
			closesocket (ip_sockets[NS_CLIENT]);
			ip_sockets[NS_CLIENT] = -1;
		}
	}
}

/*
====================
NET_ServerConfig
====================
*/
void NET_ServerConfig (qbool enable)
{
	int		i, port;

	if (enable)
	{
		if (ip_sockets[NS_SERVER] != -1)
			return;

		port = 0;
		i = COM_CheckParm ("-port");
		if (i && i < com_argc)
			port = atoi(com_argv[i+1]);
		if (!port)
			port = PORT_SERVER;

		ip_sockets[NS_SERVER] = UDP_OpenSocket (port);
		if (ip_sockets[NS_SERVER] == -1)
		{
#ifdef SERVERONLY
			Sys_Error ("Couldn't allocate server socket");
#else
			Com_Printf ("WARNING: Couldn't allocate server socket.\n");
#endif
		}
	}
	else
	{
		if (ip_sockets[NS_SERVER] != -1) {
			closesocket (ip_sockets[NS_SERVER]);
			ip_sockets[NS_SERVER] = -1;
		}
	}
}


/*
====================
NET_Sleep

Sleeps msec or until the server socket is ready
====================
*/
void NET_Sleep (int msec)
{
	struct timeval timeout;
	fd_set	fdset;
	int i;

	FD_ZERO (&fdset);
	i = 0;
	if (ip_sockets[NS_SERVER] != -1) {
		FD_SET (ip_sockets[NS_SERVER], &fdset); // network socket
		i = ip_sockets[NS_SERVER];
	}

/*	if (ipx_sockets[NS_SERVER] != -1) {
		FD_SET(ipx_sockets[NS_SERVER], &fdset); // network socket
		if (ipx_sockets[NS_SERVER] > i)
			i = ipx_sockets[NS_SERVER];
	}
*/
	timeout.tv_sec = msec/1000;
	timeout.tv_usec = (msec%1000)*1000;
	select (i+1, &fdset, NULL, NULL, &timeout);
}


/*
====================
NET_Init
====================
*/
void NET_Init (void)
{
	WORD	wVersionRequested; 
	int		r;

	wVersionRequested = MAKEWORD(1, 1); 
	r = WSAStartup (wVersionRequested, &winsockdata);

	if (r)
		Sys_Error ("Winsock initialization failed.");

	//
	// init the message buffer
	//
	SZ_Init (&net_message, net_message_buffer, sizeof(net_message_buffer));

	Com_Printf ("Winsock initialized.\n");
}

/*
====================
NET_Shutdown
====================
*/
void NET_Shutdown (void)
{
	NET_ClientConfig (false);
	NET_ServerConfig (false);
	WSACleanup ();
}

