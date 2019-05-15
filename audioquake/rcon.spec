# vim: ft=python
block_cipher = None

a = Analysis(['rcon.py'],  # noqa F821
	binaries=[],
	datas=[],
	hiddenimports=[],
	hookspath=[],
	runtime_hooks=[],
	excludes=[],
	win_no_prefer_redirects=False,
	win_private_assemblies=False,
	cipher=block_cipher)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)  # noqa F821

exe = EXE(pyz,  # noqa F821
	a.scripts,
	exclude_binaries=True,
	name='rcon',
	debug=False,
	strip=False,
	upx=True,
	console=True)

coll = COLLECT(exe,  # noqa F821
	a.binaries,
	a.zipfiles,
	a.datas,
	strip=False,
	upx=True,
	name='rcon')
