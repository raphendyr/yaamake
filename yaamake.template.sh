#!/bin/sh

LIBDIR="@@LIBDIR@@"
RELEASE="@@RELEASE@@"

name=${0##*/}
if [ "${0##*/}" = "$0" ]; then
    installed=true
elif [ "$(which $name)" = "$0" ]; then
    installed=true
else
    installed=false
fi

usage() {
    echo "usage: $name [action] [options]"
    echo
    echo "  actions:"
    echo "       --include-path  - print filename to be included by Makefile"
    echo "    -i --init-project  - create initial files for your project (Makefile)"
    echo "       --list-versions - List installed versions"
    echo "    -h --help          - This help message"
    echo "    -V --version       - Show yaamake's version'"
    echo
    echo "  options:"
    echo "    -Y --yaal YAAL     - yaal base dir if there is no yaal command in PATH"
    echo "       --make-initial  - Allow uncommited changes on working tree"
    echo "    -R --require X.Y   - Require version to be at least X.Y, but less than (X+1).0"
}


## include-path & list-versions

require_version() {
    req=$1
    # possible versions come from stdin

    major=${req%%.*}
    minor=
    [ "$major" != "$req" ] && minor=${req#*.} && minor=${minor%%.*}

    if [ "$minor" ]; then
        # required with major and minor version
        awk -F. '{ if ($1 == '$major' && $2 >= '$minor') print $0 }' | sort -n | tail -n 1
    elif [ "$major" ]; then
        # required with major version
        awk -F. '{ if ($1 >= '$major') print $0}' | sort -n | tail -n 1
    else
        # newest, no requirement
        sort -n | tail -n 1
    fi
}

list_versions() {
    if [ -e "${LIBDIR}/makefile.ext" ]; then
        cat "${LIBDIR}/VERSION"
    else
        ls "${LIBDIR}" | grep -E '^([0-9]+.?)+$'
    fi
}

include_path() {
    if [ -e "${LIBDIR}/makefile.ext" ]; then
        version=$(list_versions | require_version "$require")
        if [ "$version" ]; then
            echo "${LIBDIR}/makefile.ext"
        else
            echo "${LIBDIR}/makefile_has_invalid_version"
        fi
    else
        version=$(list_versions | require_version "$require")
        if [ "$version" ]; then
            echo "${LIBDIR}/${version}/makefile.ext"
        else
            echo "${LIBDIR}/${version}/no_makefile_with_valid_version_found"
            exit 1
        fi
    fi
    exit 0
}


## init-project

create_makefile() {
    # Makefile
    for f in GNUmakefile makefile Makefile; do
        if [ -e $f ]; then
            echo "$f exists, didn't touch it."
            return 0
        fi
    done

    cat > Makefile <<MAKEFILE
# Target filename
#TARGET := current_dir_name

# Source files c, c++, assembly (.c .cpp .cc .S)
#SRC = first_of(main.* TARGET.*)
#SRC += additional_source.cpp

# Define known board. To list all known boards run 'make boards_list'
#BOARD := teensy2
# If you do not know the board or something is different
#MCU := atmegaXXX
#F_CPU := 16MHz
# run 'make info' to know these values

# List macro defines here (-D for gcc)
#DEFS = -DFOOBAR="foo bar" -DBAZ=baz

MAKEFILE
    if [ "$yaal" ] || [ "$yaal_cmd" ]; then
        cat >> Makefile <<MAKEFILE
# Uncomment if you do not want to have yaal to setup cpu pre-scaler and
# do not want to use void loop(); nor void setup();
#YAAL_NO_INIT = 1

# If you are planning to change cpu.clock (F_CPU) at runtime,
# you should set following option, so yaal methods will get F_CPU at runtime
#DEFS += -DYAAL_UNSTABLE_F_CPU
# NOTE: this could make your code slow and big

MAKEFILE
    fi

    echo "# Here happens all the magic" >> Makefile

    if [ "$yaal" ]; then
        echo "YAAL := \"$yaal\"" >> Makefile
    fi

    if $installed; then
        echo "include \$(shell yaamake --include-path --require $(list_versions | sort -n | tail -n 1))" >> Makefile
    else
        echo "include ${yaamake_path}/makefile.ext" >> Makefile
    fi

    cat >> Makefile <<MAKEFILE

# run 'make help' for information
MAKEFILE

    [ "$git_root" ] && git add Makefile 2>/dev/null || true

    echo "Created Makefile in current path"
}

create_gitignore() {
    if [ "$git_root" ] && ! [ -f "$git_root" ] && ! [ -f "$git_root/.gitignore" ] ; then
        (
            cd "$git_root"
            cat > .gitignore <<GITIGNORE
*~
*.tmp
*.o
*.i
*.m
*.s
*.hex
*.elf
*.eep
*.lss
*.map
*.sym
*.lst
.cache/
GITIGNORE
            git add .gitignore
        )

        echo "Created .gitignore in git root."
    fi
}

create_yaal_main() {
    if [ "$yaal_cmd" ]; then
        for base in main $(basename $(pwd)); do
            for ext in .c .cpp .cc .S; do
                if [ -e "$base$ext" ]; then
                    echo "$base$ext found. Didn't touch it."
                    return 0
                fi
            done
        done

        yaal --initial-main >> main.cpp

        [ "$git_root" ] && git add main.cpp 2>/dev/null || true

        echo "Created main.cpp as output of 'yaal --initial-main'."
    fi
}

init_project() {
    if ! $installed; then
        yaamake_path=${0%/*}
        yaamake_p=$(readlink -e "$yaamake_path")
        if [ "$git_root" ] && [ "${yaamake_p#$git_root}" = "${yaamake_p}" ]; then
            echo "You are executing yaamake out side of your project directory."
            echo "This would result setup where others could build the code."
            echo "Add yaamake as submodule or require installation instead."
            echo "For adding submodule run: git submodule add https://github.com/raphendyr/yaamake.git vendor/yaamake"
            exit 1
        fi
    fi
    yaal_cmd=$(yaal --base-path 2>/dev/null || true)
    if [ "$git_root" ]; then
        initial=$(git status | grep -q -s '^# Initial commit$' && echo yes)
        if ! $make_initial; then
            if [ "$initial" ]; then
                if git status | grep -q -s '^# Changes to be committed:$'; then
                    echo "You have initial commit in progress."
                    echo "Please finish it before running this command."
                    exit 1
                else
                    git commit -m "Initial" --allow-empty >/dev/null
                    echo "Created empty initial commit."
                fi
            fi
            stashed=$(git stash | grep -q -s Saved && echo yes)
        fi
    fi
    if create_makefile && create_gitignore && create_yaal_main; then
        if [ "$git_root" ] && git status | grep "Changes to be committed"; then
            git commit -m 'yaamake --init-project'
        fi
        [ "$stashed" ] && git stash pop
        return 0
    fi
    git reset --hard
    [ "$stashed" ] && git stash pop
    return 1
}



## Argument parsing

get_arg() {
    _t=$1 ; _a1=$2 ; _a2=$3
    _a1c=${_a1#*=}
    if [ "$_a1c" != "$_a1" ]; then
        eval "$_t=$_a1c"
        return 1
    else
        eval "$_t=$_a2"
        return 0
    fi
}

git_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
[ "$git_root" ] && git_root=$(readlink -e "$git_root")
action=
require=
make_initial=false
yaal=
targets=
while [ "$1" ]; do
    case "$1" in
        --include-path)
            action=include_path
            ;;
        --list-versions)
            action=list_versions
            ;;
        --require|--require=*|-R|-R=*)
            get_arg require "$1" "$2" && shift
            ;;
        --init-project|-i)
            action=init_project
            ;;
        --make-initial)
            make_initial=true
            ;;
        --yaal|--yaal=*|-Y|-Y=*)
            get_arg yaal "$1" "$2" && shift
            yaal_p=$(readlink -e "$yaal")
            if [ "$git_root" ] && [ "${yaal_p#$git_root}" = "${yaal_p}" ]; then
                echo "You are linking to yaal, which is outside of your project directory."
                echo "This would result setup where others could build the code."
                echo "Add yaal ad submodule or require installation instead."
                echo "For adding submodule run: git submodule add https://github.com/raphendyr/yaal.git vendor/yaal"
                exit 1
            fi
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        --version|-V)
            echo "$name release $RELEASE"
            echo ""
            echo "yaamake makefile versions:"
            list_versions | sed 's/^/  /'
            exit 0
            ;;
        --)
            shift
            targets=$@
            break
            ;;
        *)
            targets="$targets${targets:+ }$1"
            ;;
    esac
    shift
done

if [ "$action" ]; then
    if [ "$targets" ]; then
        echo "ERROR: invalid arguments: $targets"
        echo
        usage
        exit 3
    fi
    $action
    exit $?
elif [ "$targets" ]; then
    yaamakefile=$(include_path)
    make -f "$yaamakefile" ${yaal:+"YAAL=$yaal"} $targets
    exit $?
else
    usage
    exit 1
fi
