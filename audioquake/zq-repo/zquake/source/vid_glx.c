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
#include <termios.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <stdarg.h>
#include <stdio.h>
#include <signal.h>

#include "gl_local.h"
#include "keys.h"
#include "input.h"

#include <GL/glx.h>

#include <X11/keysym.h>
#include <X11/cursorfont.h>

#ifdef USE_VMODE
#include <X11/extensions/xf86vmode.h>
#endif

#ifdef USE_DGA
#include <X11/extensions/xf86dga.h>
#endif

static Display *x_disp = NULL;
static Window x_win;
static GLXContext ctx = NULL;

static float mouse_x, mouse_y, old_mouse_x, old_mouse_y;
static qbool input_grabbed =  false;

#define KEY_MASK (KeyPressMask | KeyReleaseMask)
#define MOUSE_MASK (ButtonPressMask | ButtonReleaseMask | \
		    PointerMotionMask | ButtonMotionMask )
#define X_MASK (KEY_MASK | MOUSE_MASK | VisibilityChangeMask | StructureNotifyMask )

typedef void (APIENTRY *lpMTexFUNC) (GLenum, GLfloat, GLfloat);
lpMTexFUNC qglMultiTexCoord2f = NULL;

// setup gamma variables
float vid_gamma = 1.0;
byte vid_gamma_table[256];
unsigned short *currentgammaramp = NULL;
qbool vid_gammaworks = false;
// qbool vid_hwgamma_enabled = false;
qbool customgamma = false;

unsigned d_8to24table[256];
unsigned d_8to24table2[256];
unsigned char	d_15to8table[65536];

static int scrnum;

#ifdef USE_DGA
static qbool dgamouse = false;
#endif

#ifdef USE_VMODE
static qbool vidmode_ext = false;
static XF86VidModeModeInfo **vidmodes;
static int num_vidmodes;
static qbool vidmode_active = false;
static unsigned short systemgammaramp[3][256];
#endif

cvar_t	vid_ref = {"vid_ref", "gl", CVAR_ROM};
cvar_t	_windowed_mouse = {"_windowed_mouse", "1", CVAR_ARCHIVE};
cvar_t	vid_mode = {"vid_mode","0"};

static float mouse_x, mouse_y;
static float old_mouse_x, old_mouse_y;

cvar_t	m_filter = {"m_filter", "0"};
cvar_t	gl_strings = {"gl_strings", "", CVAR_ROM};
cvar_t	vid_hwgammacontrol = {"vid_hwgammacontrol", "1"};

/*-----------------------------------------------------------------------*/

float gldepthmin, gldepthmax;

const char *gl_vendor;
const char *gl_renderer;
const char *gl_version;
const char *gl_extensions;

qbool is8bit = false;
qbool isPermedia = false;
qbool gl_mtexable = false;
qbool gl_mtexfbskins = false;

/*-----------------------------------------------------------------------*/

// direct draw software compatibility 

void VID_UnlockBuffer()
{
}

void VID_LockBuffer()
{
}

void D_BeginDirectRect (int x, int y, byte *pbitmap, int width, int height)
{
}

void D_EndDirectRect (int x, int y, int width, int height)
{
}

void VID_SetCaption (char *text)
{
	if (!x_disp)
		return;
	XStoreName (x_disp, x_win, text);
}

static int XLateKey(XKeyEvent *ev)
{

    int key;
//    char buf[64];
//    KeySym shifted;
    KeySym keysym;

    keysym = XLookupKeysym (ev, 0);
//    XLookupString (ev, buf, sizeof buf, &shifted, 0);

    key = 0;

    switch (keysym)
    {
    case XK_KP_Page_Up:
    case XK_Page_Up:
        key = K_PGUP;
        break;

    case XK_KP_Page_Down:
    case XK_Page_Down:
        key = K_PGDN;
        break;

    case XK_KP_Home:
    case XK_Home:
        key = K_HOME;
        break;

    case XK_KP_End:
    case XK_End:
        key = K_END;
        break;

    case XK_KP_Left:
    case XK_Left:
        key = K_LEFTARROW;
        break;

    case XK_KP_Right:
    case XK_Right:
        key = K_RIGHTARROW;
        break;

    case XK_KP_Down:
    case XK_Down:
        key = K_DOWNARROW;
        break;

    case XK_KP_Up:
    case XK_Up:
        key = K_UPARROW;
        break;

    case XK_Escape:
        key = K_ESCAPE;
        break;

    case XK_KP_Enter:
    case XK_Return:
        key = K_ENTER;
        break;

    case XK_Tab:
        key = K_TAB;
        break;

    case XK_F1:
        key = K_F1;
        break;

    case XK_F2:
        key = K_F2;
        break;

    case XK_F3:
        key = K_F3;
        break;

    case XK_F4:
        key = K_F4;
        break;

    case XK_F5:
        key = K_F5;
        break;

    case XK_F6:
        key = K_F6;
        break;

    case XK_F7:
        key = K_F7;
        break;

    case XK_F8:
        key = K_F8;
        break;

    case XK_F9:
        key = K_F9;
        break;

    case XK_F10:
        key = K_F10;
        break;

    case XK_F11:
        key = K_F11;
        break;

    case XK_F12:
        key = K_F12;
        break;

    case XK_BackSpace:
        key = K_BACKSPACE;
        break;

    case XK_KP_Delete:
    case XK_Delete:
        key = K_DEL;
        break;

    case XK_Pause:
        key = K_PAUSE;
        break;

    case XK_Shift_L:
    case XK_Shift_R:
        key = K_SHIFT;
        break;

    case XK_Execute:
    case XK_Control_L:
    case XK_Control_R:
        key = K_CTRL;
        break;

    case XK_Alt_L:
    case XK_Meta_L:
    case XK_Alt_R:
    case XK_Meta_R:
        key = K_ALT;
        break;

    case XK_KP_Begin:
        key = '5';
        break;

    case XK_KP_Insert:
    case XK_Insert:
        key = K_INS;
        break;

    case XK_KP_Multiply:
        key = '*';
        break;
    case XK_KP_Add:
        key = '+';
        break;
    case XK_KP_Subtract:
        key = '-';
        break;
    case XK_KP_Divide:
        key = '/';
        break;

    case XK_Caps_Lock:
        key = K_CAPSLOCK;
        break;
    case XK_Scroll_Lock:
        key = K_SCROLLLOCK;
        break;
    case XK_Num_Lock:
        key = KP_NUMLOCK;
        break;

    default:
        if (keysym >= 32 && keysym <= 126) {
            key = tolower(keysym);
        }
        break;
    }

    return key;
}

// hide the mouse cursor when in window
static Cursor CreateNullCursor(Display *display, Window root)
{
    Pixmap cursormask;
    XGCValues xgc;
    GC gc;
    XColor dummycolour;
    Cursor cursor;

    cursormask = XCreatePixmap(display, root, 1, 1, 1/*depth*/);
    xgc.function = GXclear;
    gc =  XCreateGC(display, cursormask, GCFunction, &xgc);
    XFillRectangle(display, cursormask, gc, 0, 0, 1, 1);
    dummycolour.pixel = 0;
    dummycolour.red = 0;
    dummycolour.flags = 04;
    cursor = XCreatePixmapCursor(display, cursormask, cursormask,
                                 &dummycolour,&dummycolour, 0,0);
    XFreePixmap(display,cursormask);
    XFreeGC(display,gc);
    return cursor;
}

static void install_grabs(void)
{
    int MajorVersion, MinorVersion;

    input_grabbed = true;

    // don't show mouse cursor icon
    XDefineCursor(x_disp, x_win, CreateNullCursor(x_disp, x_win));

    XGrabPointer(x_disp, x_win,
                 True,
                 0,
                 GrabModeAsync, GrabModeAsync,
                 x_win,
                 None,
                 CurrentTime);

#ifdef USE_DGA
    if (!COM_CheckParm("-nodga") &&
            XF86DGAQueryVersion(x_disp, &MajorVersion, &MinorVersion)) {
        // let us hope XF86DGADirectMouse will work
        XF86DGADirectVideo(x_disp, DefaultScreen(x_disp), XF86DGADirectMouse);
        dgamouse = true;
        XWarpPointer(x_disp, None, x_win, 0, 0, 0, 0, 0, 0); // oldman: this should be here really
    }
    else
#endif
        XWarpPointer(x_disp, None, x_win,
                     0, 0, 0, 0,
                     vid.width / 2, vid.height / 2);

    XGrabKeyboard(x_disp, x_win,
                  False,
                  GrabModeAsync, GrabModeAsync,
                  CurrentTime);
}

static void uninstall_grabs(void)
{
    input_grabbed = false;

#ifdef USE_DGA
    XF86DGADirectVideo(x_disp, DefaultScreen(x_disp), 0);
    dgamouse = false;
#endif

    XUngrabPointer(x_disp, CurrentTime);
    XUngrabKeyboard(x_disp, CurrentTime);

    // show cursor again
    XUndefineCursor(x_disp, x_win);

}

static void GetEvent(void)
{
    XEvent event;
    int b;
    qbool grab_input;

    if (!x_disp)
        return;

    XNextEvent(x_disp, &event);

    switch (event.type)
    {
    case KeyPress:
    case KeyRelease:
        Key_Event(XLateKey(&event.xkey), event.type == KeyPress);
        break;

    case MotionNotify:
        if (input_grabbed)
        {
#ifdef USE_DGA
            if (dgamouse)
            {
                mouse_x += event.xmotion.x_root;
                mouse_y += event.xmotion.y_root;
            }
            else
#endif
            {
                mouse_x = (float) ((int)event.xmotion.x - (int)(vid.width/2));
                mouse_y = (float) ((int)event.xmotion.y - (int)(vid.height/2));

                /* move the mouse to the window center again */
                XSelectInput(x_disp, x_win, X_MASK & ~PointerMotionMask);
                XWarpPointer(x_disp, None, x_win, 0, 0, 0, 0,
                             (vid.width/2), (vid.height/2));
                XSelectInput(x_disp, x_win, X_MASK);
            }
        }
        break;

    case ButtonPress:
        b=-1;
        if (event.xbutton.button == 1)
            b = 0;
        else if (event.xbutton.button == 2)
            b = 2;
        else if (event.xbutton.button == 3)
            b = 1;
        if (b>=0)
            Key_Event(K_MOUSE1 + b, true);
        break;

    case ButtonRelease:
        b=-1;
        if (event.xbutton.button == 1)
            b = 0;
        else if (event.xbutton.button == 2)
            b = 2;
        else if (event.xbutton.button == 3)
            b = 1;
        if (b>=0)
            Key_Event(K_MOUSE1 + b, false);
        break;
    }

#ifdef USE_VMODE
    grab_input = _windowed_mouse.value != 0 || vidmode_active;
#else
    grab_input = _windowed_mouse.value != 0;
#endif

    if (grab_input && !input_grabbed) {
        /* grab the pointer */
        install_grabs();
    }
    else if (!grab_input && input_grabbed) {
        /* ungrab the pointer */
        uninstall_grabs();
    }
}

void signal_handler(int sig)
{
    printf("Received signal %d, exiting...\n", sig);
    Sys_Quit();
    exit(0);
}

void InitSig(void)
{
    signal(SIGHUP, signal_handler);
    signal(SIGINT, signal_handler);
    signal(SIGQUIT, signal_handler);
    signal(SIGILL, signal_handler);
    signal(SIGTRAP, signal_handler);
    signal(SIGIOT, signal_handler);
    signal(SIGBUS, signal_handler);
    signal(SIGFPE, signal_handler);
    signal(SIGSEGV, signal_handler);
    signal(SIGTERM, signal_handler);
}

void VID_ShiftPalette(unsigned char *p)
{
}

/*
======================
VID_SetDeviceGammaRamp

Note: ramps must point to a static array
======================
*/
void VID_SetDeviceGammaRamp (unsigned short *ramps)
{
#ifdef USE_VMODE
    if (vid_gammaworks)
    {
        currentgammaramp = ramps;
        if (vid_hwgamma_enabled)
        {
            XF86VidModeSetGammaRamp(x_disp, scrnum, 256, ramps, ramps + 256, ramps + 512);
            customgamma = true;
        }
    }
#endif
}

void InitHWGamma (void)
{
#ifdef USE_VMODE
    int xf86vm_gammaramp_size;

    if (COM_CheckParm("-nohwgamma"))
        return;

    XF86VidModeGetGammaRampSize(x_disp, scrnum, &xf86vm_gammaramp_size);

    vid_gammaworks = (xf86vm_gammaramp_size == 256);

    if (vid_gammaworks)
    {
        XF86VidModeGetGammaRamp(x_disp,scrnum,xf86vm_gammaramp_size,
                                systemgammaramp[0], systemgammaramp[1], systemgammaramp[2]);
    }
    vid_hwgamma_enabled = vid_hwgammacontrol.value && vid_gammaworks; // && fullscreen?
#endif
}

void RestoreHWGamma (void)
{
#ifdef USE_VMODE
    if (vid_gammaworks && customgamma)
    {
        customgamma = false;
        XF86VidModeSetGammaRamp(x_disp, scrnum, 256, systemgammaramp[0], systemgammaramp[1], systemgammaramp[2]);
    }
#endif
}

//=================================================================

// check gamma settings
void Check_Gamma (unsigned char *pal)
{
	float	f, inf;
	unsigned char	palette[768];
	int		i;

	if ((i = COM_CheckParm("-gamma")) != 0 && i+1 < com_argc)
		vid_gamma = bound (0.3, Q_atof(com_argv[i+1]), 1);
	else
		vid_gamma = 1;

	Cvar_SetValue (&gl_gamma, vid_gamma);

	for (i=0 ; i<768 ; i++)
	{
		f = pow ( (pal[i]+1)/256.0 , vid_gamma );
		inf = f*255 + 0.5;
		if (inf < 0)
			inf = 0;
		if (inf > 255)
			inf = 255;
		palette[i] = inf;
	}

	memcpy (pal, palette, sizeof(palette));
}

void VID_SetPalette (byte *palette)
{
    int i;
    byte *pal, *table;

    // 8 8 8 encoding
    pal = palette;
    table = (byte *)d_8to24table;
    for (i = 0; i < 256; i++)
    {
        *table++ = *pal++;
        *table++ = *pal++;
        *table++ = *pal++;
        *table++ = 255;
    }
    d_8to24table[255] = 0;	// 255 is transparent

    // Tonik: create a brighter palette for bmodel textures
    pal = palette;
    table = (byte *)d_8to24table2;

    for (i = 1; i < 256; i++)
    {
        pal[0] = min(pal[0] * (2.0 / 1.5), 255);
        pal[1] = min(pal[1] * (2.0 / 1.5), 255);
        pal[2] = min(pal[2] * (2.0 / 1.5), 255);
        *table++ = *pal++;
        *table++ = *pal++;
        *table++ = *pal++;
        *table++ = 255;
    }
    d_8to24table2[255] = 0;	// 255 is transparent
}

/*
===============
GL_Init
===============
*/
void GL_Init (void)
{
    gl_vendor = glGetString (GL_VENDOR);
    Com_Printf ("GL_VENDOR: %s\n", gl_vendor);
    gl_renderer = glGetString (GL_RENDERER);
    Com_Printf ("GL_RENDERER: %s\n", gl_renderer);
    gl_version = glGetString (GL_VERSION);
    Com_Printf ("GL_VERSION: %s\n", gl_version);
    gl_extensions = glGetString (GL_EXTENSIONS);
//  Com_Printf ("GL_EXTENSIONS: %s\n", gl_extensions); 

	Cvar_Register (&gl_strings);
	Cvar_ForceSet (&gl_strings, va("GL_VENDOR: %s\nGL_RENDERER: %s\n"
		"GL_VERSION: %s\nGL_EXTENSIONS: %s", gl_vendor, gl_renderer, gl_version, gl_extensions));

    glClearColor (1,0,0,0);
    glCullFace(GL_FRONT);
    glEnable(GL_TEXTURE_2D);

    glEnable(GL_ALPHA_TEST);
    glAlphaFunc(GL_GREATER, 0.666);

    glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
    glShadeModel (GL_FLAT);

    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    //	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
}

void GL_EndRendering (void)
{
    static qbool old_hwgamma_enabled;

    vid_hwgamma_enabled = vid_hwgammacontrol.value && vid_gammaworks;
    if (vid_hwgamma_enabled != old_hwgamma_enabled)
    {
        old_hwgamma_enabled = vid_hwgamma_enabled;
        if (vid_hwgamma_enabled && currentgammaramp)
            VID_SetDeviceGammaRamp (currentgammaramp);
        else
            RestoreHWGamma ();
    }

    glFlush();
    glXSwapBuffers(x_disp, x_win);
}

void VID_Shutdown(void)
{
    if (!ctx)
        return;

    uninstall_grabs();

    RestoreHWGamma();

#ifdef USE_VMODE
    if (x_disp)
    {
        glXDestroyContext(x_disp, ctx);
        if (x_win)
            XDestroyWindow(x_disp, x_win);
        if (vidmode_active)
            XF86VidModeSwitchToMode(x_disp, scrnum, vidmodes[0]);
        XCloseDisplay(x_disp);
        vidmode_active = false;
    }
#else
    glXDestroyContext(x_disp, ctx);
#endif
}

qbool VID_Is8bit(void)
{
    return is8bit;
}

// removed old 3dfx code
void VID_Init8bitPalette()
{
    // Check for 8bit Extensions and initialize them.
    int i;
    char thePalette[256*3];
    char *oldPalette, *newPalette;

    if (strstr(gl_extensions, "GL_EXT_shared_texture_palette") == NULL)
        return;

    Com_Printf ("8-bit GL extensions enabled.\n");
    glEnable( GL_SHARED_TEXTURE_PALETTE_EXT );
    oldPalette = (char *) d_8to24table; //d_8to24table3dfx;
    newPalette = thePalette;
    for (i=0;i<256;i++)
    {
        *newPalette++ = *oldPalette++;
        *newPalette++ = *oldPalette++;
        *newPalette++ = *oldPalette++;
        oldPalette++;
    }
    glColorTableEXT(GL_SHARED_TEXTURE_PALETTE_EXT, GL_RGB, 256, GL_RGB, GL_UNSIGNED_BYTE, (void *) thePalette);
    is8bit = true;
}

void VID_Init(unsigned char *palette)
{
    int i;
    int attrib[] = {
                       GLX_RGBA,
                       GLX_RED_SIZE, 1,
                       GLX_GREEN_SIZE, 1,
                       GLX_BLUE_SIZE, 1,
                       GLX_DOUBLEBUFFER,
                       GLX_DEPTH_SIZE, 1,
                       None
                   };
    int width = 640, height = 480;
    XSetWindowAttributes attr;
    unsigned long mask;
    Window root;
    XVisualInfo *visinfo;

#ifdef USE_VMODE
    qbool fullscreen = true;
    int MajorVersion, MinorVersion;
    int actualWidth, actualHeight;
#endif

    Cvar_Register (&vid_ref);
    Cvar_Register (&vid_mode);
    Cvar_Register (&vid_hwgammacontrol);
    Cvar_Register (&_windowed_mouse);
    Cvar_Register (&m_filter);

    vid.colormap = host_colormap;

    // interpret command-line params
    // fullscreen cmdline check
#ifdef USE_VMODE
    if (COM_CheckParm("-window"))
        fullscreen = false;
#endif
    // set vid parameters
    if ((i = COM_CheckParm("-width")) != 0)
        width = atoi(com_argv[i+1]);
    if ((i = COM_CheckParm("-height")) != 0)
        height = atoi(com_argv[i+1]);
    if ((i = COM_CheckParm("-conwidth")) != 0)
        vid.width = Q_atoi(com_argv[i+1]);
    else
        vid.width = 640;

    vid.width &= 0xfff8; // make it a multiple of eight

    if (vid.width < 320)
        vid.width = 320;

    // pick a conheight that matches with correct aspect
    vid.height = vid.width*3 / 4;

    if ((i = COM_CheckParm("-conheight")) != 0)
        vid.height = Q_atoi(com_argv[i+1]);
    if (vid.height < 200)
        vid.height = 200;

    if (!(x_disp = XOpenDisplay(NULL)))
    {
        fprintf(stderr, "Error couldn't open the X display\n");
        exit(1);
    }

    scrnum = DefaultScreen(x_disp);
    root = RootWindow(x_disp, scrnum);

#ifdef USE_VMODE
    // check vmode extensions supported
    // Get video mode list
    MajorVersion = MinorVersion = 0;
    if (!XF86VidModeQueryVersion(x_disp, &MajorVersion, &MinorVersion))
    {
        vidmode_ext = false;
    }
    else
    {
        Com_Printf("Using XFree86-VidModeExtension Version %d.%d\n", MajorVersion, MinorVersion);
        vidmode_ext = true;
    }
#endif

    visinfo = glXChooseVisual(x_disp, scrnum, attrib);
    if (!visinfo)
    {
        fprintf(stderr, "qkHack: Error couldn't get an RGB, Double-buffered, Depth visual\n");
        exit(1);
    }

    // setup fullscreen size to fit display -->
#ifdef USE_VMODE
    if (vidmode_ext)
    {
        int best_fit, best_dist, dist, x, y;

        XF86VidModeGetAllModeLines(x_disp, scrnum, &num_vidmodes, &vidmodes);

        // Are we going fullscreen?  If so, let's change video mode
        if (fullscreen)
        {
            best_dist = 9999999;
            best_fit = -1;

            for (i = 0; i < num_vidmodes; i++)
            {
                if (width > vidmodes[i]->hdisplay || height > vidmodes[i]->vdisplay)
                    continue;

                x = width - vidmodes[i]->hdisplay;
                y = height - vidmodes[i]->vdisplay;
                dist = x * x + y * y;
                if (dist < best_dist)
                {
                    best_dist = dist;
                    best_fit = i;
                }
            }

            if (best_fit != -1)
            {
                actualWidth = vidmodes[best_fit]->hdisplay;
                actualHeight = vidmodes[best_fit]->vdisplay;
                // change to the mode
                XF86VidModeSwitchToMode(x_disp, scrnum, vidmodes[best_fit]);
                vidmode_active = true;
                // Move the viewport to top left
                XF86VidModeSetViewPort(x_disp, scrnum, 0, 0);
            }
            else
            {
                fullscreen = 0;
            }
        }
    }
#endif
    /* window attributes */
    attr.background_pixel = 0;
    attr.border_pixel = 0;
    attr.colormap = XCreateColormap(x_disp, root, visinfo->visual, AllocNone);
    attr.event_mask = X_MASK;
    mask = CWBackPixel | CWBorderPixel | CWColormap | CWEventMask;

    // if fullscreen disable window manager decoration
#ifdef USE_VMODE
    if (vidmode_active)
    {
        mask = CWBackPixel | CWColormap | CWSaveUnder | CWBackingStore |
               CWEventMask | CWOverrideRedirect;
        attr.override_redirect = True;
        attr.backing_store = NotUseful;
        attr.save_under = False;
    }
#endif
    x_win = XCreateWindow(x_disp, root, 0, 0, width, height,
                        0, visinfo->depth, InputOutput,
                        visinfo->visual, mask, &attr);
    XStoreName(x_disp, x_win, PROGRAM);
    XMapWindow(x_disp, x_win);

#ifdef USE_VMODE
    if (vidmode_active)
    {
        XRaiseWindow(x_disp, x_win);
        XWarpPointer(x_disp, None, x_win, 0, 0, 0, 0, 0, 0);
        XFlush(x_disp);
        // Move the viewport to top left
        XF86VidModeSetViewPort(x_disp, scrnum, 0, 0);
    }
#endif
    XFlush(x_disp);

    ctx = glXCreateContext(x_disp, visinfo, NULL, True);

    glXMakeCurrent(x_disp, x_win, ctx);

    vid.realwidth = width;
    vid.realheight = height;

    if (vid.height > height)
        vid.height = height;
    if (vid.width > width)
        vid.width = width;

    vid.aspect = ((float)vid.height / (float)vid.width) * (320.0 / 240.0);
    vid.numpages = 2;

    InitSig(); // trap evil signals

    GL_Init();

    Check_Gamma(palette);

    VID_SetPalette(palette);

    InitHWGamma();

    Com_Printf ("Video mode %dx%d initialized.\n", width, height);

	SCR_InvalidateScreen ();
}

void Sys_SendKeyEvents(void)
{
    if (x_disp)
    {
        while (XPending(x_disp))
            GetEvent();
    }
}

void Force_CenterView_f (void)
{
    cl.viewangles[PITCH] = 0;
}

void IN_Init(void)
{
    Cmd_AddCommand ("force_centerview", Force_CenterView_f);
}

void IN_Shutdown(void)
{}

/*
===========
IN_Commands
===========
*/
void IN_Commands (void)
{}

/*
===========
IN_Move
===========
*/
void IN_MouseMove (usercmd_t *cmd)
{
    if (m_filter.value)
    {
        mouse_x = (mouse_x + old_mouse_x) * 0.5;
        mouse_y = (mouse_y + old_mouse_y) * 0.5;
    }
    old_mouse_x = mouse_x;
    old_mouse_y = mouse_y;

    mouse_x *= sensitivity.value;
    mouse_y *= sensitivity.value;

    // add mouse X/Y movement to cmd
    if ( (in_strafe.state & 1) || (lookstrafe.value && mlook_active))
        cmd->sidemove += m_side.value * mouse_x;
    else
        cl.viewangles[YAW] -= m_yaw.value * mouse_x;

    if (mlook_active)
        V_StopPitchDrift ();

    if (mlook_active && !(in_strafe.state & 1))
    {
		cl.viewangles[PITCH] += m_pitch.value * mouse_y;
		if (cl.viewangles[PITCH] > cl.maxpitch)
			cl.viewangles[PITCH] = cl.maxpitch;
		if (cl.viewangles[PITCH] < cl.minpitch)
			cl.viewangles[PITCH] = cl.minpitch;
    }
    else
    {
        cmd->forwardmove -= m_forward.value * mouse_y;
    }
    mouse_x = mouse_y = 0.0;
}

void IN_Move (usercmd_t *cmd)
{
    IN_MouseMove(cmd);
}

/* vi: set noet ts=4 sts=4 ai sw=4: */
