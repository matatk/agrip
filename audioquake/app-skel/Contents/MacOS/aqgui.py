#!/usr/bin/env python
import Tkinter
import sys
import os
import subprocess

class App:
	def __init__(self, master):
		self.master = master
		self.master.title("AudioQuake Launcher")
		self.master.geometry("300x300+100+100")

		btn_launch = Tkinter.Button(
			master,
			command=self.launch,
			width=10,
			text="Frag!"
		)
		btn_launch.pack()

		btn_launch_tut = Tkinter.Button(
			master,
			command=self.launch_tut,
			width=10,
			text="Tutorial"
		)
		btn_launch_tut.pack()

		btn_quit = Tkinter.Button(
			master,
			command=self.quit,
			width=10,
			text="Quit"
		)
		btn_quit.pack()
	
	def launch(self):
		subprocess.call(
			("./zquake-glsdl", "-window", "+set sensitivity 0")
		)
	
	def launch_tut(self):
		subprocess.call(
			("./zquake-glsdl", "-window", "+set sensitivity 0",
				"+coop 0", "+deathmatch 0", "+map agtut01")
		)

	def quit(self):
		self.master.destroy()


if __name__ == '__main__':
	os.chdir(os.path.dirname(sys.argv[0]))
	root = Tkinter.Tk()
	app = App(root)
	root.mainloop()
