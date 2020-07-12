# vim: ft=python
import platform

data_files = [
	('mod-static-files/', 'id1'),
	('manuals-converted/', 'manuals'),
	('manuals/agrip.css', 'manuals'),
	('../giants/zq-repo/qc/agrip/qwprogs.dat', 'id1/'),
	('../giants/zq-repo/qc/agrip/spprogs.dat', 'id1/'),
	('app-support-files/start-rcon.command', '.'),
	('app-support-files/start-server.command', '.'),
	('../ldl/bin/*', 'bin/'),
	('../ldl/style.xml', '.'),
	('../../redist/quake.wad', '.')]

if platform.system() != 'Windows':
	binary_files = [
		('../giants/zq-repo/zquake/release-mac/zqds', '.'),
		('../giants/zq-repo/zquake/release-mac/zquake-glsdl', '.')]
else:
	binary_files = [
		('../giants/zq-repo/zquake/source/Release-server/zqds.exe', '.'),
		('../giants/zq-repo/zquake/source/Release-GL/zquake-gl.exe', '.')]

block_cipher = None

a = Analysis(['AudioQuake.py'],  # noqa F821
	binaries=binary_files,
	datas=data_files,
	hiddenimports=['pkg_resources.py2_warn'],
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

if platform.system() != 'Windows':
	info_plist = {
		'NSRequiresAquaSystemAppearance': 'No'
	}
else:
	info_plist = None

app = BUNDLE(coll,  # noqa F821
	name='AudioQuake.app',
	icon=platform_icon,
	info_plist=info_plist,
	bundle_identifier=None)
