#!/bin/sh

INFILE=/dev/null
OUTFILE=/dev/null

exists {
    command -v $1 >/dev/null 2>&1
}

while [ $# -gt 0 ]; do
    case "$1" in
        -i)
            shift
            INFILE="$1"
            ;;
        -o)
            shift
            OUTFILE="$1"
            ;;
        -h|--help)
            echo "$0 -i infile -o outfile"
            ;;
        *)
            INFILE="$1"
    esac
    shift
done

cat << EOF
binary-xfer utility for minicom
Sending file ${INFILE} to ${OUTFILE}
EOF

if (exists pv); then
    pv --force -i 0.25 -B 128  ${INFILE}  2>&1 > ${OUTFILE}
else
    cat ${INFILE} > ${OUTFILE}
fi

cat << EOF

File transfer complete
EOF

sleep 1
