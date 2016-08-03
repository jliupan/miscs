#!/bin/sh
BUILD_REL=build/release
DPKG_O=$BUILD_REL/dpkg.o
CGC_APP_O=$BUILD_REL/cgc-extended-application.o

if [ "$#" -ne 1 ] || ! [ -f "$1" ]; then
  echo "Usage: $0 <c file>"
  exit 1
fi

FILENAME=$1
BASE_FILENAME=$(basename "$FILENAME")
FILE_EXT="${BASE_FILENAME##*.}"
FILE_NAME="${BASE_FILENAME%.*}"


if [ ! -d "$BUILD_REL" ]; then
  # Control will enter here if $DIRECTORY exists.
    mkdir -p $BUILD_REL
fi

if [ ! -f "$FILE_NAME" ]; then
    /bin/rm $FILE_NAME
fi


if [ ! -f "$BUILD_REL/$FILE_NAME.o" ]; then
    /bin/rm $BUILD_REL/$FILE_NAME.o
fi

if [ ! -f "$DPKG_O" ]; then
    echo "The DECREE packages used in the creation of this challenge binary were:" > $DPKG_O.txt
    dpkg --list | grep -i cgc >> $DPKG_O.txt
    /usr/i386-linux-cgc/bin/objcopy --input binary --output cgc32-i386 --binary-architecture i386 $DPKG_O.txt $DPKG_O
fi

if [ ! -f "$CGC_APP_O" ]; then
    echo "The 79533 byte CGC Extended Application follows. Each team participating in CGC must have submitted this completed agreement including the Team Information, the Liability Waiver, the Site Visit Information Sheet and the Event Participation agreement." > $CGC_APP_O.tmp
    cat /usr/share/cb-testing/CGC_Extended_Application.pdf >> $CGC_APP_O.tmp
    /usr/i386-linux-cgc/bin/objcopy --input binary --output cgc32-i386 --binary-architecture i386 $CGC_APP_O.tmp $CGC_APP_O
fi

/usr/i386-linux-cgc/bin/clang -c -DNPATCHED -nostdlib -fno-builtin -nostdinc -Iinclude -Ilib -I/usr/include -O0 -g -Werror -Wno-overlength-strings -Wno-packed -DCGC_BIN_COUNT=0 -o $BUILD_REL/$FILE_NAME.o $FILENAME
/usr/i386-linux-cgc/bin/ld -nostdlib -static -s -o $FILE_NAME -I$BUILD_REL/lib $BUILD_REL/$FILE_NAME.o $DPKG_O $CGC_APP_O -L/usr/lib -lcgc
echo "Compile finished. $FILE_NAME is ready for you.";
