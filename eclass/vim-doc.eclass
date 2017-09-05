# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
#
# This eclass is used by vim.eclass and vim-plugin.eclass to update
# the documentation tags.  This is necessary since vim doesn't look in
# /usr/share/vim/vimfiles/doc for documentation; it only uses the
# versioned directory, for example /usr/share/vim/vim62/doc
#
# We depend on vim being installed, which is satisfied by either the
# DEPEND in vim-plugin or by whatever version of vim is being
# installed by the eclass.

inherit vim-runtime

run_helptags() {
	# Update tags; need a vim binary for this
	if [[ -n "$1" ]]; then
		einfo "Updating documentation tags in $2"
		DISPLAY= $1 -u NONE -n \
			'+set nobackup nomore' \
			"+helptags $2/doc" \
			'+qa!' </dev/null &>/dev/null
	fi
}

update_vim_helptags() {
	has "${EAPI:-0}" 0 1 2 && ! use prefix && EROOT="${ROOT}"
	local vimfiles vim d s

	# This is where vim plugins are installed
	vimfiles="${EROOT}$(vimfiles_directory)"

	if [[ $PN != vim-core ]]; then
		vim="$(vim_binary)"
	fi

	# Make vim not try to connect to X. See :help gui-x11-start
	# in vim for how this evil trickery works.
	if [[ -n "${vim}" ]] ; then
		ln -s "${vim}" "${T}/tagvim"
		vim="${T}/tagvim"
	fi

	# Install the documentation symlinks into the versioned vim
	# directory and run :helptags
	for d in "${EROOT%/}"/usr/share/vim/vim[0-9]*; do
		[[ -d "$d/doc" ]] || continue	# catch a failed glob

		# Remove links, and possibly remove stale dirs
		find $d/doc -name \*.txt -type l | while read s; do
			[[ $(readlink "$s") = $vimfiles/* ]] && rm -f "$s"
		done
		if [[ -f "$d/doc/tags" && $(find "$d" | wc -l | tr -d ' ') = 3 ]]; then
			# /usr/share/vim/vim61
			# /usr/share/vim/vim61/doc
			# /usr/share/vim/vim61/doc/tags
			einfo "Removing $d"
			rm -r "$d"
			continue
		fi

		# Re-create / install new links
		if [[ -d $vimfiles/doc ]]; then
			ln -s $vimfiles/doc/*.txt $d/doc 2>/dev/null
		fi

		# Update tags; need a vim binary for this
		run_helptags $vim $d
	done

	# For neovim, just run :helptags on the tag directory
	if use nvim ; then
		[[ -d $vimfiles/doc ]] || break

		# Update tags; need a vim binary for this
		run_helptags $vim $vimfiles
	fi

	[[ -n "${vim}" && -f "${vim}" ]] && rm "${vim}"
}
