# Ink ramp prompt: logo pill, one powerline segment per folder stepping from
# near-black to charcoal, a git segment (green clean, amber dirty), then the
# chevron. Plain zsh: no prompt program runs per prompt, and git runs once,
# only inside a repo. Colours are fixed hex, so the bar looks the same in every
# terminal and theme; only the chevron uses the theme's green and red.

typeset -ga _ramp_bg=('#141618' '#1a1d1f' '#212427' '#282c2f' '#303438')
typeset -g  _ramp_fg='#e8eaed' _ramp_logo_bg='#333336' _ramp_ink='#16181a'
typeset -g  _ramp_clean='#6fbf86' _ramp_dirty='#e0b25e'
# Logo: the Herdr font pair by default; app terminals export PROMPT_LOGO
# with the system Apple logo instead (see .zshrc).
typeset -g  _ramp_logo=${PROMPT_LOGO:-$'\ue1bb\ue1bc'}

_ramp_esc() { REPLY=${1//\%/%%} }

# Sets _ramp_seg to the git segment's colour and text, or empty outside a repo.
_ramp_git() {
  _ramp_seg=()
  # Walk up for .git in zsh so non-repo folders cost no process at all.
  local d=$PWD
  while [[ ! -e $d/.git ]]; do
    [[ $d == / || -z $d ]] && return
    d=${d:h}
  done
  local out; out=$(GIT_OPTIONAL_LOCKS=0 command git status --porcelain=v2 --branch 2>/dev/null) || return
  local head oid ahead=0 behind=0 changed=0 untracked=0 conflicted=0 line
  for line in ${(f)out}; do
    case $line in
      '# branch.head '*) head=${line#\# branch.head } ;;
      '# branch.oid '*)  oid=${line#\# branch.oid } ;;
      '# branch.ab '*)   local ab=(${=line#\# branch.ab }); ahead=${ab[1]#+}; behind=${ab[2]#-} ;;
      [12]' '*) (( changed++ )) ;;
      'u '*)    (( conflicted++ )) ;;
      '? '*)    (( untracked++ )) ;;
    esac
  done
  [[ $head == '(detached)' ]] && head=${oid[1,7]}
  _ramp_esc "$head"; local text=$'\ue725 '"%B${REPLY}%b"
  (( ahead ))      && text+=$'  \uf062 '$ahead
  (( behind ))     && text+=$'  \uf063 '$behind
  (( conflicted )) && text+=$'  \uf071 '$conflicted
  (( changed ))    && text+=$'  \uf111 '$changed
  (( untracked ))  && text+=$'  \uf067 '$untracked
  local bg=$_ramp_clean
  (( changed + untracked + conflicted )) && bg=$_ramp_dirty
  # Third element: the segment's visible text, for width checks.
  local plain=${text//\%[Bb]/}
  _ramp_seg=($bg $text $plain)
}

_ramp_precmd() {
  local exit=$?
  # Folders: ~ or / first, then each folder; deep paths keep the last three.
  local -a parts
  local p=${(%):-%~}
  if [[ $p == '~'* ]]; then parts=('~' ${(s:/:)${p#\~}})
  else parts=('/' ${(s:/:)p}); fi
  (( $#parts > 5 )) && parts=($parts[1] '…' $parts[-3,-1])

  _ramp_git
  # Keep at least 30 columns free for typing in narrow panes: fold middle
  # folders into … until the bar fits. Each segment is its text plus 3 cells.
  local width=$(( 6 + ${#_ramp_seg[3]} + 4 )) part
  for part in $parts; do (( width += ${#part} + 3 )); done
  while (( width > COLUMNS - 30 && $#parts > 2 )); do
    if [[ $parts[2] == '…' ]]; then
      (( $#parts == 3 )) && break
      (( width -= ${#parts[3]} + 3 )); parts[3]=()
    else
      (( width -= ${#parts[2]} - 1 )); parts[2]='…'
    fi
  done

  local s="%F{$_ramp_logo_bg}"$'\ue0b6'"%K{$_ramp_logo_bg}%F{#ffffff}${_ramp_logo}"
  local prev=$_ramp_logo_bg i bg
  for (( i = 1; i <= $#parts; i++ )); do
    bg=${_ramp_bg[$(( i < $#_ramp_bg ? i : $#_ramp_bg ))]}
    _ramp_esc "$parts[i]"
    (( i == $#parts )) && REPLY="%B${REPLY}%b"
    s+="%K{$bg}%F{$prev}"$'\ue0b0'"%F{$_ramp_fg} ${REPLY} "
    prev=$bg
  done

  if (( $#_ramp_seg )); then
    s+="%K{$_ramp_seg[1]}%F{$prev}"$'\ue0b0'"%F{$_ramp_ink} $_ramp_seg[2] "
    prev=$_ramp_seg[1]
  fi
  s+="%k%F{$prev}"$'\ue0b0'"%f "
  if (( exit )); then s+='%B%F{red}❯%f%b '; else s+='%B%F{green}❯%f%b '; fi
  PROMPT=$s
}

setopt no_prompt_subst
PROMPT2='%F{8}∙%f '
RPROMPT=''
precmd_functions=(${precmd_functions:#_ramp_precmd} _ramp_precmd)
