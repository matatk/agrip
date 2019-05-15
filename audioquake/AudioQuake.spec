# vim: ft=python
import platform

data_files = [
	('mod-static-files/', 'id1'),
	('downloaded-assets/quake-shareware-1.06', '.'),
	('downloaded-assets/demos', '.'),
	('downloaded-assets/maps', 'id1/maps'),
	('downloaded-assets/mindgrid-audio_quake_2003.09.22/*.txt',
		'mindgrid-docs'),
	('downloaded-assets/mindgrid-audio_quake_2003.09.22/pak2.pak', 'id1'),
	('downloaded-assets/skins/', 'id1/skins'),
	('manuals-converted/', 'manuals'),
	('manuals/agrip.css', 'manuals'),
	('zq-repo/qc/agrip/qwprogs.dat', 'id1/'),
	('zq-repo/qc/agrip/spprogs.dat', 'id1/'),
	('app-support-files/start-rcon.command', '.'),
	('app-support-files/start-server.command', '.')]

if platform.system() != 'Windows':
	binary_files = [
		('zq-repo/zquake/release-mac/zqds', '.'),
		('zq-repo/zquake/release-mac/zquake-glsdl', '.')]
else:
	binary_files = [
		('zq-repo/zquake/source/Release-server/zqds.exe', '.'),
		('zq-repo/zquake/source/Release-GL/zquake-gl.exe', '.')]

block_cipher = None

a = Analysis(['AudioQuake.py'],  # noqa F821
	binaries=binary_files,
	datas=data_files,
	hiddenimports=[],
	hookspath=[],
	runtime_hooks=[],
	excludes=[],
	win_no_prefer_redirects=False,
	win_private_assemblies=False,
	cipher=block_cipher)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)  # noqa F821

if platform.system() != 'Windows':
	platform_icon = 'app-support-files/aq.icns'
else:
	platform_icon = 'app-support-files/aq.ico'

exe = EXE(pyz,  # noqa F821
	a.scripts,
	exclude_binaries=True,
	name='AudioQuake',
	debug=False,
	strip=False,
	upx=True,
	console=False,
	icon=platform_icon)

coll = COLLECT(exe,  # noqa F821
	a.binaries,
	a.zipfiles,
	a.datas,
	strip=False,
	upx=True,
	name='AudioQuake')

app = BUNDLE(coll,  # noqa F821
	name='AudioQuake.app',
	icon=platform_icon,
	bundle_identifier=None)
