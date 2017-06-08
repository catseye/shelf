shelf
=====

*Version 0.1.  Subject to change in backwards-incompatible ways.*

Cat's Eye Technologies' **shelf** is "a package installer which
neither packages nor installs".  It aims to be a replacement for
[toolshelf](https://github.com/catseye/toolshelf), implemented as a
set of Bourne shell functions.

Quick Start
-----------

Download the file `shelf.sh` and put it somewhere, say `$HOME/shelf.sh`.

Or better, clone this repo as `$HOME/.shelf`; then the file `shelf.sh`
will be at `$HOME/.shelf/shelf.sh`, and you can pull the latest changes
with `cd $HOME/.shelf && git pull origin master`.

Then add these four lines to the end of your shell startup script
(`.bashrc`, `.bash_profile`, or whatever):

    . $HOME/.shelf/shelf.sh
    export SHELF_FARMBASE=$HOME/.local                   # see below
    export SHELF_PATH=$HOME/checkout1:$HOME/checkout2    # see below
    shelf_init

Then start a new shell for it to take effect.

`SHELF_FARMBASE` is the directory where the link farms will be created.
On some OSes `$HOME/.local` has a similar purpose, so it can be used here
too.  (Although note, the wisdom of doing that has not been fully vetted.)

`SHELF_PATH` should be a colon-separated list of directories where you
will be keeping the source directories you wish to manage using shelf.

Usage
-----

The following shell functions are defined by `shelf.sh` and available for use:

*   `shelf_link` *DIR* [*DIR* ...]
    
    Create links to the relevant files in *DIR*, in the appropriate link farm.
    One or more *DIR*s may be given.

*   `shelf_unlink` *DIR* [*DIR* ...]
    
    Remove, from all link farms, any links to any files found in *DIR*.
    One or more *DIR*s may be given.

*   `shelf_unlink_broken`
    
    Remove, from all link farms, any links that are broken.

*   `shelf_build` *DIR* [*DIR* ...]
    
    Make a best-effort guess at how to build the sources in *DIR*, and try to
    build them using that method.  One or more *DIR*s may be given.

*   `shelf_test` *DIR* [*DIR* ...]
    
    Make a best-effort guess at how to run tests for the project in *DIR*, then
    run the tests using that method.  One or more *DIR*s may be given.

*   `shelf_pwd` *NAME*
    
    Print out the full path of the first directory on `SHELF_PATH` with name
    *NAME*, if one exists, else print nothing and return an error code 1.

*   `shelf_cd` *NAME*
    
    Change directory to the first directory on `SHELF_PATH` with name *NAME*,
    if one exists, else display an error message and return an error code 1.

*   `shelf_which` *NAME*
    
    Essentially the same as `which` but, if the found file is a symbolic link,
    display the filename that the link points to as well.

*   `shelf_populate_from_distfiles` *DIR* < *CATALOG*
    
    TBW

*   `shelf_populate_from_git` *PREFIX* < *CATALOG*
    
    TBW

*   `shelf_cast_projection` *DIR* < *CATALOG*
    
    TBW

*   `shelf_pin` < *CATALOG*
    
    TBW

*   `shelf_unpin` < *CATALOG*
    
    TBW

*   `shelf_dockgh` *USER/PROJECT*
    
    TBW

*   `shelf_push` *DEST* *DIR* [*DIR* ...]
    
    *DEST* should be a directory on the `SHELF_PATH`.

### Catalog files

In the context of shelf, a _catalog file_ is a text file with one entry per line.
Each entry consists of a directory name, optionally followed by an `@` symbol
followed by a tag name.

Several commands operate on catalog files, which are usually supplied via
standard input.  Some of these commands ignore the tag names.

### Environment variables

*   `SHELF_VERBOSE`
    
    If this environment variable is set to any non-empty value, the `shelf_*`
    functions will produce verbose messages on standard output about what they
    are doing, which can be useful for troubleshooting.

*   `SHELF_DRYRUN`
    
    If this environment variable is set to any non-empty value, the `shelf_*`
    functions will not make significant changes to the state of the
    filesystem (for example, running commands like `ln` and `rm`) and instead
    will only report that such changes would be made.
