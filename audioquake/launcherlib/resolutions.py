"""AudioQuake & LDL Launcher - Customise tab"""
# FIXME: enforce min and max resolutions
import launcherlib.config as config

RESOLUTIONS = [(640, 480), (800, 600), (1024, 768)]
DEFAULT_RESOLUTION_INDEX = 0


def resolution_from_config():
	try:
		index = int(config.resolution())
		x, y = RESOLUTIONS[index]
		return x, y
	except:  # noqa 722
		x, y = RESOLUTIONS[DEFAULT_RESOLUTION_INDEX]
		config.resolution(DEFAULT_RESOLUTION_INDEX)
		return x, y
