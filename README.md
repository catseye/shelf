shelf
=====

*Version 0.3-PRE.  Subject to change in backwards-incompatible ways.*

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

If you are using `bash`, you can also configure some nicer tab-completion
by sourcing `shelf_tabcomplete.sh`, i.e. you can also add

    . $HOME/.shelf/shelf_tabcomplete.sh

to your startup script.

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

*   `shelf_dockgh` *USER/PROJECT*
    
    Convenience command which, given the user (or organization) and repository
    name of a repository on Github, clones that repository using `git`, then
    runs `shelf_build` and `shelf_link` on the clone's directory.  This makes
    the most sense if the current directory is on the `SHELF_PATH`, but no
    check is made.

*   `shelf_push` *DEST* *DIR* [*DIR* ...]
    
    Pushes changes from the project in *DIR* to the project of the same basename
    in *DEST*.  Currently only supports git repos.  Always pushes the changes to
    a branch in *DEST* whose name is the name of the current branch in *DIR; if
    there is no such branch configured in *DEST*, it will be fetched first.
    *DEST* should be a directory on the `SHELF_PATH`.

*   `shelf_fanout` *DIR* [*DIR* ...]
    
    Executes a `shelf_push` to every directory on the `SHELF_PATH` that contains
    a project directory that has the same basename as *DIR*.

### Catalog files

In the context of shelf, a _catalog file_ is a text file with one entry per line.
Each entry consists of a directory name, optionally followed by an `@` symbol
followed by a tag name.

Several commands operate on catalog files, which are usually supplied via
standard input.  Some of these commands ignore the tag names.

*   `shelf_populate_from_distfiles` *DIR* < *CATALOG*
    
    Given a directory *DIR* containing tarballs of the project listed in
    *CATALOG*, extract each of those tarballs to a directory of the same
    name in the current directory (assumed to be on `SHELF_PATH`.)

*   `shelf_populate_from_git` *PREFIX* < *CATALOG*
    
    For each of the projects listed in *CATALOG*, prefix *PREFIX* to its
    name and attempt to clone that named object with `git` to a repository
    directory in the current directory (assumed to be on `SHELF_PATH`.)

*   `shelf_cast` *DIR* < *CATALOG*
    
    When executed from a directory containing repositories listed in *CATALOG*,
    create a non-version-controlled directory in *DIR* from each of the listed
    repositories.

*   `shelf_pin` < *CATALOG*
    
    When executed from a directory containing repositories listed in *CATALOG*,
    checks out each repository named in the catalog at the tag or branch given
    by its tag name.

*   `shelf_unpin` < *CATALOG*
    
    When executed from a directory containing repositories listed in *CATALOG*,
    checks out each repository named in the catalog at the tip of its `master`
    branch.

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

### TODO

*   Make a `shelf_pull` to complement `shelf_push`.
*   Make a `shelf_fanin` to complement `shelf_fanout`.
*   Make a `shelf_populate_from_shelf` (`shelf_replicate`?)
*   Would a `shelf_pwd_all` be helpful?  It's in my notes, but I don't know why.

### History

#### 0.3

*   Added tab completion for bash.
*   Made `shelf_push` and `shelf_fanout` fetch the branch first, so new branches
    can be pushed to repositories that don't have them yet.
*   `shelf_fanout` is able to process multiple project directories.

#### 0.2

*   Added `shelf_test`, `shelf_dockgh`, `shelf_push`, `shelf_fanout`,
    `shelf_populate_from_distfiles`, `shelf_populate_from_git`, `shelf_cast`,
    `shelf_pin`, and `shelf_unpin`.
*   `shelf_build` is able to process multiple sources.
*   Fixed bug where `shelf_build` exited immediately on the first error.

#### 0.1

*   Initial version.
