# vim: ft=python
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
        ('wrapper-mac/start-rcon.command', '.'),
        ('wrapper-mac/start-server.command', '.')]
binary_files = [
        ('zq-repo/zquake/release-mac/zqds', '.'),
        ('zq-repo/zquake/release-mac/zquake-glsdl', '.')]

block_cipher = None
a = Analysis(['AudioQuake.py'],
             binaries=binary_files,
             datas=data_files,
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          exclude_binaries=True,
          name='AudioQuake',
          debug=False,
          strip=False,
          upx=True,
          console=False,
          icon='wrapper-mac/aq.icns')
coll = COLLECT(exe,
               a.binaries,
               a.zipfiles,
               a.datas,
               strip=False,
               upx=True,
               name='AudioQuake')
app = BUNDLE(coll,
             name='AudioQuake.app',
             icon='wrapper-mac/aq.icns',
             bundle_identifier=None)
