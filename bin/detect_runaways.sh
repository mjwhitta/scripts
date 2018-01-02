#!/usr/bin/env bash
# A script to prevent runaway processes.
# by Miles Whittaker <mjwhitta@gmail.com>
#
# --------------------------------------------------------------------
# The MIT License (MIT)
#
# Copyright (c) 2017 Miles Whittaker
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# --------------------------------------------------------------------

usage() {
    echo "Usage: ${0/*\//} [OPTIONS]"
    echo
    echo "Prevent processes from rapidly spawning (sometimes happens"
    echo "with xdg-open)"
    echo
    echo "Options:"
    echo "    -c, --count        Show count of each running command"
    echo "    -h, --help         Display this help message"
    echo "    -m, --max=MAX      Set maximum allowed process count"
    echo "                       (default: $max)"
    echo "    -p, --proc=PROC    Only check processes matching PROC"
    echo
    exit $1
}

declare -a args
unset proc show_count
max="64"

while [[ $# -gt 0 ]]; do
    case "$1" in
        "--") shift && args+=("$@") && break ;;
        "-c"|"--count") show_count="true" ;;
        "-h"|"--help") usage 0 ;;
        "-m"|"--max"*)
            case "$1" in
                "--"*"="*)
                    arg="$(echo "$1" | sed -r "s/[^=]+=//")"
                    [[ -n $arg ]] || usage 1
                    ;;
                *) shift; [[ $# -gt 0 ]] || usage 1; arg="$1" ;;
            esac
            max="$1"
            ;;
        "-p"|"--proc"*)
            case "$1" in
                "--"*"="*)
                    arg="$(echo "$1" | sed -r "s/[^=]+=//")"
                    [[ -n $arg ]] || usage 1
                    ;;
                *) shift; [[ $# -gt 0 ]] || usage 1; arg="$1" ;;
            esac
            proc="$arg"
            ;;
        *) args+=("$1") ;;
    esac
    shift
done
[[ -z ${args[@]} ]] || set -- "${args[@]}"

[[ $# -eq 0 ]] || usage 1

while read c p; do
    if [[ -n $show_count ]]; then
        if [[ -n $proc ]]; then
            case "$p" in
                *"$proc"*) echo "$c $p" ;;
            esac
        else
            echo "$c $p"
        fi
    elif [[ -n $proc ]]; then
        [[ "$p" == "$proc" ]] && [[ $c -ge $max ]] && killall $p
    else
        [[ $c -ge $max ]] && killall $p
    fi
done < <(\ps -e -o comm | tail -n +2 | sort | uniq -c | sort -n -r)
