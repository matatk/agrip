"""AudioQuake & LDL Launcher - Date of Birth check"""
import datetime

import wx
from dateutil.relativedelta import relativedelta

from launcherlib.ui.helpers import Error, add_widget


def dobcheck():
	with _DoBCheck(None) as dialog:
		if dialog.ShowModal() == wx.ID_OK:
			date_of_birth = datetime.date(
				_component(dialog.year),
				_component(dialog.month),
				_component(dialog.day))

			today = datetime.date.today()

			if relativedelta(today, date_of_birth).years >= 15:
				return True

			Error(None, "Sorry, but you're not permitted to play Quake.")
			return False

		Error(None, 'You must enter a date of birth.')
		return False


def _component(control):
	return int(control.GetString(control.GetCurrentSelection()))


class _DoBCheck(wx.Dialog):
	def __init__(self, parent):
		wx.Dialog.__init__(
			self, parent, style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER,
			title='Date of birth')

		sizer = wx.BoxSizer(wx.VERTICAL)

		# Date input grouping

		date_input = wx.StaticBoxSizer(
			wx.VERTICAL, self, 'Please input your date of birth')

		add_widget(date_input, wx.StaticText(
			self, -1, 'This information will not be transmitted or stored.'))

		def make_component(label, values):
			hbox = wx.BoxSizer(wx.HORIZONTAL)
			label = wx.StaticText(self, label=f'{label}: ')
			pick = wx.Choice(self, -1, choices=values)
			# pick.SetSelection(0)  # Needed on Windows FIXME
			add_widget(hbox, label, border=False)
			add_widget(hbox, pick, border=False, expand=True)
			add_widget(date_input, hbox)
			return pick

		self.day = make_component('Day', list(map(str, range(1, 32))))
		self.month = make_component('Month', list(map(str, range(1, 13))))
		self.year = make_component(
			'Year', list(map(str, reversed(range(1903, 2022)))))

		sizer.Add(date_input, 1, wx.EXPAND, 10)

		# Done button

		done = wx.Button(self, -1, 'Done')
		done.Bind(wx.EVT_BUTTON, lambda event: self.EndModal(wx.ID_OK))
		add_widget(sizer, done)

		# Wiring

		self.SetSizer(sizer)
		self.Fit()
