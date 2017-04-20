# encoding: UTF-8

# This file is intended to be `source`d (or `.`ed) from `.bashrc` or similar.


### utility functions ###


_shelf_verbose() {
    if [ "X$SHELF_VERBOSE" != X ]; then
        echo $*
    fi
}

_shelf_show_run() {
    if [ "X$SHELF_DRYRUN" != X ]; then
        echo "$* (DRY RUN)"
    else
        echo $*
        $*
    fi
}

_shelf_abspath_dir() {
    CWD=`pwd`
    cd "$1"
    pwd
    cd "$CWD"
}

_shelf_abspath_file() {
    dir=`dirname $1`
    dir=`_shelf_abspath_dir "$dir"`
    base=`basename $1`
    echo "$dir/$base"
}

_shelf_ln() {
    source=`_shelf_abspath_file "$1"`
    _shelf_verbose "linking to $1 which absolutized as $source"
    dest="$2"
    if [ -e "$dest" ]; then
        _shelf_verbose $dest already exists
    else
        _shelf_show_run ln -s "$source" "$dest"
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
            *.jpg|*.png)
                _shelf_verbose Skipping $base
            ;;
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
    find_opts="-perm -111 -type f"
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
        dir=`_shelf_abspath_dir "$dir"`
        for sub in bin include lib; do
            for file in $SHELF_FARMBASE/$sub/*; do
                link=`readlink -f "$file"`
                _shelf_verbose "in $dir found link $link"
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
            if [ "$file" = "$SHELF_FARMBASE/$sub/*" ]; then
                echo "Directory $SHELF_FARMBASE/$sub is empty, skipping"
            elif [ ! -e "$file" ]; then
                _shelf_show_run rm "$file"
            fi
        done
    done
}

shelf_build() {
    CWD=`pwd`

    dir=`_shelf_abspath_dir "$1"`
    cd $dir

    # if build command is defined for this, then run it, else
    if [ -x "build.sh" ]; then
        ./build.sh
    elif [ -x "make.sh" ]; then
        ./make.sh
    elif [ -e "build.xml" ]; then
        ant
    elif [ -e "configure" ]; then
        ./configure --prefix=$dir/install && make && make install
    elif [ -e "configure.in" ]; then
        autoconf && ./configure --prefix=$dir/install && make && make install
    elif [ -e "autogen.sh" ]; then
        ./autogen.sh && autoconf && ./configure --prefix=$dir/install && make && make install
    elif [ -e "Makefile" ]; then
        make
    elif [ -e "src/Makefile" ]; then
        cd src
        make
    else
        echo "No heuristic to build this source"
        return 1
    fi

    cd $CWD
    return $?
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

shelf_which() {
    w=`which $1`
    if [ "x$w" = "x" ]; then
        return 1
    fi
    if [ -L "$w" ]; then
        r=`readlink $w`
        echo "$w -> $r"
    else
        echo "$w"
    fi
}
