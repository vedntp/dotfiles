
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

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Complete direnv initialization (after instant prompt)
(( ${+commands[direnv]} )) && eval "$(direnv hook zsh)"


# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1

plugins=(
	git zsh-autosuggestions
	fzf
	fzf-tab
	z
	colored-man-pages
	zsh-syntax-highlighting
)
# Mac-only plugins
$IS_MAC && plugins+=(macos brew)

# Keep completion search paths stable so Oh My Zsh can reuse .zcompdump.
typeset -U fpath
[[ -d "$HOME/.oh-my-zsh/custom/plugins/fzf-tab/lib" ]] && fpath+=("$HOME/.oh-my-zsh/custom/plugins/fzf-tab/lib")
$IS_MAC && [[ -d /opt/homebrew/share/zsh/site-functions ]] && fpath+=(/opt/homebrew/share/zsh/site-functions)

source $ZSH/oh-my-zsh.sh


# User configuration

# Keep Puppeteer/fast-cli cache out of ~/.cache to avoid cleanup.
export PUPPETEER_CACHE_DIR="$HOME/.local/share/puppeteer"

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='nvim'
export VISUAL='nvim'

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias szsh='source ~/.zshrc'
alias hetzner='ssh myserver'
alias ompg='omp --config "$HOME/.omp/agent/presets/opencode-go.yml"'

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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export TERM="xterm-256color"

(( ${plugins[(Ie)fzf]} )) || [[ ! -f ~/.fzf.zsh ]] || source ~/.fzf.zsh

alias theta="~/thetadata/theta.bash"
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
alias cx="$HOME/.local/bin/codex --yolo"
alias cx-update='curl -fsSL https://chatgpt.com/codex/install.sh | sh'
alias cxl="codex -p lean --dangerously-bypass-approvals-and-sandbox"
alias oc="opencode --auto"
alias oc2="opencode2 --auto"

# Usage aliases with model breakdown
alias ccu="ccusage --since \$(date +%Y%m%d) -b"
alias ccuw="ccusage weekly -b"
alias ccum="ccusage monthly -b"
alias ccup="ccusage -i"

# Remove oh-my-zsh git plugin alias that conflicts with gsd-pi CLI
unalias gsd 2>/dev/null
alias gsdc="gsd -c"
alias gfix="gcloud auth application-default login"

# Source machine-specific local overrides (not version controlled)
[[ -f ~/.config/zsh/.zshrc.local ]] && source ~/.config/zsh/.zshrc.local

export PATH="$HOME/.local/bin:$PATH"

# omnara
path=("/Users/vp/.omnara/bin" $path)

# To customize prompt, run `p10k configure` or edit ~/.dotfiles/mac/.p10k.zsh.
[[ ! -f ~/.dotfiles/mac/.p10k.zsh ]] || source ~/.dotfiles/mac/.p10k.zsh

# Added by Devin
export PATH="/Users/vp/.codeium/windsurf/bin:$PATH"


# Added by Antigravity CLI installer
export PATH="/Users/vp/.local/bin:$PATH"
