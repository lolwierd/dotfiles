function h() {
    # check if we passed any parameters
    if [ -z "$*" ]; then
        # if no parameters were passed print entire history
        history 1
    else
        # if words were passed use it as a search
        history 1 | egrep --color=auto "$@"
    fi
}

function mc(){
    FOO=$1
    FOO=${FOO:-'learn'}
    mkdir "$FOO" && cd "$FOO"
}
