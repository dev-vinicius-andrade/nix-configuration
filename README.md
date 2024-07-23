# nix-config

Personal nix configuration files.
This repository contains my development environment configuration which are configured using Flakes and Disko.

## Table of Contents

- [Installation] (#installation)
  - [Pre-Requisites] (#pre-requisites)
  - [Change Current user] (#change-current-user)
  - [Setting up the keymap] (#setting-up-the-keymap)
  - [Setting a Root Password] (#setting-a-root-password)
  - [A Command To Rule Them All] (#a-command-to-rule-them-all)
  - [Clear the nixos configuration files] (#clear-the-nixos-configuration-files)
  - [Cloning the repository] (#cloning-the-repository)
  - [Init script] (#init-script)
    - [Script permissions] (#script-permissions)
    - [Running the script] (#running-the-script)
    - [Personalization] (#personalization)
  - [Installing NixOS] (#installing-nixos)

## Installation

Bellow is a step-by-step guide to install NixOS using this repository.

### Pre-Requisites

- A working internet connection
- Create a bootable USB with the nixos iso, you can get it [here](https://nixos.org/download.html);
- A Machine or a VM;
- Knowledge of the terminal;
- Basic understanding of the nix package manager;
- Basic understanding of the nixos configuration files;
- Basic knowledge of how to boot from a USB drive;

### Change Current user

As default nixos minimal ISO uses the `nixos` user, I prefer to use the `root` user, so I change the current user to `root`.

```bash
   sudo -i 
```

### Setting up the keymap

As I'm using a brazilian keyboard, I need to set the keymap to br-abnt2, you can change it to your own keymap or skip this step if not needed.

```bash
    loadkeys br-abnt2
```

> Note: Normally the keymap name is the `<country_code>-<layout>`;

### Setting a Root Password

As I wanted to connect to the machine using ssh, I need to set a root password.

```bash
    passwd
```

### Create a directory to clone the repository

As I'm going to use symlinks to the nixos configuration files I need to create a directory to clone the repository, the directory can be anywhere that you want, but I prefer to use the `/mnt/etc/dotfiles` directory.

```bash
    #if the /mnt/etc/nixos exists, create a backup for it
    mv /mnt/etc/nixos /mnt/etc/nixos.bkp 
    mkdir -p /mnt/etc/dotfiles
```

> Note: You can change the directory to your own path if you want, but remember to change the path in the following commands.

### Creating the symlinks

As I'm going to use symlinks, first I create a backup for the nixos directory, then I create a symlink to the nixos configuration files.

```bash
    [ -d /mnt/etc/nixos ] && mv /mnt/etc/nixos /mnt/etc/nixos.bkp; ln -sfv /mnt/etc/dotfiles/nix /mnt/etc/nixos
```

### A Command To Rule Them All

If you want to run all the commands in one go, you can use the following command.

```bash
    curl -L https://github.com/dev-vinicius-andrade/nix-config/archive/refs/heads/main.tar.gz | tar xz --strip-components=1 -C /mnt/etc/dotfiles/nixos-config && \
    chmod +x ./nixos-config/init.sh && \
    ./nixos-config/init.sh /etc/nixos
```

Or you can run each command separately.

- [Clear the nixos configuration files](#clear-the-nixos-configuration-files)
- [Cloning the repository](#cloning-the-repository)
- [Init script](#init-script)
  - [Script permissions](#script-permissions)
  - [Running the script](#running-the-script)

### Clear the nixos configuration files

```bash
    rm -rf /etc/nixos/*
```

### Cloning the repository

As I'm using the minimal ISO I'm use curl to clone the repository.

```bash
    curl -L https://github.com/dev-vinicius-andrade/nix-config/archive/refs/heads/main.tar.gz | tar xz --strip-components=1 -C ./nixos-config
```

This will clone the repository to the `./nixos-config` directory.

If you want you can clone the repository using git, but you need to install it first.

```bash
    nix-env -i git
    git clone https://github.com/dev-vinicius-andrade/nix-config.git ./nixos-config
```

### Init script

The repository contains a [init.sh](init.sh) script that will do some initial configurations for you.

- Copies the [variables.template.nix](variables.template.nix) to [variables.nix](variables.nix);

#### Script permissions

After cloning the repository you need to give the script execution permission.

```bash
    chmod +x ./nixos-config/init.sh
```

#### Running the script

```bash
    ./nixos-config/init.sh
```

#### Personalization

After running the script the templates files will be copied to /etc/nixos, there you can personalize the configurations as you want, mainly you need to personalize the [variables.nix](variables.nix) file with your own configurations.
Also, you can personalize the nixos configuration files as you want, this is just a starting point.

#### Installing NixOS

Bellow are the steps to install NixOS using this repository.

- [Bootstrapping the disks](#bootstrapping-the-disks)

##### Bootstrapping the disks

To Install NixOs firts you need to bootstrap the disks, to do it you can use the following command:

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./nixos-config/nix/disko/default/disko.nix  --show-trace
```

Here we are using the `disko` tool to bootstrap the disks, you can check the [disko.nix](nix/disko/default/disko.nix) file to see the configurations.
You can also check the [disko documentation here](https://github.com/nix-community/disko)

But basically we are enabling flakes and using their flake to generate the partitions using the [disko.nix](nix/disko/default/disko.nix) file;

##### Generating the hardware configuration

After bootstrapping the disks you need to generate the hardware configuration, to do it you can use the following command:

```bash
nixos-generate-config --root /mnt --no-filesystems && \
rm /mnt/etc/nixos/configuration.nix && \
cp /mnt/etc/nixos/hardware-configuration.nix ./nixos-config/nix/hardware-configuration.nix && \
mkdir -p /mnt/usr/share/dotfiles && \
cp -r ./nixos-config/* /mnt/usr/share/dotfiles && \
([ -d /mnt/etc/nixos ] && mv /mnt/etc/nixos /mnt/etc/nixos.bkp) && \
ln -sfv /usr/share/dotfiles/nix /etc/nixos
```

The above command will:

- Generate the hardware configuration and create the file `/mnt/etc/nixos/hardware-configuration.nix` and remove the default configuration.nix file;
- Copy the hardware configuration to the [nix folder](nix)(which is ignored by git);
- Create a directory `/usr/share/dotfiles` and copy the nix repository to it;
- Create a backup of the `/mnt/etc/nixos` directory if it exists;
- Create a symlink to the nix repository in the `/etc/nixos` directory pointing to the `/usr/share/dotfiles/nix` directory;

##### Running NixOS Install

If you followed all the steps above you are ready to install NixOS.
Run the following command to install NixOS:

```bash
nixos-install --root /mnt --flake /mnt/usr/share/dotfiles/nix#default
#sudo  cp -r ./nixos-config/* /mnt/etc/nixos && nixos-install --root /mnt --flake /mnt/etc/nixos/nix/flakes/default#default
```

> Note: The `--flake /mnt/etc/nixos#nixos` is the path to the flake, you can change it to your own path if you want, and change the `#default` to the. name of the system you want to install.

Shutdown your machine and remove the USB drive(or the ISO) and boot your machine.

#### Post Installation

I recommend running the following commands after the installation:

```bash
    mkdir -p /usr/share/dotfiles && \
    [ -d /etc/nixos ] && mv /etc/nixos /etc/nixos.bkp; cp /mnt/etc/nixos.bkp/hardware-configuration.nix /usr/share/dotfiles/nix && ln -sfv /usr/share/dotfiles/nix /etc/nixos
```

## Nioscli

```bash
nix-env -i git && \
chmod +x ./nixos-config/nix/tools/nioscli && \
./nixos-config/nix/tools/nioscli create disko --path ./nixos-config/nix/disko/default/disko.nix  && \
./nixos-config/nix/tools/nioscli create hardware --no-filesystem --move-file --destination ./nixos-config/nix && \
./nixos-config/nix/tools/nioscli templates --src ./nixos-config/nix/templates --dest ./nixos-config/nix/ && \
nixos-install --root /mnt --flake ./nixos-config/nix#default  && \
[ -d /mnt/etc/nixos ] && cp -r /mnt/etc/nixos /mnt/etc/nixos.bkp;  rm -Rf /mnt/etc/nixos/* && cp -r ./nixos-config/nix/* /mnt/etc/nixos
```
