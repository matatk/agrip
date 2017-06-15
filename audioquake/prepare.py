"""Get all the bits and bobs ready to build AudioQuake"""
import platform
import os
import sys
import subprocess
import glob
import shutil
import urllib.request
import urllib.parse
import urllib.error
import zipfile
import traceback
from manuals import convert


def is_mac(): return platform.system() == 'Darwin'


def is_windows(): return platform.system() == 'Windows'


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

    dir_assets = 'downloaded-assets'
    dir_manuals = 'manuals'
    dir_mod_static = 'mod-static-files'

    url_maps = 'https://dl.dropboxusercontent.com/sh/quqwcm244sqoh5a/8no8PzlJCW/devfiles/maps.zip'
    url_demos = 'https://dl.dropboxusercontent.com/sh/quqwcm244sqoh5a/HTM6QTjNTh/devfiles/demos.zip'
    url_skins = 'https://dl.dropboxusercontent.com/sh/quqwcm244sqoh5a/QlAYOO3MLl/devfiles/skins.zip'
    url_shareware = 'https://dl.dropboxusercontent.com/sh/quqwcm244sqoh5a/jhcvn0KyLd/data/quake-shareware-1.06.zip'
    url_mindgrid = 'https://dl.dropboxusercontent.com/sh/quqwcm244sqoh5a/tS5qRFx_Am/data/mindgrid-audio_quake_2003.09.22.zip'


#
# Utilities
#

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
    exc_type, exc_value, exc_traceback = sys.exc_info()
    if exc_type:
        traceback.print_exc()
    print('Error:', message)
    sys.exit(42)


def check_platform():
    if not is_mac() and not is_windows():
        die('Sorry, your platform is not supported yet.')


def prep_dir(directory):
    if os.path.exists(directory):
        if not os.path.isdir(directory):
            die(directory + ' exists but is not a directory')
    else:
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
        print('Building', Info.release_number, ':', Info.release_name)


#
# Engine compilation
#

def compile_zqcc():
    _compile(Config.dir_make_zqcc, 'zqcc')


def compile_zquake():
    _compile(Config.dir_make_zquake, 'zquake', ['gl', 'server'])


def _make(name, target=None):
    try:
        with open(os.devnull, 'w') as DEVNULL:
            if target is not None:
                result = subprocess.call(['make', target],
                        stdout=DEVNULL, stderr=subprocess.STDOUT)
            else:
                result = subprocess.call(['make'],
                        stdout=DEVNULL, stderr=subprocess.STDOUT)
                if result is not 0:
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


#
# QuakeC Compilation
#

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
        with open(os.devnull, 'w') as DEVNULL:
            result = subprocess.call((
                os.path.join(Info.base_dir, Config.bin_zqcc),
                '-progs',
                progs),
                stdout=DEVNULL,
                stderr=subprocess.STDOUT)
            if result is not 0:
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


#
# Converting the manuals and other docs
#

def _chdir_manuals():
    try:
        os.chdir(Config.dir_manuals)
    except:
        die("can't change to manuals' directory: " + Config.dir_manuals)


@comeback
def convert_manuals():
    _chdir_manuals()
    print('Converting manuals from Markdown to HTML')
    convert.manuals()  # also converts the sound legend individual file


@comeback
def convert_standalone_docs():
    # TODO LICENCE and README from above
    convert.all_single_md_files()


#
# Downloading support files
#

def get_summat(dest_dir, check_file, plural_name, url):
    print('Checking:', plural_name)
    real_dest_dir = os.path.join(Config.dir_assets, dest_dir)
    if not os.path.isdir(real_dest_dir) \
            or not os.path.isfile(os.path.join(real_dest_dir, check_file)):
        print("It seems you don't have", plural_name)
        # Try to re-extract, or re-download
        zip_file_name = real_dest_dir + '.zip'
        if os.path.isfile(zip_file_name):
            print('Re-extracting...')
        else:
            print('Downloading...')
            try:
                urllib.request.urlretrieve(url, zip_file_name)
            except:
                die('whilst downloading ' + url)
        # Actually try to extract
        try:
            zipfile.ZipFile(zip_file_name).extractall(Config.dir_assets)
        except:
            die('when extracting ' + zip_file_name)


#
# Let's script like it's 1989...
#

if __name__ == '__main__':
    banner()
    check_platform()

    if Config.do_compile:
        if is_mac():
            print('Compiling zqcc')
            compile_zqcc()
            print('Compiling zquake')
            compile_zquake()
        elif is_windows():
            print("On Windows, we don't compile the engine here; we just pick up the existing binaries.")
        else:
            raise NotImplementedError

    print('Preparing downloaded assets dir')
    prep_dir(Config.dir_assets)

    if Config.do_compile:
        print('Compiling gamecode')
        compile_gamecode()
    #print('Copying in gamecode')
    #copy_gamecode()

    # Markdown to HTML...
    convert_manuals()

    # Get stuff...
    get_summat(
            'maps',
            'agdm01.bsp',
            'maps',
            Config.url_maps)
    get_summat(
            'demos',
            'final2.dem',
            'demos',
            Config.url_demos)
    get_summat(
            'skins',
            'base.pcx',
            'skins',
            Config.url_skins)
    get_summat(
            'quake-shareware-1.06',
            'q95.bat',
            'shareware data',
            Config.url_shareware)
    get_summat(
            'mindgrid-audio_quake_2003.09.22',
            'pak2.pak',
            'mindgrid sounds',
            Config.url_mindgrid)

    print('Finally, converting all standalone .md files to .html')
    convert_standalone_docs()
