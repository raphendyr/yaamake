#!/bin/sh

usage() {
    echo "usage: $0 [action]"
    echo "  --include-path  - print filename to be included by Makefile"
}

while [ "$1" ]; do
    case "$1" in
        --include-path)
            echo "@@LIBDIR@@/makefile.ext"
            exit 0
            ;;
    esac
    shift
done

usage
exit 1
