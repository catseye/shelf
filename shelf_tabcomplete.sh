# tab-completion setup for shelf in bash
# source this file after shelf has been loaded.
# note, I do not claim to entirely know what I'm doing here.

function _shelf_cd_tabcomplete_()
{
    local cmd="${1##*/}"
    local word=${COMP_WORDS[COMP_CWORD]}
    local line=${COMP_LINE}

    local path=`echo "$SHELF_PATH" | sed -e 's/:/ /g'`
    local subdirs=''
    for d in $path; do
        if [ -d $d ]; then
            these=`ls $d`
            subdirs="$subdirs $these"
        fi
    done

    COMPREPLY=($(compgen -W "${subdirs}" "${word}"))
}

complete -F _shelf_cd_tabcomplete_ shelf_cd


function _shelf_which_tabcomplete_()
{
    local cmd="${1##*/}"
    local word=${COMP_WORDS[COMP_CWORD]}
    local line=${COMP_LINE}

    local path=`echo "$SHELF_PATH" | sed -e 's/:/ /g'`
    local files=`ls $SHELF_FARMBASE/bin`

    COMPREPLY=($(compgen -W "${files}" "${word}"))
}

complete -F _shelf_which_tabcomplete_ shelf_which
