# -*- mode: sh; -*-

declare -A CMD_HANDLERS
CMD_HANDLERS=(
    ["init"]=_repo_init
    ["help"]=_repo_help
    ["abandon"]=_repo_abandon
    ["branch"]=_repo_branch
    ["branches"]=_repo_branches
    ["checkout"]=_repo_checkout
    ["cherry-pick"]=_repo_cherry_pick
    ["diff"]=_repo_diff
    ["download"]=_repo_download
    ["forall"]=_repo_forall
    ["grep"]=_repo_grep
    ["list"]=_repo_list
    ["prune"]=_repo_prune
    ["rebase"]=_repo_rebase
    ["selfupdate"]=_repo_selfupdate
    ["smartsync"]=_repo_smartsync
    ["stage"]=_repo_stage
    ["start"]=_repo_start
    ["status"]=_repo_status
    ["sync"]=_repo_sync
    ["upload"]=_repo_upload
    ["version"]=_repo_version
)

# To be populated by command handlers.
declare -a OPTIONS
declare -A ARG_OPTIONS

declare cur
declare prev

_init_cur_prev() {
    cur=$(_get_cword "=")
    prev=$(_get_cword "=" 1)

    _split_longopt
}

_find_repo() {
    local dir=$(pwd)
    local found=1

    while [ "${dir}" != / ]
    do
        if [ -e "${dir}/.repo/repo/main.py" ]
        then
            found=0
            break
        fi

        dir=$(cd "${dir}/.." && pwd)
    done

    if [ ${found} -eq 0 ]
    then
        echo "${dir}"
    fi
}

_is_repo_dir() {
    local repo_root=$(_find_repo)

    [ -n "${repo_root}" ]
}

_gen_comps() {
    local completions="$1"
    local suffix="${2:- }"

    local -i i
    local -a tmp=( $(compgen -W "${completions}" -- ${cur}) )

    for (( i=0; i < ${#tmp[*]}; i++ ))
    do
        tmp[$i]="${tmp[$i]}${suffix}"
    done

    COMPREPLY=(
        "${COMPREPLY[@]}"
        "${tmp[@]}"
    )
}

_strip_colors () {
    # taken from http://goo.gl/7KlLZ
    sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
}

_no_completion() {
    true
}

_command_completion() {
    local cmds

    if _is_repo_dir
    then
        cmds=("abandon" "branch" "branches" "checkout" "cherry-pick" "diff"
            "download" "forall" "grep" "help" "init" "list" "prune" "rebase"
            "selfupdate" "smartsync" "stage" "start" "status" "sync"
            "upload" "version")
    else
        cmds=("help" "init")
    fi

    _gen_comps "${cmds[*]}"
}

_branch_completion() {
    local raw_branches

    # separate statement required to be able to access exit code
    raw_branches=$(repo branches 2>/dev/null)

    if [ $? -eq 0 ]
    then
        local branches=$(
            echo "${raw_branches}" |
            _strip_colors | awk 'BEGIN { FS="|" } { print $1 }' | cut -c 3-
        )

        _gen_comps "${branches}"
    fi
}

_dir_completion() {
    _filedir -d
}

_project_completion() {
    local repo_root=$(_find_repo)

    if [ -n "${repo_root}" -a -f "${repo_root}/.repo/project.list" ]
    then
        local projects=$(cat "${repo_root}/.repo/project.list")
        _gen_comps "${projects}"
    fi
}

_manifest_completion() {
    local repo_root=$(_find_repo)

    if [ -n "${repo_root}" ]
    then
        local manifests_dir="${repo_root}/.repo/manifests"
        local git_dir="${manifests_dir}/.git"
        local candidates

        manifests=$(
            git --git-dir "${git_dir}" ls-files "*.xml" 2>/dev/null)

        if [ $? -eq 0 ]
        then
            _gen_comps "${manifests}"
        fi
    fi
}

_path_cmd_completion() {
    _gen_comps "$(compgen -c ${cur})"
}

_is_option() {
    local opt="$1"

    [[ "${opt}" == -* ]]
}

_is_long_option() {
    local opt="$1"

    [[ "${opt}" == --* ]]
}

_expects_arg() {
    local opt="$1"

    if [[ ${ARG_OPTIONS[$opt]} ]]
    then
        return 0
    else
        return 1
    fi
}

_handle_options() {
    if _expects_arg "${prev}"
    then
        local handler=${ARG_OPTIONS[$prev]}
        eval ${handler} "${cur}"
    elif _is_option "${cur}"
    then
        _gen_comps "${OPTIONS[*]}"

        local arg_short
        local arg_long

        for opt in "${!ARG_OPTIONS[@]}"
        do
            if _is_long_option "${opt}"
            then
                arg_long="${arg_long} ${opt}"
            else
                arg_short="${arg_short} ${opt}"
            fi
        done

        _gen_comps "${arg_short}"
        _gen_comps "${arg_long}" "="
    else
        return 1
    fi

    return 0
}

_is_known_shortopt() {
    local needle="$1"

    for opt in ${OPTIONS[@]}
    do
        if [ "${opt}" = "${needle}" ]
        then
            return 0
        fi
    done

    return 1
}

_is_known_longopt() {
    local needle="$1"

    [[ ${ARG_OPTIONS[$1]} ]]
}

_arg_index() {
    local -i i=2               # skip repo and command
    local -i ix=0

    while [ ${i} -lt ${COMP_CWORD} ]
    do
        if _is_known_shortopt "${COMP_WORDS[i]}"
        then
            i+=1
        elif _is_known_longopt "${COMP_WORDS[i]}"
        then
            i+=2
        elif _is_option "${COMP_WORDS[i]}"
        then
            i+=1
        else
            i+=1
            ix+=1
        fi
    done

    eval $1="${ix}"
}

_when_ix() {
    local ix="$1"
    local completion="$2"

    _arg_index arg_ix

    if [ ${arg_ix} -eq ${ix} ]
    then
        ${completion}
        return 0
    else
        return 1
    fi
}

_when_first() {
    _when_ix 0 "$1"
}

_when_even() {
    local completion="$1"

    _arg_index arg_ix

    if [ $(( ${arg_ix} % 2 )) -eq 0 ]
    then
        ${completion}
        return 0
    else
        return 1
    fi
}

_cmp_opts() {
    local opt="$1"
    local word="$2"

    if _is_option "${opt}" && ! _is_long_option "${opt}"
    then
        [ "${word}" == "${opt}" ]
    else
        [[ "${word}" == "${opt}"=* || "${word}" == "${opt}" ]]
    fi
}

_before() {
    local completion="$1"
    local words

    shift

    _get_comp_words_by_ref -n = words

    for word in "${words[@]}"
    do
        for needle in "$@"
        do
            if _cmp_opts "${needle}" "${word}"
            then
                return 1
            fi
        done
    done

    ${completion}
    return 0
}

_repo_init() {
    OPTIONS=(
        "-h" "--help"
        "-q" "--quite"
        "--mirror"
        "--no-repo-verify"
    )

    ARG_OPTIONS=(
        ["-u"]=_no_completion
        ["--manifest-url"]=_no_completion
        ["-b"]=_no_completion
        ["--manifest-branch"]=_no_completion
        ["-m"]=_manifest_completion
        ["--manifest-name"]=_manifest_completion
        ["--reference"]=_dir_completion
        ["--repo-url"]=_no_completion
        ["--repo-branch"]=_no_completion
    )

    _handle_options
}

_repo_help() {
    OPTIONS=(
        "-a" "--all"
        "-h" "--help"
    )

    ARG_OPTIONS=()

    _handle_options || _when_first _command_completion
}

_repo_abandon() {
    OPTIONS=(
        "-h" "--help"
    )

    ARG_OPTIONS=()

    _handle_options || _when_first _branch_completion || _project_completion
}

_repo_branch() {
    OPTIONS=(
        "-h" "--help"
    )

    ARG_OPTIONS=()

    _handle_options
}

_repo_branches() {
    OPTIONS=(
        "-h" "--help"
    )

    ARG_OPTIONS=()

    _handle_options
}

_repo_checkout() {
    OPTIONS=(
        "-h" "--help"
    )

    ARG_OPTIONS=()

    _handle_options || _when_first _branch_completion || _project_completion
}

_repo_cherry_pick() {
    OPTIONS=(
        "-h" "--help"
    )

    ARG_OPTIONS=()

    _handle_options
}

_repo_diff() {
    OPTIONS=(
        "-h" "--help"
    )

    ARG_OPTIONS=()

    _handle_options || _project_completion
}

_repo_download() {
    OPTIONS=(
        "-h" "--help"
    )

    ARG_OPTIONS=()

    _handle_options || _when_even _project_completion
}

_repo_forall() {
    OPTIONS=(
        "-h" "--help"
        "-p"
        "-v" "--verbose"
    )

    ARG_OPTIONS=(
        ["-c"]=_path_cmd_completion
        ["--command"]=_path_cmd_completion
    )

    _handle_options || _before _project_completion -c --command || _filedir
}

_repo_grep() {
    OPTIONS=(
        "-h" "--help"
        "--cached"
        "-r" "--revision"
        "-i" "--ignore-case"
        "-a" "--text"
        "-I"
        "-w" "--word-regexp"
        "-v" "--invert-match"
        "-G" "--basic-regexp"
        "-E" "--extended-regexp"
        "-F" "--fixed-strings"
        "--all-match"
        "--and" "--or" "--not"
        "-(" "-)"
        "-n"
        "-l" "--name-only" "--files-with-matches"
        "-L" "--files-without-match"
    )

    ARG_OPTIONS=(
        ["-e"]=_no_completion
        ["-C"]=_no_completion
        ["-B"]=_no_completion
        ["-A"]=_no_completion
    )

    _handle_options || _project_completion
}

_repo_list() {
    OPTIONS=(
        "-h" "--help"
    )

    ARG_OPTIONS=()

    _handle_options || _project_completion
}

_repo_prune() {
    OPTIONS=(
        "-h" "--help"
    )

    ARG_OPTIONS=()

    _handle_options || _project_completion
}

_repo_rebase() {
    OPTIONS=(
        "-h" "--help"
        "-i" "--interactive"
        "-f" "--force-rebase"
        "--no-ff"
        "-q" "--quiet"
        "--autosquash"
    )

    ARG_OPTIONS=(
        ["--whitespace"]=_no_completion
    )

    _handle_options || _project_completion
}

_repo_selfupdate() {
    OPTIONS=(
        "-h" "--help"
        "--no-repo-verify"
    )

    ARG_OPTIONS=()

    _handle_options
}

_repo_smartsync() {
    OPTIONS=(
        "-h" "--help"
        "-f" "--force-broken"
        "-l" "--local-only"
        "-n" "--network-only"
        "-d" "--detach"
        "-q" "--quiet"
        "--no-repo-verify"
    )

    ARG_OPTIONS=(
        ["-j"]=_no_completion
        ["--jobs"]=_no_completion

    )

    _handle_options || _project_completion
}

_repo_stage() {
    OPTIONS=(
        "-h" "--help"
        "-i" "--interactive"
    )

    ARG_OPTIONS=()

    _handle_options || _project_completion
}

_repo_start() {
    OPTIONS=(
        "-h" "--help"
        "--all"
    )

    ARG_OPTIONS=()

    _handle_options || _when_first _branch_completion || _project_completion
}

_repo_status() {
    OPTIONS=(
        "-h" "--help"
    )

    ARG_OPTIONS=(
        ["-j"]=_no_completion
        ["--jobs"]=_no_completion
    )

    _handle_options || _project_completion
}

_repo_sync() {
    OPTIONS=(
        "-h" "--help"
        "-f" "--force-broken"
        "-l" "--local-only"
        "-n" "--network-only"
        "-d" "--detach"
        "-q" "--quiet"
        "-s" "--smart-sync"
        "--no-repo-verify"
    )

    ARG_OPTIONS=(
        ["-j"]=_no_completion
        ["--jobs"]=_no_completion
    )

    _handle_options || _project_completion
}

_repo_upload() {
    OPTIONS=(
        "-h" "--help"
        "-t"
        "--no-verify"
        "--verify"
    )

    ARG_OPTIONS=(
        ["--re"]=_no_completion
        ["--reviewers"]=_no_completion
        ["--cc"]=_no_completion
        ["--br"]=_branch_completion
    )

    _handle_options || _project_completion
}

_repo_version() {
    OPTIONS=(
        "-h" "--help"
    )

    ARG_OPTIONS=()

    _handle_options
}

_repo() {
    COMPREPLY=()

    _init_cur_prev

    if [ ${COMP_CWORD} -eq 1 ]
    then
        _command_completion
    else
        local cmd=${COMP_WORDS[1]}
        local handler=${CMD_HANDLERS["${cmd}"]}
        if [ -n ${handler} ]
        then
            eval ${handler}
        fi
    fi

    return 0
}

complete -o nospace -F _repo repo
