Building AudioQuake
===================

Please ensure you've read and followed the steps in [the main BUILD.md file](../BUILD.md) first.

If you want to build AudioQuake separately, and have the development environment set up already, it's as simple as running:

* **Mac:** `./build-audioquake.py`
* **Windows:** `python build-audioquake.py`

What does `build-audioquake.py` do?
-----------------------------------

1. Converts the user manual, sound legend appendix (so it can be referred to separately), development manuals, README and LICENCE files from Markdown to HTML.
2. Runs [PyInstaller](http://www.pyinstaller.org) to "freeze" the Python code (so that it runs like a normal executable, without requiring Python on the player's computer) and combine it with...
  + The engine, gamecode and map compilation tools (built using the "build-giants.py" script in the root directory).
  + The Level Description Language tools (from the "ldl" subdirectory).
  + The AudioQuake game assets (sounds etc.) from this directory.
  + The Remote console client written in Python, also from this directory.
