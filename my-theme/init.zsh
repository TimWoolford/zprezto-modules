typeset currentTheme

zstyle -s ':prezto:module:prompt' theme 'currentTheme'

if [[ "${currentTheme}" == "powerlevel10k" ]]; then
  typeset p10k_theme
  zstyle -s ':prezto:module:my-theme' p10k-theme 'p10k_theme'
  typeset themeScript="${0:h}/theme/p10k-${p10k_theme:-default}.zsh"

  [[ ! -f ${themeScript} ]] || source "${themeScript}"
fi
