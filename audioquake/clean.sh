#!/bin/bash
echo "AudioQuake Repository Cleanup Script"
echo " $0 gen  -- clean generated files."
echo " $0 most -- clean generated files, ZQ code."
echo " $0 all  -- clean generated files, ZQ code and support files."
echo
echo "generated files: mod and app staging area"
echo "ZQ code: the zquake repository (zqcc, qc and the engine)."
echo "support files: map bsp files, demos, skins, shareware, mindgrid"
echo "  -- they will be re-extracted if the ZIPs are still there"
echo

D_MOD="id1"
D_APP="app-staging"

# Trap help or invalid options
if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ "$1" == "help" ]; then
	exit
fi
if [ "$1" != "gen" ] && [ "$1" != "most" ] && [ "$1" != "all" ]; then
	exit
fi

echo Generated files...
rm -rf $D_MOD $D_APP
echo

if [ "$1" == "most" ] || [ "$1" == "all" ]; then
	echo ZQ Code...
	cd zq-repo
	./agrip-cleanup
	cd - > /dev/null
	echo
fi

if [ "$1" == "all" ]; then
	echo Support files...
	rm -f maps/*bsp
	rm -rf skins demos

	echo Shareware and mindgrid data files...
	rm -rf quake-shareware-1.06 mindgrid-audio_quake_2003.09.22
	echo
fi

echo Cleanup complete!
