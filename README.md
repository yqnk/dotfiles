# .dotfiles
> My ArchLinux dotfiles.

## Install
```sh
$ git clone git@github.com:yqnk/dotfiles.git ~/dotfiles
$ cd ~/dotfiles

# Install wallpapers
$ ln -s ~/dotfiles/wallpapers ~/.local/share/wallpapers

# Install fonts
$ sudo pacman -S --needed - < fonts.txt

# Install packages. pkglist-min.txt is the minimal set, pkglist-extra.txt is
# everything else: the two lists never repeat a package.
$ cat pkglist-min.txt pkglist-extra.txt | xargs sudo pacman -S --needed --

# AUR packages (paru, yay, ...)
$ cat pkglist-aur.txt | xargs paru -S --needed --
```

Machine-local values that must not be committed (device MAC addresses, tokens)
go in `~/.config/zsh/local.zsh`, which `.zshrc` sources when it exists.
`airpods` needs `AIRPODS_MAC` set there.

## Stow

All the important config files are manages through **GNU Stow**. To add them in a simple and clean way instead of copy-pasting everything and it becomes a real mess when you want to update or save your dotfiles, simply do the following:

```sh
$ stow kitty nvim
```

By default, stow symlinks the content of every folder you give him to another folder in the parent folder.

Re-run `stow -R <package>` after a pull that adds a file: stow only links files
that existed when it last ran.

## Compositors

**niri** is the session in use:

```sh
$ stow niri quickshell rofi kitty mako scripts hyprlock
```

It uses `awww` for the wallpaper and `xwayland-satellite` for X11 apps, niri's built-in
screenshot UI, and `hyprlock` (via `~/.local/bin/lockscreen`) for the lock screen. The
Quickshell bar reads niri's IPC event stream for workspaces and the focused window title.

`hypr/` still holds the old **Hyprland** config. It is no longer used, and its
wallpaper and lock-screen paths were never updated.
