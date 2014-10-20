#!/usr/bin/env python
import platform
import os
import sys  # exit
import subprocess
import glob  # picking up .dat files
import shutil  # removing a tree; copying files
import urllib
import zipfile

def is_mac(): return platform.system() == 'Darwin'
def is_windows(): return platform.system() == 'Windows'

# Bit of a hack doing it this way, but I have not got custom build
# commands working yet -- cx_Freeze overrides them and I'm not sure
# how best to play with that.  So, for now, the build steps are done
# as part of a linear script; how hideous! :-)

class Info:
    release_number = None
    release_name = None
    base_dir = os.getcwd()

class Config:
    do_compile = True
    dir_make_zqcc = os.path.join('zq-repo', 'zqcc')
    dir_make_zquake = os.path.join('zq-repo', 'zquake')
    dir_qc = os.path.join('zq-repo', 'qc', 'agrip')

    if is_mac():
        bin_zqcc = os.path.join(dir_make_zqcc, 'zqcc')
        bin_zqgl = os.path.join(dir_make_zquake, 'release-mac', 'zquake-glsdl')
        bin_zqds = os.path.join(dir_make_zquake, 'release-mac', 'zqds')
    elif is_windows():
        bin_zqcc = os.path.join(dir_make_zqcc, 'Release', 'zqcc.exe')
        bin_zqgl = os.path.join(dir_make_zquake, 'source', 'Release-GL', 'zquake-gl.exe')
        bin_zqds = os.path.join(dir_make_zquake, 'source', 'Release-server', 'zqds.exe')
    else:
        raise NotImplementedError

    dir_manuals = 'manuals'
    dir_staging = 'app-staging'
    dir_staging_manuals = os.path.join(dir_staging, 'manuals')
    dir_mod_compiled = os.path.join(dir_staging, 'id1')
    dir_mod_static = 'mod-static'

    url_maps = 'https://dl.dropboxusercontent.com/sh/quqwcm244sqoh5a/8no8PzlJCW/devfiles/maps.zip'
    url_demos = 'https://dl.dropboxusercontent.com/sh/quqwcm244sqoh5a/HTM6QTjNTh/devfiles/demos.zip'
    url_skins = 'https://dl.dropboxusercontent.com/sh/quqwcm244sqoh5a/QlAYOO3MLl/devfiles/skins.zip'
    url_shareware = 'https://dl.dropboxusercontent.com/sh/quqwcm244sqoh5a/jhcvn0KyLd/data/quake-shareware-1.06.zip'
    url_mindgrid = 'https://dl.dropboxusercontent.com/sh/quqwcm244sqoh5a/tS5qRFx_Am/data/mindgrid-audio_quake_2003.09.22.zip'


# Utilities
def comeback(function):
    def wrapper(*args, **kwargs):
        original = os.getcwd()
        function(*args, **kwargs)
        try:
            os.chdir(original)
        except:
            die("couldn't return to original directory: " + original)
    return wrapper

def die(message):
    backtrace = sys.exc_info()
    if backtrace: print backtrace
    print 'Error:', message
    sys.exit(42)

def check_platform():
    if not is_mac() and not is_windows():
        die('platform ' + plat + ' is not supported yet; sorry!')

def prep_empty_dir(directory):
    if os.path.exists(directory):
        if not os.path.isdir(directory):
            die(directory + ' exists but is not a directory')
        # It exists and is a directory; remove it
        try:
            shutil.rmtree(directory)
        except:
            die('removing previous directory: ' + directory)
    # It's been removed or didn't exist; create an empty one
    try:
        os.mkdir(directory)
    except:
        die('creating ' + directory)

def copy_tree(source, dest):
    try:
        shutil.copytree(source, dest)
    except:
        die("copying " + source + " to " + dest)

def copy_glob(source_dir, pattern, dest_dir):
    files = glob.glob(os.path.join(source_dir, pattern))
    for thing in files:
        try:
            shutil.copy(thing, dest_dir)
        except:
            die("copying " + thing + " to " + dest_dir)

def copy_file(source_dir, name, dest_dir):
    try:
        shutil.copy(os.path.join(source_dir, name), dest_dir)
    except:
        die("copying " + name + " from " + source_dir + " to " + dest_dir)

def copy_file_abs(source, dest_dir):
    try:
        shutil.copy(source, dest_dir)
    except:
        die("copying " + source + " to " + dest_dir)

def make_subdir(path, name):
    try:
        os.mkdir(os.path.join(path, name))
    except:
        die("making directory " + name + " under " + path)

def banner():
    with open('release', 'r') as f:
        Info.release_number = f.readline().rstrip()
        Info.release_name = f.readline().rstrip()
        print 'Building', Info.release_number, ':', Info.release_name


# Engine compilation
def compile_zqcc():
    _compile(Config.dir_make_zqcc, 'zqcc')

def compile_zquake():
    _compile(Config.dir_make_zquake, 'zquake', ['gl', 'server'])

def _make(name, target = None):
    try:
        if target is not None:
            ret = subprocess.call(('make', target))
        else:
            ret = subprocess.call('make')
        if ret != 0:
            die('failed to compile ' + name + ' target: ' + str(target))
    except:
        die('failed to run make for ' + name + ', target: ' + str(target))

@comeback
def _compile(path, name, targets=[]):
    try:
        os.chdir(path)
    except:
        die("can't change directory to: " + path)
    if len(targets) == 0:
        _make(name)
    else:
        for targ in targets:
            _make(name, targ)


# QuakeC Compilation
def _chdir_gamecode():
    try:
        os.chdir(Config.dir_qc)
    except:
        die("can't change to QuakeC directory: " + Config.dir_qc)

@comeback
def compile_gamecode():
    _chdir_gamecode()
    _compile_gamecode('progs.src')
    _compile_gamecode('spprogs.src')

def _compile_gamecode(progs):
    try:
        ret = subprocess.call((
            os.path.join(Info.base_dir, Config.bin_zqcc),
            '-progs',
            progs))
        if ret != 0:
            die('failed compiling gamecode: ' + progs)
    except:
        die('failed calling zqcc to compile gamecode: ' + progs)

@comeback
def copy_gamecode():
    _chdir_gamecode()
    datfiles = glob.glob('*.dat')
    full_mod_dir = os.path.join(Info.base_dir, Config.dir_mod_compiled)
    for datfile in datfiles:
        try:
            shutil.copy(datfile, full_mod_dir)
        except:
            die('copying ' + datfile + ' to ' + full_mod_dir)


# Downloading support files
def get_summat(dest_dir, check_file, plural_name, url):
    print 'Checking:', plural_name
    if not os.path.isdir(dest_dir) \
    or not os.path.isfile(os.path.join(dest_dir, check_file)):
        print "It seems you don't have", plural_name
        # Try to re-extract, or re-download
        zip_file_name = dest_dir + '.zip'
        if os.path.isfile(zip_file_name):
            print 'Re-extracting...'
        else:
            print 'Downloading...'
            try:
                urllib.urlretrieve(url, zip_file_name)
            except:
                die('whilst downloading ' + url)
        # Actually try to extract
        try:
            zipfile.ZipFile(zip_file_name).extractall()
        except:
            die('when extracting ' + zip_file_name)


# Let's script like it's 1989...
if __name__ == '__main__':
    banner()
    check_platform()

    if Config.do_compile:
        if is_mac():
            print 'Compiling zqcc'
            compile_zqcc()
            print 'Compiling zquake'
            compile_zquake()
        elif is_windows():
            print "On Windows, we don't compile the engine here; we just pick up the existing binaries."
        else:
            raise NotImplementedError

    print 'Preparing empty staging area'
    prep_empty_dir(Config.dir_staging)
    prep_empty_dir(Config.dir_staging_manuals)

    print "Copying in 'static' assets"
    copy_tree(Config.dir_mod_static, Config.dir_mod_compiled)

    if Config.do_compile:
        print 'Compiling gamecode'
        compile_gamecode()
    print 'Copying in gamecode'
    copy_gamecode()

    # Get stuff...
    get_summat('maps', 'agdm01.bsp', 'maps', Config.url_maps)
    make_subdir(Config.dir_mod_compiled, 'maps')
    copy_glob('maps', '*.bsp', os.path.join(Config.dir_mod_compiled, 'maps'))

    get_summat('demos', 'final2.dem', 'demos', Config.url_demos)
    copy_glob('demos', '*.dem', Config.dir_mod_compiled)

    get_summat('skins', 'base.pcx', 'skins', Config.url_skins)
    make_subdir(Config.dir_mod_compiled, 'skins')
    copy_file('skins', 'base.pcx', os.path.join(Config.dir_mod_compiled, 'skins'))

    get_summat(
        'quake-shareware-1.06',
        'q95.bat',
        'shareware data',
        Config.url_shareware)
    copy_glob('quake-shareware-1.06', '*.*', Config.dir_staging)
    copy_glob(
        os.path.join('quake-shareware-1.06', 'id1'),
        '*.*',
        Config.dir_mod_compiled)

    get_summat(
        'mindgrid-audio_quake_2003.09.22',
        'pak2.pak',
        'mindgrid sounds',
        Config.url_mindgrid)
    copy_file('mindgrid-audio_quake_2003.09.22', 'readme.txt',
        os.path.join(Config.dir_staging, 'mindgrid-audio-readme.txt'))
    copy_glob('mindgrid-audio_quake_2003.09.22', '*.txt', Config.dir_staging)
    copy_glob('mindgrid-audio_quake_2003.09.22', '*.pak', Config.dir_mod_compiled)

    print 'Copying in other files (engine binaries, launcher, setup, docs)'
    copy_file('..', 'COPYING', Config.dir_staging)
    copy_glob('..', '*.md', Config.dir_staging)
    copy_glob('.', '*.md', Config.dir_staging)
    copy_file('.', 'AudioQuake.py', Config.dir_staging)
    copy_file('.', 'rcon.py', Config.dir_staging)
    copy_file('.', 'setup.py', Config.dir_staging)
    copy_file_abs(Config.bin_zqds, Config.dir_staging)
    copy_file_abs(Config.bin_zqgl, Config.dir_staging)
    copy_glob(Config.dir_manuals, '*-manual.html', Config.dir_staging_manuals)
    copy_file(Config.dir_manuals, 'agrip.css', Config.dir_staging_manuals)

    if is_mac():
        print 'Copying Mac command-line starter scripts'
        copy_glob('wrapper-mac', 'start-*.command', Config.dir_staging)
        print 'Hacking in Python support files for freeze on Mac'
        copy_tree('/System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/PyObjC/PyObjCTools', Config.dir_staging + '/PyObjCTools')
        copy_file_abs('/System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/pkg_resources.py', Config.dir_staging)
