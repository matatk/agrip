"""AudioQuake Game Launcher - Mod tab"""
from os import path
from glob import glob

import wx

from launcherlib.ui.helpers import \
	add_widget, add_opener_buttons, pick_file, launch_core, \
	Info, YesNoWithTitle, WarnException

from qmodlib import QMODFile


class ModTab(wx.Panel):
	def __init__(self, parent, game_controller):
		self.game_controller = game_controller

		wx.Panel.__init__(self, parent)
		sizer = wx.BoxSizer(wx.VERTICAL)

		select_qmod_button = wx.Button(self, -1, 'Play a mod')
		select_qmod_button.Bind(wx.EVT_BUTTON, self.play_mod)
		add_widget(sizer, select_qmod_button)

		install_qmod_button = wx.Button(self, -1, 'Install a mod')
		install_qmod_button.Bind(wx.EVT_BUTTON, self.install_qmod)
		add_widget(sizer, install_qmod_button)

		add_opener_buttons(self, sizer, {
			'Development manual':
				(path.join('manuals', 'development-manual.html'),),
			'Developer debugging: show all files': ('.',)
		})

		sizer.SetSizeHints(self)
		self.SetSizer(sizer)

	def install_qmod(self, event):
		incoming = pick_file(
			self, "Select a QMOD file", "QMOD files (*.qmod)|*.qmod")
		if incoming:
			try:
				qmod = QMODFile(incoming)
				title = qmod.name + ' ' + qmod.version
				desc = qmod.shortdesc + '\n\n' + qmod.longdesc

				if path.exists(qmod.gamedir):
					body = desc \
						+ "\n\nThere's already a mod installed in '" \
						+ qmod.gamedir + "'. Do you still want to " \
						+ 'install this mod?'
				else:
					body = desc + '\n\nWould you like to install this mod?'

				answer = YesNoWithTitle(self, title, body)
				if answer == wx.ID_YES:
					qmod.install()
					Info(self, qmod.name + ' installed!')
			except:  # noqa E722
				WarnException(self)

	def play_mod(self, event):
		# FIXME check watch on cfg and auto...
		mod_dirs = list(map(lambda ini: path.dirname(ini), glob('**/qmod.ini')))
		if len(mod_dirs) > 0:
			chooser = wx.SingleChoiceDialog(
				self, 'Installed mods', 'Play mod', mod_dirs)
			if chooser.ShowModal() == wx.ID_OK:
				choice = chooser.GetStringSelection()
				launch_core(self, lambda: self.game_controller.launch_mod(choice))
		else:
			Info(self, 'No mods are installed')
