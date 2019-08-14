Level Description Language
==========================

You may be interested in [the research paper on Level Description Language](http://hdl.handle.net/2134/4478).

The codebase is presently being modernised (in line with AudioQuake), with LDL being converted to Python 3 and using different Quake map compilation tools. It works on macOS, with Windows support to come.

Longer-term plans include a GUI that can be used from within AudioQuake.

For now, if you want to run it, you need to...

 * Check out this repository.
 * [Build AudioQuake](https://github.com/matatk/agrip/blob/master/audioquake/BUILD.md)
 * Run `make-tools.sh` to compile the Quake map tools.
 * Optionally run `make-doc-html.sh` if you want the latest HTML version of the LDL tutorial (which is written in Markdown).
 * Run `pip3 install -r requirements.txt` to install the dependencies of the LDL tool.

You can then run `./ldl.py`—you'll probably want to run `./ldl.py --help` for more information on how to use it. For playing maps in the version of AudioQuake you built above, you could use the `./ldl.py play` subcommand.

The LDL tutorial will walk you through the syntax and some simple examples.
