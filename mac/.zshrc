
# Load local secrets (API keys, tokens)
[[ -f ~/.config/zsh/.zshenv.local ]] && source ~/.config/zsh/.zshenv.local

# Disable claude.ai MCP servers in Claude Code (keep them in desktop app only)
export ENABLE_CLAUDEAI_MCP_SERVERS=false

# Use experimental no-flicker renderer for Claude Code
export CLAUDE_CODE_NO_FLICKER=1
# Force truecolor in tmux (workaround for anthropics/claude-code#35148)
export CLAUDE_CODE_TMUX_TRUECOLOR=1

# ===== PLATFORM DETECTION =====
if [[ "$OSTYPE" == darwin* ]]; then
    IS_MAC=true
else
    IS_MAC=false
fi

# Prevent terminal bells from bouncing Alacritty's Dock icon.
if [[ -n "$ALACRITTY_WINDOW_ID" ]]; then
    printf '\e[?1042l'
fi

# Cache the output of `tool init zsh` so startup does not spawn the tool every
# time. Regenerated whenever the tool's binary is newer than the cache.
_cached_init() {
  local name=$1 bin=${commands[$1]}; shift
  [[ -n $bin ]] || return
  local file=~/.cache/zsh/$name-init.zsh
  if [[ ! -s $file || $bin -nt $file ]]; then
    mkdir -p ${file:h}
    "$@" >| $file
  fi
  source $file
}

# Starship's init, with two per-shell costs baked in at cache time: the
# continuation prompt (otherwise one starship run per new shell) and the
# right prompt (otherwise one extra starship run per prompt; this config has
# no right_format).
_starship_init_static() {
  local cont; cont=$(STARSHIP_SHELL=zsh starship prompt --continuation)
  starship init zsh | grep -v '^PROMPT2=\|^RPROMPT='
  print -r -- "PROMPT2=${(q)cont}"
  print -r -- "RPROMPT=''"
}

# ===== SHELL BASICS =====
# Plain zsh, no framework. These replace the parts of Oh My Zsh in use.

# History, shared across sessions
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_verify share_history

# Directories: type a folder name to cd into it; `-` goes back
setopt auto_cd auto_pushd pushd_ignore_dups pushdminus interactive_comments
alias -- -='cd -'

# Keys: emacs mode; up/down search history for what is already typed
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word

# Colours and listings
export CLICOLOR=1
alias grep='grep --color=auto'
# eza, with the same aliases as Omarchy, only for a person at a terminal.
# Agents keep plain ls: Claude Code copies these aliases into its shell, which
# has no terminal, and there eza waits for file names on stdin and hangs.
if (( $+commands[eza] )) && [[ -t 0 && -z $CLAUDECODE ]]; then
    alias ls='eza -lh --group-directories-first --icons=auto'
    alias lsa='ls -a'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
else
    alias ls='ls -G'
    alias lsa='ls -lah'
fi

# Completion: case-insensitive, menu via fzf-tab (loaded at the end).
# The full security check runs once a day; other starts reuse the dump (-C).
typeset -U fpath
$IS_MAC && [[ -d /opt/homebrew/share/zsh/site-functions ]] && fpath+=(/opt/homebrew/share/zsh/site-functions)
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-$ZSH_VERSION"
_zcompdump_stale=( $_zcompdump(N.mh+24) )
if [[ ! -s $_zcompdump || -n $_zcompdump_stale ]]; then
  compinit -d $_zcompdump
else
  compinit -C -d $_zcompdump
fi
# A compiled dump loads faster than the plain text one.
[[ $_zcompdump.zwc -nt $_zcompdump ]] || zcompile $_zcompdump
unset _zcompdump _zcompdump_stale
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true
setopt complete_in_word always_to_end

# Window title: user@host:dir at the prompt, the command while it runs
_title_precmd() { print -Pn "\e]0;%n@%m:%~\a" }
_title_preexec() { print -Pn "\e]0;%n@%m:" && print -rn -- "${1[(w)1]}" && print -n "\a" }
precmd_functions+=(_title_precmd)
preexec_functions+=(_title_preexec)

ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1

# ===== USER CONFIGURATION =====

# Keep Puppeteer/fast-cli cache out of ~/.cache to avoid cleanup.
export PUPPETEER_CACHE_DIR="$HOME/.local/share/puppeteer"

# Preferred editor for local and remote sessions
export EDITOR='nvim'
export VISUAL='nvim'

alias szsh='source ~/.zshrc'
alias hetzner='ssh myserver'

# Set the font size used by Ghostty and Alacritty.
my_terminal_font() {
	if (( $# != 1 )) || [[ ! "$1" =~ ^([1-9]|[1-9][0-9])([.][0-9]+)?$ ]]; then
		print "Usage: my_terminal_font SIZE (for example: my_terminal_font 14)" >&2
		return 2
	fi

	local size="$1"
	local config
	local ghostty_configs=(
		"$HOME/.config/ghostty/config"
		"$HOME/.dotfiles/mac/.config/ghostty/config"
	)
	local alacritty_configs=(
		"$HOME/.config/alacritty/alacritty.toml"
		"$HOME/.dotfiles/mac/.config/alacritty/alacritty.toml"
	)

	for config in $ghostty_configs; do
		[[ -f "$config" ]] && sed -i '' -E "s/^font-size[[:space:]]*=.*/font-size = $size/" "$config"
	done
	for config in $alacritty_configs; do
		[[ -f "$config" ]] && sed -i '' -E "s/^size[[:space:]]*=.*/size = $size/" "$config"
	done

	print "Terminal font size set to $size."
}

# List project-scoped Codex skills from the project root.
alias project-skills='find .agents/skills -name SKILL.md -print 2>/dev/null'

export TERM="xterm-256color"

# fzf key bindings (Ctrl+R history search)
_cached_init fzf fzf --zsh

alias theta="~/tools/thetadata/theta.bash"
export PATH="$PATH:$HOME/.config/emacs/bin"
alias py=".venv/bin/python3"
alias fim="vim \$(fzf)"

# Recent files from neovim, pick with fzf (filters to existing files only)
fr() {
  local file
  file=$(nvim --headless +'lua for _,f in ipairs(vim.v.oldfiles) do print(f) end' +q 2>&1 | grep '^/' | tr -d '\r' | while read -r f; do [[ -f "$f" ]] && echo "$f"; done | fzf)
  [[ -n "$file" ]] && nvim "$file"
}

# Platform-specific file opening aliases
if $IS_MAC; then
    alias fopen="open \"\$(fzf)\""
    alias ffind="open -R \"\$(fzf)\""
else
    alias fopen="xdg-open \"\$(fzf)\""
    alias ffind="xdg-open \"\$(dirname \"\$(fzf)\")\""
fi

alias fcd="cd \"\$(dirname \"\$(fzf)\")\" && ls"
alias tw="task"

# Mac-specific paths and tools
if $IS_MAC; then
    # Added by Windsurf
    export PATH="$HOME/.codeium/windsurf/bin:$PATH"
    # opencode
    export PATH="$HOME/.opencode/bin:$PATH"
    # gsd-browser
    export PATH="$HOME/.gsd-browser/bin:$PATH"
    # MacPorts
    export PATH="/opt/local/bin:/opt/local/sbin:$PATH"

    # Network optimization aliases
    alias mynet='~/.config/myFiles/network/enable_fast_network.sh'
    alias offmynet='~/.config/myFiles/network/disable_fast_network.sh'

    # IBKR trading scripts
    export PATH="$PATH:$HOME/pspl/ibkr/cron"
    alias nxc="nextcron"

    # Caffeinate control aliases
    alias caff="$HOME/pspl/ibkr/cron/on_caffeinate"
    alias uncaff="$HOME/pspl/ibkr/cron/off_caffeinate"

    # Added by Antigravity
    export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
fi

# Vertex AI config (GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_LOCATION) set in ~/.zshenv
# Auth via ADC (gcloud auth application-default login), no API keys

# Ranger function to cd to last directory on quit with Q
ranger() {
    local IFS=$'\t\n'
    local tempfile="$(mktemp -t tmp.XXXXXX)"
    local ranger_cmd=(
        command ranger
        --cmd="map q chain shell echo %d > "$tempfile"; quitall"
        "$@"
    )
    "${ranger_cmd[@]}"
    if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
        cd -- "$(cat "$tempfile")"
    fi
    command rm -f -- "$tempfile"
}

alias rr="ranger"
alias vim="nvim"
alias vi="nvim"

# === CLAUDE CODE KEYBINDINGS ===
# Unbind Ctrl+T (transpose-chars) so it passes through to Claude Code Tasks
bindkey -r '^T'

# === CLAUDE CODE PROVIDER SWITCHER ===
alias cl="claude"
alias cld="claude --dangerously-skip-permissions"
alias cldr="claude --resume --dangerously-skip-permissions"
alias cldc="claude --continue --dangerously-skip-permissions"

# Kick off the 5-hour usage window with the cheapest possible request
# Optional arg: delay in minutes, e.g. `cc5 40` (keeps Mac awake while waiting).
# The delayed run gets its own session so closing the pane or terminal won't kill it.
cc5() {
  if [[ -n "$1" ]]; then
    [[ "$1" == <-> ]] || { echo "usage: cc5 [minutes]" >&2; return 1; }
    local log=~/.cache/cc5.log
    mkdir -p ${log:h}
    nohup perl -MPOSIX -e 'fork and exit; POSIX::setsid(); exec @ARGV' \
      zsh -c "$(functions cc5); caffeinate -i sleep $(( $1 * 60 )) && cc5" \
      </dev/null >>$log 2>&1 &!
    echo "cc5 scheduled for $(date -v+${1}M '+%H:%M') (log: $log)"
    return
  fi
  if claude -p "hi" \
      --model haiku \
      --effort low \
      --safe-mode \
      --tools "" \
      --system-prompt "Reply with exactly: ok" \
      --no-session-persistence >/dev/null 2>&1; then
    echo "claude window started $(date '+%H:%M'), ends ~$(date -v+5H '+%H:%M')"
  else
    echo "cc5: request failed (are you logged in? try: claude auth)" >&2
    return 1
  fi
}

# codex
# Computer-use override (unverified; saved persistently, run manually if needed):
# defaults write -g ComputerUseAllowForbiddenTargets -bool YES
# Undo: defaults delete -g ComputerUseAllowForbiddenTargets
alias cx="$HOME/.local/bin/codex --yolo"
alias cxa="$HOME/.local/bin/codex --yolo agents"
alias cx-update='curl -fsSL https://chatgpt.com/codex/install.sh | sh'
alias cxl="codex -p lean --dangerously-bypass-approvals-and-sandbox"
alias oc="opencode --auto"

# Usage aliases with model breakdown
alias ccu="ccusage --since \$(date +%Y%m%d) -b"
alias ccuw="ccusage weekly -b"
alias ccum="ccusage monthly -b"
alias ccup="ccusage -i"

alias gsdc="gsd -c"
alias gfix="gcloud auth application-default login"

# Source machine-specific local overrides (not version controlled)
[[ -f ~/.config/zsh/.zshrc.local ]] && source ~/.config/zsh/.zshrc.local

export PATH="$HOME/.local/bin:$PATH"

# omnara
path=("/Users/vp/.omnara/bin" $path)

# Added by Devin
export PATH="/Users/vp/.codeium/windsurf/bin:$PATH"


# Added by Antigravity CLI installer
export PATH="/Users/vp/.local/bin:$PATH"

# Drop duplicate PATH entries added above
typeset -U path

# ===== PLUGINS AND PROMPT =====
# Order matters: fzf-tab after compinit, syntax highlighting last.
source ~/.local/share/zsh/plugins/fzf-tab/fzf-tab.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
_cached_init starship _starship_init_static
