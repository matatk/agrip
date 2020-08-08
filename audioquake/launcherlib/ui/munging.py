"""AudioQuake Game Launcher - Map, texture and WAD munging"""
from io import BytesIO
from os import path
import shutil

from vgio.quake.pak import PakFile, is_pakfile, BadPakFile
from vgio.quake.bsp.bsp29 import Bsp
from vgio.quake import wad

import wx


def do_stuff(progress, pak0, pak1):
	copy_paks(0, 40, progress, pak0, pak1)
	make_quake_wad(40, 100, progress)


def copy_paks(start, end, progress, pak0, pak1):
	update_message(progress, start, 'Copying .pak files')
	for pak in [pak0, pak1]:
		if not is_pakfile(pak):
			raise BadPakFile(f'{pak} is not a .pak file')
	shutil.copy(pak0, 'id1')
	update(progress, start, end, 0.54, 2)  # 18 M
	shutil.copy(pak1, 'id1')
	update(progress, start, end, 2, 2)     # 33 M


def make_quake_wad(start, end, progress):
	bsps = []
	miptextures = []

	# FIXME finer progress

	update_message(progress, start, 'Extracting textures')

	for name in ['pak0.pak', 'pak1.pak']:
		with PakFile(path.join('id1', name), 'r') as pak:
			for item in pak.namelist():
				if item.endswith('.bsp'):
					bsps.append(pak.read(item))

	update(progress, start, end, 1, 3)

	for bsp_data in bsps:
		with Bsp.open(bsp_data) as bsp:
			miptextures += [
				mip for mip in bsp.miptextures if mip and mip.name not in [
					n.name for n in miptextures]]

	update(progress, start, end, 2, 3)

	with wad.WadFile('quake.wad', mode='w') as wad_file:
		for miptex in miptextures:
			if not miptex:
				continue

			buff = BytesIO()
			wad.Miptexture.write(buff, miptex)
			buff.seek(0)

			info = wad.WadInfo(miptex.name)
			info.file_size = 40 + len(miptex.pixels)
			info.disk_size = info.file_size
			info.compression = wad.CompressionType.NONE
			info.type = wad.LumpType.MIPTEX

			wad_file.writestr(info, buff)

	update(progress, start, end, 3, 3)


def update(progress, start, end, step, of):
	progress.Update(start + ((step / of) * (end - start)))
	wx.Yield()


def update_message(progress, start, message):
	progress.Update(start, message)
