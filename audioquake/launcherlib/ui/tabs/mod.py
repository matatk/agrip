"""AudioQuake & LDL Launcher - Mod tab"""
import wx

from launcherlib import dirs
from launcherlib.ui.helpers import \
	add_widget, add_opener_button, pick_file, launch_core, \
	Info, YesNoWithTitle, Error

from qmodlib import QMODFile, InstalledQMOD, BadQMODFileError


class ModTab(wx.Panel):
	def __init__(self, parent, game_controller):
		self.game_controller = game_controller

		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		select_qmod_button = wx.Button(self, -1, 'Play a mod')
		select_qmod_button.Bind(wx.EVT_BUTTON, self.play_mod_handler)
		add_widget(sizer, select_qmod_button)

		install_qmod_button = wx.Button(self, -1, 'Install a mod')
		install_qmod_button.Bind(wx.EVT_BUTTON, self.install_qmod_handler)
		add_widget(sizer, install_qmod_button)

		add_widget(sizer, wx.StaticLine(self, -1))

		add_opener_button(
			self, sizer, 'Development manual',
			dirs.manuals / 'development-manual.html')

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)

	def install_qmod_handler(self, event):
		incoming = pick_file(
			self, "Select a QMOD file", "QMOD files (*.qmod)|*.qmod")
		if incoming:
			try:
				qmod = QMODFile(incoming)
			except BadQMODFileError as err:
				Error(self, f'There is a problem with the QMOD file: {err}.')
				return

			title = qmod.name + ' ' + qmod.version
			desc = qmod.shortdesc + '\n\n' + qmod.longdesc

			if (dirs.data / qmod.gamedir).exists():
				body = desc \
					+ "\n\nThere's already a mod installed in '" \
					+ qmod.gamedir + "'. Do you still want to " \
					+ 'install this mod?'
			else:
				body = desc + '\n\nWould you like to install this mod?'

			answer = YesNoWithTitle(self, title, body)
			if answer == wx.ID_YES:
				qmod.install(dirs.data)
				Info(self, qmod.name + ' installed.')

	def play_mod_handler(self, event):
		mod_dirs = [ini.parent for ini in dirs.data.glob('**/qmod.ini')]
		mod_objs = [InstalledQMOD(mod_dir) for mod_dir in mod_dirs]
		mod_info = [f'{mod.name} {mod.version}' for mod in mod_objs]

		if len(mod_dirs) > 0:
			chooser = wx.SingleChoiceDialog(
				self, 'Installed mods', 'Play mod', mod_info)
			if chooser.ShowModal() == wx.ID_OK:
				index = chooser.GetSelection()
				mod_objs[index].apply_watches()
				launch_core(self, lambda: self.game_controller.launch_mod(
					mod_dirs[index].name))  # only need the leaf dirname
		else:
			Info(self, 'No mods are installed.')
