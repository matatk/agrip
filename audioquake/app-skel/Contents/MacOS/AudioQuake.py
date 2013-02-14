#!/usr/bin/env python
import sys
import os
import subprocess
from GUI import Window, Button, application

class SingletonWindow(Window):
	def __init__(self, application, *args, **kwargs):
		super(SingletonWindow, self).__init__(*args, **kwargs)
		self._application = application

		self.auto_position = False
		self.position = (200, 250)
		self.size = (120, 150)
		self.resizable = 0
		self.zoomable = 0

		self.add(Button(
			position = (10, 10), 
			size = (100, 25),
		    title = "Frag!",
			action = self.launch_default
		))
		
		self.add(Button(
			position = (10, 40), 
			size = (100, 25),
		    title = "Tutorial",
			action = self.launch_tutorial
		))

		self.add(Button(
			position = (10, 70), 
			size = (100, 25),
		    title = "Quit",
			action = self.close_cmd
		))
	
	def close_cmd(self):
		self._application.quit_cmd()
	
	def launch_default(self):
		subprocess.call(
			("./zquake-glsdl", "-window", "+set sensitivity 0")
		)

	def launch_tutorial(self):
		subprocess.call(
			("./zquake-glsdl", "-window", "+set sensitivity 0",
				"+coop 0", "+deathmatch 0", "+map agtut01")
		)


if __name__ == '__main__':
	os.chdir(os.path.dirname(sys.argv[0]))
	app = application()
	launcher = SingletonWindow(app)
	launcher.show()
	app.run()
