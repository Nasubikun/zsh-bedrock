#!/usr/bin/env zsh
function _brk_completion {
    local -a opts
    local curcontext="$curcontext" state line
    typeset -A opt_args
    _arguments -C \
        '-c[Configuration option]:configuration option:->conf_opts' \
        '*:: :->extra_args'
    case $state in
    conf_opts)
        local -a conf_opts
        conf_opts=(
            'AWS_REGION:AWS region, e.g. us-west-2'
            'MODEL_ID:Model ID, e.g. anthropic.claude-v2'
            'ENDPOINT_URL:Endpoint URL'
            'LANGS:Languages, e.g. ["English", "Japanese"]'
        )
        _describe 'configuration option' conf_opts
        ;;
    esac
}
# Associate _brk_completion with brk command
compdef _brk_completion brk
