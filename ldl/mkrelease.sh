#!/bin/sh
RELEASE="0.0.3"
PROG_DIR="ldl"
REL_DIR="releases"
REDIST_DIR="redist"

which flip >/dev/null
if [ $? != 0 ]; then
	echo Cannot find the flip utility - please install it.
	exit 42
fi

MAC_DIR="${PROG_DIR}_${RELEASE}_mac"
MAC_REL_DIR="$REL_DIR/$MAC_DIR"

LIN_PPC_DIR="${PROG_DIR}_${RELEASE}_linux-ppc"
LIN_PPC_REL_DIR="$REL_DIR/$LIN_PPC_DIR"

LIN_X86_DIR="${PROG_DIR}_${RELEASE}_linux-x86"
LIN_X86_REL_DIR="$REL_DIR/$LIN_X86_DIR"

WIN_DIR="${PROG_DIR}_${RELEASE}_win32"
WIN_REL_DIR="$REL_DIR/$WIN_DIR"

echo === Common Tasks ===
echo
echo Cleaning up...
rm -fv *.pyc
echo Converting POD documentation...
pod2html ldl.pod > ldl.html
pod2text ldl.pod > ldl.tutorial
rm pod2*tmp
echo

cd ..

echo === Making Mac Release ===
echo
echo Copying directory...
cp -R $PROG_DIR $MAC_REL_DIR
echo Copying in WAD file...
rm $MAC_REL_DIR/quake.wad
cp $REDIST_DIR/quake.wad $MAC_REL_DIR
echo Copying in executables...
cp $REDIST_DIR/qbsp.mac $MAC_REL_DIR/qbsp
cp $REDIST_DIR/light.mac $MAC_REL_DIR/light
cp $REDIST_DIR/vis.mac $MAC_REL_DIR/vis
echo Removing Bazaar info...
rm -rf $MAC_REL_DIR/.bzr/
echo Tarballing release...
cd $REL_DIR
tar zcvf $MAC_DIR.tar.gz $MAC_DIR > /dev/null
echo Removing directory...
rm -rf $MAC_DIR
cd -
echo

echo === Making Linux/PowerPC Release ===
echo
echo Copying directory...
cp -R $PROG_DIR $LIN_PPC_REL_DIR
echo Copying in WAD file...
rm $LIN_PPC_REL_DIR/quake.wad
cp $REDIST_DIR/quake.wad $LIN_PPC_REL_DIR
echo Copying in executables...
cp $REDIST_DIR/qbsp.x86 $LIN_PPC_REL_DIR/qbsp
cp $REDIST_DIR/light.x86 $LIN_PPC_REL_DIR/light
cp $REDIST_DIR/vis.x86 $LIN_PPC_REL_DIR/vis
echo Removing Bazaar info...
rm -rf $LIN_PPC_REL_DIR/.bzr/
echo Tarballing release...
cd $REL_DIR
tar zcvf $LIN_PPC_DIR.tar.gz $LIN_PPC_DIR > /dev/null
echo Removing directory...
rm -rf $LIN_PPC_DIR
cd -
echo

echo === Making Linux/x86 Release ===
echo
echo Copying directory...
cp -R $PROG_DIR $LIN_X86_REL_DIR
echo Copying in WAD file...
rm $LIN_X86_REL_DIR/quake.wad
cp $REDIST_DIR/quake.wad $LIN_X86_REL_DIR
echo Copying in executables...
cp $REDIST_DIR/qbsp.x86 $LIN_X86_REL_DIR/qbsp
cp $REDIST_DIR/light.x86 $LIN_X86_REL_DIR/light
cp $REDIST_DIR/vis.x86 $LIN_X86_REL_DIR/vis
echo Removing Bazaar info...
rm -rf $LIN_X86_REL_DIR/.bzr/
echo Tarballing release...
cd $REL_DIR
tar zcvf $LIN_X86_DIR.tar.gz $LIN_X86_DIR > /dev/null
echo Removing directory...
rm -rf $LIN_X86_DIR
cd -
echo

echo === Making Windows Release ===
echo
echo Copying directory...
cp -R $PROG_DIR $WIN_REL_DIR
echo Copying in WAD file...
rm $WIN_REL_DIR/quake.wad
cp $REDIST_DIR/quake.wad $WIN_REL_DIR
echo Copying in executables...
cp $REDIST_DIR/qbsp.exe $REDIST_DIR/light.exe $REDIST_DIR/vis.exe $WIN_REL_DIR
echo Removing Bazaar info...
rm -rf $WIN_REL_DIR/.bzr/
cd $REL_DIR
echo Converting Text Tutorial...
mv $WIN_DIR/ldl.tutorial $WIN_DIR/ldl.txt
flip -m $WIN_DIR/ldl.txt
echo ZIPing release...
mv $WIN_DIR ldl  # so that the test.bat file works
zip -9r $WIN_DIR.zip ldl > /dev/null
echo Removing directory...
rm -rf ldl/

echo
echo Done!
