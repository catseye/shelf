# encoding: UTF-8

# This file is intended to be `source`d (or `.`ed) from `.bashrc` or similar.


### utility functions ###


_shelf_verbose() {
    if [ -e /tmp/.shelf_verbose ]; then
        echo $*
    fi
}

_shelf_show_run() {
    echo $*
    $*
}

_shelf_ln() {
    source="$1"
    dest="$2"
    if [ -e "$dest" ]; then
        _shelf_verbose $dest already exists
    else
        _shelf_show_run ln -s `realpath "$source"` "$dest"
    fi
}

_shelf_link_stuff() {
    dir="$1"
    subdir="$2"
    find_opts="-name .git -prune -o -path Funicular/eg -prune -o -path Chrysoberyl/modules -prune -o -path Chrysoberyl/checkout -prune -o $3"
    skip_pat="$4"
    if [ "X$dir" = X ]; then
        echo "Usage: shelf_link_stuff <dir> <subdir> <find-opts> <skip-pat>"
        return 1
    fi
    _shelf_verbose "find $dir $find_opts"
    for source in `find "$dir" $find_opts`; do
        base=`basename "$source"`
        case "$base" in
            ${skip_pat})
                _shelf_verbose Skipping $base
            ;;
            *)
                _shelf_ln "$source" "$SHELF_FARMBASE/$subdir/$base"
            ;;
        esac
    done
}

_shelf_link_bin() {
    subdir="bin"
    find_opts="-executable -type f"
    skip_pat=".git|depcomp|configure|config.guess|*.h|*.so|*.so.*"
    _shelf_link_stuff "$1" "$subdir" "$find_opts" "$skip_pat"
}

_shelf_link_include() {
    subdir="include"
    find_opts="-name '*.h'"
    skip_pat=".git"
    _shelf_link_stuff "$1" "$subdir" "$find_opts" "$skip_pat"
}

_shelf_link_lib() {
    subdir="lib"
    find_opts="-name '*.so' -o -name '*.so.*'"
    skip_pat=".git"
    _shelf_link_stuff "$1" "$subdir" "$find_opts" "$skip_pat"
}


### public functions ###


shelf_init() {
    if [ "x$SHELF_FARMBASE" = "x" ]; then
        echo "Please export SHELF_FARMBASE environment variable before calling this function."
        return 1
    fi
    if [ "x$SHELF_PATH" = "x" ]; then
        echo "Please export SHELF_PATH environment variable before calling this function."
        return 1
    fi
    export PATH="$SHELF_FARMBASE/bin:$PATH"
    export LD_LIBRARY_PATH="$SHELF_FARMBASE/lib:$LD_LIBRARY_PATH"
    export LIBRARY_PATH="$SHELF_FARMBASE/lib:$LIBRARY_PATH"
    export C_INCLUDE_PATH="$SHELF_FARMBASE/include:$C_INCLUDE_PATH"
    export CPLUS_INCLUDE_PATH="$SHELF_FARMBASE/include:$CPLUS_INCLUDE_PATH"
    export PYTHONPATH="$SHELF_FARMBASE/python:$PYTHONPATH"
    export PKG_CONFIG_PATH="$SHELF_FARMBASE/pkgconfig:$PKG_CONFIG_PATH"
    export LUA_PATH="$SHELF_FARMBASE/lua/?.lua;$LUA_PATH"
    export LUA_CPATH="$SHELF_FARMBASE/lib/?.so;$LUA_CPATH"
}

shelf_link() {
    if [ "X$1" = X ]; then
        echo "Usage: shelf_link {dir}"
        return 1
    fi
    for dir in $*; do
        if [ -e "$dir/install" ]; then
            dir="$dir/install"
        fi
        _shelf_link_bin "$dir"
        _shelf_link_include "$dir"
        _shelf_link_lib "$dir"
    done
}

shelf_unlink() {
    if [ "X$1" = X ]; then
        echo "Usage: shelf_unlink {dir}"
        return 1
    fi
    for dir in $*; do
        dir=`realpath "$dir"`
        for sub in bin include lib; do
            for file in $SHELF_FARMBASE/$sub/*; do
                link=`readlink -f "$file"`
                case $link in
                    ${dir}*)
                        _shelf_show_run rm "$file"
                    ;;
                    *)
                    ;;
                esac
            done
        done
    done
}

shelf_unlink_broken() {
    for sub in bin include lib; do
        for file in $SHELF_FARMBASE/$sub/*; do
            if [ ! -e "$file" ]; then
                _shelf_show_run rm "$file"
            fi
        done
    done
}

shelf_build() {
    dir="$1"
    dir=`realpath "$dir"`
    if [ -x "$dir/build.sh" ]; then
        CWD=`pwd`
        cd $dir
        ./build.sh
        cd $CWD
        return $?
    else
        echo "No heuristic to build this source"
        return 1
    fi
}

shelf_pwd() {
    name="$1"
    path=`echo "$SHELF_PATH" | sed -e 's/:/ /g'`
    for dir in $path; do
        if [ -d "$dir/$name" ]; then
            echo "$dir/$name"
            return 0
        fi
    done
    return 1
}

shelf_cd() {
    name="$1"
    dir=`shelf_pwd $name`
    if [ "x$dir" = "x" ]; then
        echo "No directory found for $name"
        return 1
    fi
    cd $dir
}
