# .dotfiles
> My ArchLinux dotfiles.

## Install
```sh
$ git clone git@github.com:yqnk/dotfiles.git ~/dotfiles
$ cd

# Install wallpapers
$ ln -s ~/dotfiles/wallpapers ~/.local/share/wallpapers

# Install fonts
$ sudo pacman -S --needed - < fonts.txt

# Install packages in pkglist.txt
cat pkglist.txt | xargs sudo pacman -S --needed --
```

## Stow

All the important config files are manages through **GNU Stow**. To add them in a simple and clean way instead of copy-pasting everything and it becomes a real mess when you want to update or save your dotfiles, simply do the following:

```sh
$ stow kitty nvim
```

By default, stow symlinks the content of every folder you give him to another folder in the parent folder.

## Compositors

Both **Hyprland** and **niri** are configured and can be stowed side by side; pick the session
at login.

```sh
$ stow hypr  # Hyprland
$ stow niri  # niri
$ stow quickshell rofi kitty mako scripts   # shared
```

The niri session uses `awww` for the wallpaper and `xwayland-satellite` for X11 apps instead of
`hyprpaper` and Hyprland's built-in Xwayland. Screenshots use niri's built-in screenshot UI
instead of `grimblast`. The Quickshell bar is shared, but its workspace and focused-window
widgets still talk to the Hyprland IPC and stay empty under niri.
