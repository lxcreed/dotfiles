# -----------------------------------------------------------------------------
# Homebrew 初始化（macOS）
# 需在所有工具初始化之前执行，确保 PATH 中包含 brew 安装的命令
# -----------------------------------------------------------------------------
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi


# -----------------------------------------------------------------------------
# zinit 安装引导（首次运行时自动 clone zinit 本体）
# -----------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"


# -----------------------------------------------------------------------------
# 插件加载
# 注意：zsh-syntax-highlighting 必须在所有插件最后加载
# -----------------------------------------------------------------------------

# 将 Tab 补全界面替换为 fzf 模糊搜索（需已安装 fzf）
# 必须在 compinit 之前加载
zinit light Aloxaf/fzf-tab

# 比 zsh 内置更丰富的补全规则集合
zinit light zsh-users/zsh-completions

# 基于历史的命令自动建议（灰色提示，→ 或 Ctrl-E 接受建议）
zinit light zsh-users/zsh-autosuggestions

# 命令语法高亮（输入时实时着色，合法命令绿色，错误命令红色）
source ~/.config/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
zinit light zsh-users/zsh-syntax-highlighting



# -----------------------------------------------------------------------------
# oh-my-zsh 片段加载（只取用需要的插件，无需整个 oh-my-zsh）
# OMZL = oh-my-zsh lib 目录；OMZP = oh-my-zsh plugins 目录
# -----------------------------------------------------------------------------

# git lib：git 插件的底层函数库，须在 OMZP::git 之前加载
zinit snippet OMZL::git.zsh

# git：大量 git 别名（gst=status, gco=checkout, gp=push, gl=log 等）
zinit snippet OMZP::git

# sudo：双击 ESC 快速在当前命令前加上 sudo
zinit snippet OMZP::sudo

# extract：`x <file>` 一条命令解压所有格式（zip/tar/gz/7z/rar 等）
zinit snippet OMZP::extract

# copypath：`copypath` 复制当前目录的绝对路径到剪贴板
zinit snippet OMZP::copypath

# copyfile：`copyfile <file>` 复制文件内容到剪贴板
zinit snippet OMZP::copyfile

# cp：提供带进度条的 `cpv` 命令（底层使用 rsync）
zinit snippet OMZP::cp

# brew：Homebrew 相关补全和别名（macOS）
zinit snippet OMZP::brew

# aliases：`als` 命令，按分类展示所有已定义别名
zinit snippet OMZP::aliases

# command-not-found：输入不存在的命令时，提示应该安装哪个包
zinit snippet OMZP::command-not-found

# docker：为 docker 及 docker-compose 等子命令提供参数补全
zinit snippet OMZP::docker


# -----------------------------------------------------------------------------
# 补全系统初始化
# 必须在所有补全规则（插件/片段）加载完成之后调用
# zinit cdreplay -q：重放 zinit 在加载过程中缓存的 compdef 调用
# -----------------------------------------------------------------------------
autoload -Uz compinit && compinit
zinit cdreplay -q



# -----------------------------------------------------------------------------
# ZSH Basic Options
# -----------------------------------------------------------------------------
setopt autocd              # 直接输入目录名即可进入，无需输入 cd
setopt correct             # 命令输错时自动提示纠正建议
setopt interactivecomments # 允许在交互式终端中输入 # 注释
setopt magicequalsubst     # key=value 参数中等号右侧也进行文件名展开
setopt nonomatch           # 通配符无匹配时不报错，原样传递给命令
setopt notify              # 后台任务完成时立即通知，不等待下次提示符
setopt numericglobsort     # 文件名含数字时按数字大小而非字典序排序
setopt promptsubst         # 提示符中允许命令替换和变量展开（动态提示符必需, starship可能会自己开启）


# -----------------------------------------------------------------------------
# 键绑定
# -----------------------------------------------------------------------------
bindkey -e                             # Emacs 风格键绑定（支持 Ctrl-A/E/K/U 等）
bindkey '^p' history-search-backward   # Ctrl-P：基于已输入内容向上搜索历史
bindkey '^n' history-search-forward    # Ctrl-N：基于已输入内容向下搜索历史
bindkey '^[w' kill-region              # Alt-W：删除选中区域
bindkey '^[[H' beginning-of-line       # Home 键跳到行首
bindkey '^[[F' end-of-line             # End 键跳到行尾
bindkey '^[[3~' delete-char            # Delete 键向后删除字符
bindkey "^[[A" history-beginning-search-backward  # 上箭头：以已输入内容为前缀，向上搜索匹配的历史命令
bindkey "^[[B" history-beginning-search-forward   # 下箭头：以已输入内容为前缀，向下搜索匹配的历史命令


# -----------------------------------------------------------------------------
# 历史记录配置
# -----------------------------------------------------------------------------
HISTSIZE=10000                    # 内存中保留的最大历史条数
SAVEHIST=$HISTSIZE                # 写入磁盘的最大历史条数
HISTFILE=~/.zsh_history           # 历史文件路径
HISTDUP=erase                     # 存在重复时擦除旧条目

setopt appendhistory              # 追加写入历史（而非覆盖），多终端并存时安全
setopt sharehistory               # 多个 zsh 会话之间实时共享历史
setopt hist_ignore_space          # 以空格开头的命令不记录（适合含密码的命令）
setopt hist_ignore_all_dups       # 不记录任何重复命令（即使不连续）
setopt hist_save_no_dups          # 写入磁盘时去重
setopt hist_ignore_dups           # 不记录与上一条相同的命令
setopt hist_find_no_dups          # Ctrl-R 搜索历史时跳过重复条目


# -----------------------------------------------------------------------------
# 补全样式配置（需在 compinit 之后生效）
# -----------------------------------------------------------------------------

# 补全时忽略大小写（输入小写可匹配大写）
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# 补全列表使用 LS_COLORS 着色（文件类型有颜色区分）
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# 禁用旧式选择菜单，交给 fzf-tab 接管
zstyle ':completion:*' menu no

# fzf-tab：cd 补全时右侧预览目录内容
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# fzf-tab：zoxide 跳转补全时右侧预览目录内容
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

zstyle ':completion:*:*:docker:*' option-stacking yes    # 允许 docker 命令叠加选项补全（如 -it）
zstyle ':completion:*:*:docker-*:*' option-stacking yes  # 允许 docker-compose 等子命令叠加选项补全


# -----------------------------------------------------------------------------
# 环境变量
# -----------------------------------------------------------------------------
export EDITOR='nvim'              # 默认编辑器

# -----------------------------------------------------------------------------
# 检测到 bat 已安装时，将其设为系统默认分页器
# MANPAGER：man 手册页通过 col 去除控制字符后交由 bat 以语法高亮渲染
# PAGER：所有分页输出（git log / help 等）均使用 bat 替代默认的 less
# -----------------------------------------------------------------------------
if [[ -x "$(command -v bat)" ]]; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export PAGER=bat
fi



# -----------------------------------------------------------------------------
# PATH 管理函数, 添加常见二进制路径到 PATH
# 添加前自动检查目录是否存在且未重复，避免 PATH 污染
# -----------------------------------------------------------------------------

# 将目录追加到 PATH 末尾（低优先级，不覆盖系统同名命令）
function pathappend() {
    for ARG in "$@"
    do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="${PATH:+"$PATH:"}$ARG"
        fi
    done
}

# 将目录追加到 PATH 开头（高优先级，优先于系统同名命令）
function pathprepend() {
    for ARG in "$@"
    do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="$ARG${PATH:+":$PATH"}"
        fi
    done
}

# 用户自定义脚本与程序的惯用安装目录，优先于系统命令
pathprepend "$HOME/bin" "$HOME/sbin" "$HOME/.local/bin" "$HOME/local/bin" "$HOME/.bin"

# Rust cargo 安装的二进制文件目录
pathappend "$HOME/.cargo/bin"


# -----------------------------------------------------------------------------
# Yazi 目录跟随
# 使用 y 命令启动 Yazi，退出后终端自动跳转到 Yazi 中最后所在的目录
# 直接运行 yazi 则不具备此能力
# -----------------------------------------------------------------------------
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}


# -----------------------------------------------------------------------------
# 别名
# -----------------------------------------------------------------------------
alias ls='ls --color'             # ls 输出带颜色
alias vim='nvim'                  # 用 nvim 替代 vim
alias c='clear'                   # 快速清屏
alias q='exit'
alias ..='cd ..'
alias mkdir='mkdir -pv'   # -p 自动创建父目录，-v 显示创建过程
alias cp='cp -iv'         # -i 覆盖前询问确认，-v 显示操作过程
alias mv='mv -iv'         # -i 覆盖前询问确认，-v 显示操作过程
alias rm='rm -iv'         # -i 删除前逐个确认，-v 显示删除过程
alias rmdir='rmdir -v'    # -v 显示删除过程
alias grep='grep --color=auto'


if [[ -x "$(command -v lazygit)" ]]; then
    alias lg='lazygit'
fi

# Alias for lsd
if [[ -x "$(command -v lsd)" ]]; then
	alias lsd='lsd -F --group-dirs first'
	alias ll='lsd --header --long --group-dirs first'
	alias tree='lsd --tree'
fi

# fzf 增强别名
# fzf：模糊搜索，默认附带 bat 语法高亮预览，只显示前 500 行防止大文件卡顿
if [[ -x "$(command -v fzf)" ]]; then
    alias fzf='fzf --preview "bat --style=numbers --color=always --line-range :500 {}"'
    alias preview='edit $(fzf --info=inline --query="${@}")'  # 模糊搜索文件并在编辑器中打开
fi


# 网络诊断
# 本地 IP：优先使用 ip 命令，不存在时降级到 ifconfig
if [[ -x "$(command -v ip)" ]]; then
    alias iplocal="ip -br -c a"   # 简洁格式输出本地所有网卡 IP
else
    alias iplocal="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"
fi

# 公网 IP：优先使用 curl，不存在时降级到 wget
if [[ -x "$(command -v curl)" ]]; then
    alias ipexternal="curl -s ifconfig.me && echo"     # && echo 确保输出后自动换行
elif [[ -x "$(command -v wget)" ]]; then
    alias ipexternal="wget -qO- ifconfig.me && echo"
fi


# -----------------------------------------------------------------------------
# 自定义函数
# -----------------------------------------------------------------------------
# 后台启动程序并与终端完全分离，关闭终端后程序继续运行，所有输出静默丢弃
function runfree() {
    "$@" > /dev/null 2>&1 & disown
}


# 复制文件到目标目录后自动跳转进入该目录，目标为文件名时仅复制不跳转
function cpg() {
    if [[ -d "$2" ]]; then
        cp "$1" "$2" && cd "$2"
    else
        cp "$1" "$2"
    fi
}


# 移动文件到目标目录后自动跳转进入该目录，目标为文件名时仅移动不跳转
function mvg() {
    if [[ -d "$2" ]]; then
        mv "$1" "$2" && cd "$2"
    else
        mv "$1" "$2"
    fi
}


# 创建多级目录后立即跳转进入，等同于 mkdir -p + cd
function mkdirg() {
    mkdir -p "$@" && cd "$@"
}



# -----------------------------------------------------------------------------
# 外部工具初始化
# 放在配置末尾，确保上方所有设置已就绪
# -----------------------------------------------------------------------------

# fzf：模糊搜索集成
# Ctrl-R 历史搜索 / Ctrl-T 文件搜索 / Alt-C 目录跳转
# --info=inline-right  匹配数量显示在输入框右侧，不占用额外行
# --ansi               支持带 ANSI 颜色的输入内容正确渲染
# --layout=reverse     输入框置顶，候选列表向下展开，符合自然阅读方向
# --border=rounded     整体加圆角边框，视觉更精致
# 配色方案基于 Catppuccin Mocha，与终端整体主题保持一致
source <(fzf --zsh)
if [[ -x "$(command -v fzf)" ]]; then
    export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
      --info=inline-right \
      --ansi \
      --layout=reverse \
      --border=rounded \
      --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
      --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
      --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
      --color=selected-bg:#45475A \
      --color=border:#6C7086,label:#CDD6F4 \
    "
fi


# zoxide：智能目录跳转，替代 oh-my-zsh 的 z 插件
# 记忆访问频率，`cd <模糊关键词>` 即可跳转到最匹配的目录
eval "$(zoxide init --cmd cd zsh)"

# starship：跨 shell 极速提示符，替代 oh-my-zsh 主题系统
# 必须放在最后，确保在所有插件和工具初始化完成后再渲染提示符
eval "$(starship init zsh)"


# 配置nvm Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
