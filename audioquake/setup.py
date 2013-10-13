import sys
from cx_Freeze import setup, Executable

# GUI applications require a different base on Windows (the default is for a
# console application).
base = None
if sys.platform == "win32":
    base = "Win32GUI"

setup(
	name = "AudioQuke",
	version = "42",
	options = {
		'build_exe': {
			'includes': ["pyttsx", "pyttsx.drivers.sapi5"],
			'packages': ["win32com.gen_py"]
		}
	},
        executables = [Executable("AudioQuake.py", base=base)]
)
