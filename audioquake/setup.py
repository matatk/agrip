import platform
from cx_Freeze import setup, Executable

with open('../release', 'r') as f:
    release_number = f.readline().rstrip()
    release_name = f.readline().rstrip()
    print('Building', release_number, '--', release_name, '...')

include_files = [
    'COPYING',
    'ACKNOWLEDGEMENTS.html',
    'CHANGELOG.html',
    'LICENCE.html',
    'README.html',
    'manuals/',
    'cwsdpmi.exe',
    'genvxd.dll',
    'help.txt',
    'id1/',
    'licinfo.txt',
    'mgenvxd.vxd',
    'mindgrid-audio_-_quake.txt',
    'order.txt',
    'pdipx.com',
    'q95.bat',
    'qlaunch.exe',
    'quake.exe',
    'quakeudp.dll',
    'readme.txt',
    'readv106.txt',
    'slicnse.txt',
    'techinfo.txt'
]

base_gui = None
base_cli = None
includes = None
packages = None

if platform.system() == 'Windows':
    base_gui = 'Win32GUI'
    includes = [
        'pyttsx',
        'pyttsx.drivers.sapi5'
    ]
    packages = [
        'win32com.gen_py',
        'win32com.server.util'
    ]
    include_files += [
        'zquake-gl.exe',
        'zqds.exe'
    ]
    release_number = release_number.translate(None, 'abcdefghijklmnopqrstuvwxyz-_')
elif platform.system() == 'Darwin':
    includes = [
        # 'PyObjCTools',
        # 'pkg_resources'
    ]
    include_files += [
        'zquake-glsdl',
        'zqds',
        'start-server.command',
        'start-rcon.command'
    ]
else:
    raise 'Platform ' + platform.system() + ' is not currently supported.'

setup(
    name='AudioQuake',
    version=release_number,
    options={
        'build_exe': {
            'includes': includes,
            'packages': packages,
            'include_files': include_files,
            'silent': True
        },
        'bdist_mac': {
            'iconfile': '../wrapper-mac/aq.icns',
            'custom_info_plist': '../wrapper-mac/Info.plist'
        }
    },
    executables=[
        Executable('AudioQuake.py', base=base_gui),
        Executable('rcon.py', base=base_cli),
    ]
)
