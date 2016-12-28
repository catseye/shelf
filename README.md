shelf
=====

**shelf** is "a package installer which neither packages nor installs".

Work in progress.

shelf aims to replace [toolshelf](https://github.com/catseye/toolshelf).

shelf is written in Bourne shell.

Quick Start
-----------

Put the file `shelf.sh` somewhere, say `$HOME/shelf.sh`.

Add these two lines to the end of your shell startup script (`.bashrc`,
`.bash_profile`, or whatever):

    . $HOME/shelf.sh
    shelf_init $HOME/.local

Then start a new shell for it to take effect.

Usage
-----

The following shell functions are defined by `shelf.sh` and available for use:

*   `shelf_link` *DIR*

*   `shelf_unlink` *DIR*

*   `shelf_unlink_broken`

*   `shelf_build` *DIR*
