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

    if [ "X$dir" = X ]; then
        echo "Usage: _shelf_link_stuff <dir> <subdir> <find-opts>"
        return 1
    fi

    exclude_dirs=".git .hg venv"
    exclude_paths="Funicular/eg Chrysoberyl/modules Chrysoberyl/checkout"
    find_opts=""
    for ed in $exclude_dirs; do
        find_opts="$find_opts -name $ed -prune -o "
    done
    for ep in $exclude_paths; do
        find_opts="$find_opts -path $ep -prune -o "
    done
    find_opts="$find_opts $3"

    _shelf_verbose "find $dir $find_opts"
    for source in `find "$dir" $find_opts`; do
        base=`basename "$source"`
        if [ "X$subdir" = "Xbin" ]; then
            case "$base" in
                *.jpg|*.png|.git|.hg|venv|depcomp|configure|config.guess|*.h|*.so|*.so.*)
                    _shelf_verbose Skipping $base
                ;;
                *)
                    _shelf_ln "$source" "$SHELF_FARMBASE/$subdir/$base"
                ;;
            esac
        elif [ "X$subdir" = "Xinclude" ]; then
            case "$base" in
                *.jpg|*.png|.git|.hg|venv)
                    _shelf_verbose Skipping $base
                ;;
                *)
                    _shelf_ln "$source" "$SHELF_FARMBASE/$subdir/$base"
                ;;
            esac
        elif [ "X$subdir" = "Xlib" ]; then
            case "$base" in
                *.jpg|*.png|.git|.hg|venv)
                    _shelf_verbose Skipping $base
                ;;
                *)
                    _shelf_ln "$source" "$SHELF_FARMBASE/$subdir/$base"
                ;;
            esac
        fi
    done
}

_shelf_link_bin() {
    subdir="bin"
    find_opts="-perm -111 -type f"
    _shelf_link_stuff "$1" "$subdir" "$find_opts"
}

_shelf_link_include() {
    subdir="include"
    find_opts="-name '*.h'"
    _shelf_link_stuff "$1" "$subdir" "$find_opts"
}

_shelf_link_lib() {
    subdir="lib"
    find_opts="-name '*.so' -o -name '*.so.*'"
    _shelf_link_stuff "$1" "$subdir" "$find_opts"
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

_shelf_build() {
    # argument must be absolute path of current directory
    dir=$1
    pwd
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
        cd src && make
    else
        echo "No heuristic to build this source"
    fi
}

shelf_build() {
    if [ "X$1" = X ]; then
        echo "Usage: shelf_build {dir}"
        return 1
    fi

    failures=""

    for dir in $*; do
        project=$dir
        dir=`_shelf_abspath_dir "$dir"`
        (cd $dir && _shelf_build $dir)
        if [ $? -ne 0 ]; then
            failures="$failures $project"
        fi
    done

    if [ "X$failures" = X ]; then
        return 0
    else
        echo "Failures: $failures"
        return 1
    fi
}

_shelf_test() {
    pwd
    # if test command is defined for this, then run it, else
    if [ -x "test.sh" ]; then
        ./test.sh
    else
        echo "No test found for this source"
    fi
}

shelf_test() {
    if [ "X$1" = X ]; then
        echo "Usage: shelf_test {dir}"
        return 1
    fi

    failures=""

    for dir in $*; do
        project=$dir
        dir=`_shelf_abspath_dir "$dir"`
        (cd $dir && _shelf_test)
        if [ $? -ne 0 ]; then
            failures="$failures $project"
        fi
    done

    if [ "X$failures" = X ]; then
        return 0
    else
        echo "Failures: $failures"
        return 1
    fi
}

_shelf_pull_from_dest() {
    # utility function only used internally by _shelf_push()
    src=$1
    branch=$2
    origin=`git remote get-url origin`
    if [ "X$origin" != "X$src" ]; then
        echo "Resetting origin to $src"
        git remote remove origin
        git remote add origin $src
    fi
    git fetch && git checkout $branch && git pull origin $branch
}

_shelf_push() {
    src=$1
    dest=$2
    if [ "$src" = "$dest" ]; then
        echo "'$dest' is same as source directory"
        return 0
    fi
    if [ ! -d "$dest/.git" ]; then
        echo "'$dest' is not a git repository"
        return 1
    fi
    branch=`(cd $src && git symbolic-ref --short HEAD)`
    if [ "X$branch" = X ]; then
        echo "Couldn't determine branch"
        return 1
    fi
    (cd $dest && _shelf_pull_from_dest $src $branch)
}

shelf_push() {
    if [ "X$1" = X ]; then
        echo "Usage: shelf_push dest_shelf {dir}"
        return 1
    fi
    
    dest_shelf=$1
    shift

    if [ "X$1" = X ]; then
        echo "Usage: shelf_push dest_shelf {dir}"
        return 1
    fi

    failures=""

    for dir in $*; do
        dir=`_shelf_abspath_dir "$dir"`
        base=`basename "$dir"`

        _shelf_push $dir "$dest_shelf/$base"

        if [ $? -ne 0 ]; then
            failures="$failures $base"
        fi
    done

    if [ "X$failures" = X ]; then
        return 0
    else
        echo "Failures: $failures"
        return 1
    fi
}

shelf_fanout() {
    path=`echo "$SHELF_PATH" | sed -e 's/:/ /g'`

    for dir in $*; do
        dir=`_shelf_abspath_dir "$dir"`
        base=`basename "$dir"`

        for shelf in $path; do
            if [ "$dir" = "$shelf/$base" ]; then
                continue
            fi
            if [ -d "$shelf/$base" ]; then
                echo "--> $shelf/$base"
                _shelf_push $dir "$shelf/$base"
            fi
        done
    done
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
    w=`command -v $1`
    if [ "x$w" = "x" ]; then
        return 1
    fi
    if [ -L "$w" ]; then
        r=`readlink $w`
        echo "$r"
    else
        echo "$w"
    fi
}

shelf_populate_from_distfiles() {
    # ... taken from The-Platform ...

    src_dir="$1"
    while read -r line; do
        project=`echo $line | awk '{split($0,a,"@"); print a[1]}'`
        tag=`echo $line | awk '{split($0,a,"@"); print a[2]}'`
        if [ -e "$src_dir/$project.tar.gz" ]; then
            tar zxvf $src_dir/$project.tar.gz
        elif [ -e "$src_dir/$project.tgz" ]; then
            tar zxvf $src_dir/$project.tgz
        fi
    done
}

shelf_populate_from_git() {
    git_prefix="$1"
    while read -r line; do
        project=`echo $line | awk '{split($0,a,"@"); print a[1]}'`
        tag=`echo $line | awk '{split($0,a,"@"); print a[2]}'`

        # ... taken from Funicular ...

        url="$git_prefix$project"
        dest=`basename $url`

        if [ ! -d $dest ]; then
            echo -n "$dest: " && git clone $url $dest
        fi

        branch=`cd $dest && git rev-parse --abbrev-ref HEAD`
        if [ "X$branch" != "XHEAD" ]; then
            (echo -n "$dest: " && cd $dest && git pull)
        fi

        if [ "X$tag" != X ]; then
            (echo -n "$dest: " && cd $dest && git checkout $tag)
        fi
    done
}

shelf_mirror_from_git() {
    git_prefix="$1"
    while read -r line; do
        project=`echo $line | awk '{split($0,a,"@"); print a[1]}'`
        tag=`echo $line | awk '{split($0,a,"@"); print a[2]}'`

        url="$git_prefix$project"
        dest=`basename $url`

        if [ ! -d $dest ]; then
            git clone --mirror $url $dest
        fi
        (echo -n "$dest: " && cd $dest && git remote update)
    done
}

shelf_cast() {
    projection_dir=`_shelf_abspath_dir "$1"`

    while read -r line; do
        project=`echo $line | awk '{split($0,a,"@"); print a[1]}'`
        tag=`echo $line | awk '{split($0,a,"@"); print a[2]}'`

        dest_project=$project
        if [ "X$SHELF_LOWERCASE" != X ]; then
            dest_project=`echo $dest_project | tr '[:upper:]' '[:lower:]'`
        fi

        rm -rf "$projection_dir/$dest_project"
        (echo "$projection_dir/$dest_project" && cd $project && git archive --format=tar --prefix=$dest_project/ HEAD | (cd $projection_dir && tar xf -) )
    done
}

shelf_pin() {
    while read -r line; do
        project=`echo $line | awk '{split($0,a,"@"); print a[1]}'`
        tag=`echo $line | awk '{split($0,a,"@"); print a[2]}'`

        dest="$project"
        if [ -d $dest ]; then
            if [ "X$tag" != X ]; then
                (echo -n "$dest: " && cd $dest && git checkout $tag)
            fi
        fi
    done
}

shelf_unpin() {
    while read -r line; do
        project=`echo $line | awk '{split($0,a,"@"); print a[1]}'`
        tag=`echo $line | awk '{split($0,a,"@"); print a[2]}'`

        dest="$project"
        if [ -d $dest ]; then
            (echo -n "$dest: " && cd $dest && git checkout master)
        fi
    done
}

shelf_dockgh() {
    url="https://github.com/$1.git"
    git clone $url
    project=`basename $1`
    shelf_build $project || return 1
    shelf_link $project || return 1
}
