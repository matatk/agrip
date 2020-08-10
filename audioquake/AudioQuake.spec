# vim: ft=python
import platform

from buildlib import Config

data_files = [
	('mod-static-files/', 'id1'),
	('mod-conditional-files/id1/mod.cfg', 'id1/'),
	('maps-prototypewad/*.bsp', 'id1/maps/'),
	('../giants/zq-repo/qc/agrip/qwprogs.dat', 'id1/'),
	('../giants/zq-repo/qc/agrip/spprogs.dat', 'id1/'),

	('../../non-redist/oq-pak-src-2004.08.01/', 'oq'),
	('mod-static-files/', 'oq'),
	('mod-conditional-files/oq/mod.cfg', 'oq/'),
	('maps-freewad/*.bsp', 'oq/maps/'),
	('maps-prototypewad/*.bsp', 'oq/maps/'),
	('../giants/zq-repo/qc/agrip/qwprogs.dat', 'oq/'),
	('../giants/zq-repo/qc/agrip/spprogs.dat', 'oq/'),

	('manuals-converted/', 'manuals'),
	('manuals/agrip.css', 'manuals'),
	('app-support-files/start-rcon.command', '.'),
	('app-support-files/start-server.command', '.'),
	('../ldl/style.xml', '.'),
	('../ldl/tut*.xml', 'ldl-tutorial-maps')]

if next(Config.dir_maps_quakewad.glob('*.bsp'), None) is not None:
	data_files.extend([('maps-quakewad/*.bsp', 'id1/maps/')])

if platform.system() == 'Darwin':
	binary_files = [
		('../giants/zq-repo/zquake/release-mac/zqds', '.'),
		('../giants/zq-repo/zquake/release-mac/zquake-glsdl', '.'),
		('../giants/Quake-Tools/qutils/qbsp/qbsp', 'bin/'),
		('../giants/Quake-Tools/qutils/qbsp/light', 'bin/'),
		('../giants/Quake-Tools/qutils/qbsp/vis', 'bin/'),
		('../giants/Quake-Tools/qutils/qbsp/bspinfo', 'bin/')]
else:
	binary_files = [
		('../giants/zq-repo/zquake/source/Release-server/zqds.exe', '.'),
		('../giants/zq-repo/zquake/source/Release-GL/zquake-gl.exe', '.'),
		('../giants/Quake-Tools/qutils/qbsp/Release/qbsp.exe', 'bin/'),
		('../giants/Quake-Tools/qutils/light/Release/light.exe', 'bin/'),
		('../giants/Quake-Tools/qutils/vis/Release/vis.exe', 'bin/'),
		('../giants/Quake-Tools/qutils/bspinfo/Release/bspinfo.exe', 'bin/')]

block_cipher = None

a = Analysis(  # noqa 821
	['AudioQuake.py'],
	binaries=binary_files,
	datas=data_files,
	hiddenimports=['pkg_resources.py2_warn'],
	hookspath=[],
	runtime_hooks=[],
	excludes=[],
	win_no_prefer_redirects=False,
	win_private_assemblies=False,
	cipher=block_cipher)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)  # noqa 821

if platform.system() == 'Darwin':
	platform_icon = 'app-support-files/aq.icns'
else:
	platform_icon = 'app-support-files/aq.ico'

exe = EXE(  # noqa 821
	pyz,
	a.scripts,
	exclude_binaries=True,
	name='AudioQuake',
	debug=False,
	strip=False,
	upx=True,
	console=False,
	icon=platform_icon)

coll = COLLECT(  # noqa 821
	exe,
	a.binaries,
	a.zipfiles,
	a.datas,
	strip=False,
	upx=True,
	name='AudioQuake')

if platform.system() == 'Darwin':
	info_plist = {
		'NSRequiresAquaSystemAppearance': 'No'  # Support dark mode
	}
else:
	info_plist = None

app = BUNDLE(  # noqa 821
	coll,
	name='AudioQuake.app',
	icon=platform_icon,
	info_plist=info_plist,
	bundle_identifier=None)
