This repo contains random scripts I write. Below are some commands to
install or uninstall my scripts:

#### Clone

Put scripts in `$HOME/.scripts`:

```
$ git clone git@github.com:mjwhitta/scripts.git $HOME/.scripts
$ cd $HOME/.scripts
```

#### Install

This will make backups of existing scripts:

```
$ ./installer link
```

#### Force install

This will NOT make backups of existing scripts:

```
$ ./installer -f link
```

#### Unintall

This will restore any backups that exist:

```
$ ./installer unlink
```

#### Configure

To configure, simply copy `files.default` to `files` and comment or
delete the entries you don't want. Add other scripts you might want.
