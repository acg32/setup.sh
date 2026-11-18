# publish: copy files into a project on the Tailscale-served share of a dev VM.
# Needs SHARE_VM (ssh alias of the VM), set per machine in ~/.config/zsh/local/share.zsh.
# The VM side is scripts/share, installed as ~/bin/share there.
#   publish <project> <file|dir>...   (a dir is copied with its contents)
publish() {
    local vm=${SHARE_VM:-}
    [[ -n $vm ]] || { echo "publish: set SHARE_VM to the VM's ssh alias" >&2; return 2; }
    (( $# >= 2 )) || { echo "usage: publish <project> <file|dir>..." >&2; return 2; }
    local proj=$1 f host
    shift
    ssh "$vm" "mkdir -p ~/share/${proj}" || return
    for f in "$@"; do
        if [[ -d $f ]]; then
            rsync -a "${f%/}/" "${vm}:share/${proj}/" || return
        else
            rsync -a "$f" "${vm}:share/${proj}/" || return
        fi
    done
    ssh "$vm" '~/bin/share index' >/dev/null || return
    host=$(ssh "$vm" '~/bin/share host') || return
    for f in "$@"; do
        if [[ -d $f ]]; then print "https://${host}/${proj}/"; else print "https://${host}/${proj}/${f:t}"; fi
    done | awk '!seen[$0]++'
}
