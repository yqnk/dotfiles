# .dotfiles
> My ArchLinux dotfiles.

## Install
```sh
$ git clone git@github.com:yqnk/.dotfiles.git ~/dotfiles
$ cd

# Install wallpapers
$ ln -s ~/dotfiles/wallpapers ~/.local/share/wallpapers

# Install icons
$ ln -s ~/dotfiles/icons ~/.local/share/icons

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
