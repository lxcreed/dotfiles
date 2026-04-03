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

# 命令语法高亮（输入时实时着色，合法命令绿色，错误命令红色）
zinit light zsh-users/zsh-syntax-highlighting

# 比 zsh 内置更丰富的补全规则集合
zinit light zsh-users/zsh-completions

# 基于历史的命令自动建议（灰色提示，→ 或 Ctrl-E 接受建议）
zinit light zsh-users/zsh-autosuggestions

# 将 Tab 补全界面替换为 fzf 模糊搜索（需已安装 fzf）
# 必须在 compinit 之前加载
zinit light Aloxaf/fzf-tab


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


# -----------------------------------------------------------------------------
# 补全系统初始化
# 必须在所有补全规则（插件/片段）加载完成之后调用
# zinit cdreplay -q：重放 zinit 在加载过程中缓存的 compdef 调用
# -----------------------------------------------------------------------------
autoload -Uz compinit && compinit
zinit cdreplay -q


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


# -----------------------------------------------------------------------------
# 环境变量
# -----------------------------------------------------------------------------
export EDITOR='nvim'              # 默认编辑器


# -----------------------------------------------------------------------------
# 别名
# -----------------------------------------------------------------------------
alias ls='ls --color'             # ls 输出带颜色
alias vim='nvim'                  # 用 nvim 替代 vim
alias c='clear'                   # 快速清屏


# -----------------------------------------------------------------------------
# 外部工具初始化
# 放在配置末尾，确保上方所有设置已就绪
# -----------------------------------------------------------------------------

# fzf：模糊搜索集成
# Ctrl-R 历史搜索 / Ctrl-T 文件搜索 / Alt-C 目录跳转
source <(fzf --zsh)

# zoxide：智能目录跳转，替代 oh-my-zsh 的 z 插件
# 记忆访问频率，`cd <模糊关键词>` 即可跳转到最匹配的目录
eval "$(zoxide init --cmd cd zsh)"

# starship：跨 shell 极速提示符，替代 oh-my-zsh 主题系统
# 必须放在最后，确保在所有插件和工具初始化完成后再渲染提示符
eval "$(starship init zsh)"
