`shelf`
=======

_Version 0.7_
| _Entry_ [@ catseye.tc](https://catseye.tc/node/shelf)
| _See also:_ [ellsync](https://codeberg.org/catseye/ellsync#ellsync)
∘ [tagfarm](https://codeberg.org/catseye/tagfarm#tagfarm)
∘ [yastasoti](https://codeberg.org/catseye/yastasoti#yastasoti)

- - - -

Cat's Eye Technologies' **shelf** is "a package installer which
neither packages nor installs".  It aims to be a replacement for
[toolshelf](https://catseye.tc/node/toolshelf), implemented as a
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
    
    Essentially the same as `command -v` but, if the found file is a symbolic
    link, the link destination is output instead.  Thus, if *NAME* is
    an executable in your link farm, the file in the originating project
    will be shown.

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
    name in the current directory.
    
    The current directory is assumed to be on `SHELF_PATH`.

*   `shelf_populate_from_git` *PREFIX* < *CATALOG*
    
    For each of the projects listed in *CATALOG*, prefix *PREFIX* to its
    name and, if a corresponding directory exists in the current directory,
    update the repository in that corresponding directory using `git pull`,
    otherwise attempt to `git clone` the repository to that corresponding
    directory in the current directory.
    
    The current directory is assumed to be on `SHELF_PATH`.

*   `shelf_mirror_from_git` *PREFIX* < *CATALOG*
    
    The same as `shelf_populate_from_git`, but uses `git clone --mirror` to
    clone each new repo directory, and `git remote update` to update it.

*   `shelf_cast` *DIR* < *CATALOG*
    
    When executed from a directory containing repositories listed in *CATALOG*,
    create a non-version-controlled directory in *DIR* from each of the listed
    repositories, at the tag or branch given by its tag name.

    Two environment variables affect the operation of `shelf_cast`:

    `SHELF_LOWERCASE`, if set, causes the casted directory to be created as
    the lower-cased version of the catalog entry name.

    `SHELF_CAST_REF`, if set, overrides the tag given in the catalog entry.

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
*   Configure list of dirs to skip when linking, in an env var

### History

#### 0.7

*   Fixed a bug in `shelf_link` where links were not being correctly
    made to files with spaces in their pathnames.

#### 0.6

*   `shelf_cast`, by default, now casts the version of the source
    repository at the tag given in each catalog entry, instead of
    always casting `HEAD`.  Setting the environment variable
    `SHELF_CAST_REF` to `HEAD` can override this new behaviour.
*   Made `shelf_populate_from_git` and `shelf_pin` record a list of
    directories which they failed to process, and fail themselves at the
    end of procssing if that list is not empty.

#### 0.5

*   Changed `shelf_which` to [not use the which command][] and to produce
    cleaner output (only show the target executable file).
*   Introduced `shelf_mirror_from_git`.
*   Commands which work on catalog files output the name of each directory
    just before they process it, making the output more sensible to read.

#### 0.4

*   Fixed a bug where it was trying to link `.git` directories and other
    inappropriate files because a pattern wasn't being correctly applied.
*   `venv` (Python virtualenv directory) and `.hg` (Mercurial directory)
    are now skipped when finding files to link.

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

[not use the which command]: https://unix.stackexchange.com/questions/85249/why-not-use-which-what-to-use-then
