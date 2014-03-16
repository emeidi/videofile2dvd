#!/bin/sh

# Original version: http://www.lamolabs.org/blog/4582/one-liner-how-to-burn-an-m4v-or-mp4-file-to-a-dvd-under-linux-fedora-centos-rhel-debian-ubuntu/, slmingol, 2010
# Modified version: Mario Aeby, eMeidi.com, 2014

if [ $# -lt 1 ]
then
	echo "Usage: $0 <videofile>"
	exit 1
fi

#https://bbs.archlinux.org/viewtopic.php?pid=876963#p876963
export VIDEO_FORMAT=PAL

FFMPEG=$(which ffmpeg)
DVDAUTHOR=$(which dvdauthor)
MKISOFS=$(which mkisofs)

INPUTFILE="$1"
MPEG2FILE="dvd.mpg"

DVDTMPFOLDER="dvd"
DVDIMAGE="dvd.iso"

FFMPEGTARGET="pal-dvd" #Use ntsc-dvd for North America

if [ ! -f "$INPUTFILE" ]
then
	echo "ERROR: File '$1' not found. Aborting."
	exit 1
fi

if [ ! -e "$FFMPEG" ]
then
	echo "ERROR: Executable '$FFMPEG' (ffmpeg) not found or not executable. Please install. Aborting."
	exit 1
fi

if [ ! -e "$DVDAUTHOR" ]
then
	echo "ERROR: Executable '$DVDAUTHOR' (dvdauthor) not found or not executable. Please install. Aborting."
	exit 1
fi

if [ ! -e "$MKISOFS" ]
then
	echo "ERROR: Executable '$MKISOFS' (mkisofs) not found or not executable. Please install. Aborting."
	exit 1
fi

# Step 1
# ===================================================================
CMD="$FFMPEG -i \"$INPUTFILE\" -target \"$FFMPEGTARGET\" \"$MPEG2FILE\""
echo "Converting '$INPUTFILE' to MPEG2 at '$MPEG2FILE' ..."
echo $CMD
echo ""

if [ -f "$MPEG2FILE" ]
then
	echo "'$MPEG2FILE' already exists. Skipping conversion (delete the file if you want to re-encode it from scratch)."
	echo ""
else
	eval $CMD
fi

echo "Done."
echo ""
 
# Step 2
# ===================================================================
CMD="$DVDAUTHOR --title -o \"$DVDTMPFOLDER\" -f \"$MPEG2FILE\""
echo "Creating DVD folder structure in subfolder '$DVDTMPFOLDER' ..."
echo $CMD
echo ""

eval $CMD

echo "Done."
echo ""

CMD="$DVDAUTHOR -o \"$DVDTMPFOLDER\" -T"
echo "Creating DVD table of contents in subfolder '$DVDTMPFOLDER' ..."
echo $CMD
echo ""

eval $CMD

echo "Done."
echo ""

 
# Step 3
# ===================================================================
CMD="$MKISOFS -dvd-video -o \"$DVDIMAGE\" \"$DVDTMPFOLDER\""
echo "Creating ISO dvd image at './$DVDIMAGE' from subfolder '$DVDTMPFOLDER' ..."
echo $CMD
echo ""

eval $CMD

echo "Done."
echo ""

exit 0