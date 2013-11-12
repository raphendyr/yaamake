#!/bin/sh

LIBDIR="@@LIBDIR@@"

usage() {
    echo "usage: $0 [action] [options]"
    echo
    echo "  actions:"
    echo "       --include-path  - print filename to be included by Makefile"
    echo "    -i --init-project  - create initial files for your project (Makefile)"
    echo "       --make-initial  - Allow uncommited changes on working tree"
    echo
    echo "  options:"
    echo "    -Y --yaal YAAL     - yaal base dir if there is no yaal command in PATH"
}

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

    if [ "$yaal" ]; then
        cat >> Makefile <<MAKEFILE
# Base path of yaal
YAAL := "$yaal"

MAKEFILE
    fi

    cat >> Makefile <<MAKEFILE
# include yaamake's makefile
include \$(shell $0 --include-path)

# run 'make help' for more information
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
.dep/
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
    git_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
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

action=
yaal=
make_initial=false
while [ "$1" ]; do
    case "$1" in
        --include-path)
            echo "$LIBDIR/makefile.ext"
            exit 0
            ;;
        --init-project|-i)
            action=init_project
            ;;
        --make-initial)
            make_initial=true
            ;;
        --yaal|--yaal=*|-Y|-Y=*)
            if [ "${1#*=}" ]; then
                yaal=${1#*=}
            else
                yaal=$2
                shift
            fi
            ;;
        *)
            echo "ERROR: invalid argument: $1"
            echo
            usage
            exit 2
            ;;
    esac
    shift
done

if [ -z "$action" ]; then
    usage
    exit 1
fi

$action
exit $?
