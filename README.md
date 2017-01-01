shelf
=====

*Work in progress.  Subject to change in backwards-incompatible ways.*

Cat's Eye Technologies' **shelf** is "a package installer which
neither packages nor installs".  It aims to be a replacement for
[toolshelf](https://github.com/catseye/toolshelf), implemented as a
set of Bourne shell functions.

Quick Start
-----------

Put the file `shelf.sh` somewhere, say `$HOME/shelf.sh`.

Add these four lines to the end of your shell startup script (`.bashrc`,
`.bash_profile`, or whatever):

    . $HOME/shelf.sh
    export SHELF_FARMBASE=$HOME/.local                   # see below
    export SHELF_PATH=$HOME/checkout1:$HOME/checkout2    # see below
    shelf_init

Then start a new shell for it to take effect.

`SHELF_FARMBASE` is the directory where the link farms will be created.
On some OSes `$HOME/.local` has a similar purpose, so it can be used here
too.

`SHELF_PATH` should be a colon-separated list of directories where you
will be keeping the source directories you wish to manage using shelf.

Usage
-----

The following shell functions are defined by `shelf.sh` and available for use:

*   `shelf_link` *DIR*
    
    Create links to the relevant files in *DIR*, in the appropriate link farm.

*   `shelf_unlink` *DIR*
    
    Remove, from all link farms, any links to any files found in *DIR*.

*   `shelf_unlink_broken`
    
    Remove, from all link farms, any links that are broken.

*   `shelf_build` *DIR*
    
    Make a best-effort guess at how to build the sources in *DIR*, and try to
    build them using that method.
