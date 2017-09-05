# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: vim-runtime.eclass
# @MAINTAINER:
# vim@gentoo.org
# @BLURB: used for installing vim plugins
# @DESCRIPTION:
# This eclass simplifies installation of app-vim plugins into
# $(vimfiles_directory).  This is a version-independent directory
# which is read automatically by vim.  The only exception is
# documentation, for which we make a special case via vim-doc.eclass.

# @ECLASS-VARIABLE: VIM_PLUGIN_VIM_VERSION
# @DESCRIPTION:
# This variable defines the default vim version for a vim plugin.
# The default value is "7.3".
: ${VIM_PLUGIN_VIM_VERSION:=7.3}

IUSE="nvim"
DEPEND="|| (
	>=app-editors/vim-${VIM_PLUGIN_VIM_VERSION}
	>=app-editors/gvim-${VIM_PLUGIN_VIM_VERSION}
	app-editors/neovim
)"
RDEPEND="${DEPEND}"

vim_binary() {
	# Find a suitable vim binary
	local vim=$(type -P vim 2>/dev/null)
	[[ -z "$vim" ]] && vim=$(type -P gvim 2>/dev/null)
	[[ -z "$vim" ]] && vim=$(type -P nvim 2>/dev/null)
	if [[ -z "$vim" ]]; then
		ewarn "No suitable vim binary found"
	fi
	echo "$vim"
}

vimfiles_directory() {
	if use nvim ; then
		echo "/usr/share/nvim/runtime"
	else
		echo "/usr/share/vim/vimfiles"
	fi
}
