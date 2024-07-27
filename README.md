# nix-config

Personal nix configuration files.
This repository contains my development environment configuration which are configured using Flakes and Disko.

## Table of Contents
- []
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

### Installing git

As I wan't to use my personal dotfiles, I needed to install git in the **iso** system, you can check more about why [here](#configurations-dotfiles)    

```bash
    nix-env -i git
```

It may take a while, but after the installation you can clone the repository, either using git or curl.

### Cloning the repository

You can clone the repository using:

- [Git](#cloning-the-repository-using-git);
- [Curl](#cloning-the-repository-using-curl);

#### Cloning the repository using git

```bash
    git clone https://github.com/dev-vinicius-andrade/nix-configuration.git
```

#### Cloning the repository using curl

```bash
     mkdir -p /root/nixos-configuration && \
    curl -L https://github.com/dev-vinicius-andrade/nix-configuration/archive/refs/heads/main.tar.gz | tar xz --strip-components=1 -C /root/nixos-configuration
```

> Note: You can change the directory to your own path if you want, but remember to change the path in the following commands.

### Prepare installation

There are several ways to install NixOs, I will describe the way I use to install it.

The repository contains a tool that I've called [nioscli](#nioscli) that I've developed to make the installation commands more verbose.
If you want to use this tool as well you **must** give it execution permission.

```bash
    chmod +x /root/nixos-configuration/nix/tools/nioscli
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

Or you can use the [nioscli](#nioscli) tool to do it:

```bash
/root/nixos-configuration/nix/tools/nioscli create disko --path /root/nixos-configuration/nix/disko/default/disko.nix
```

Here we are using the `disko` tool to bootstrap the disks, you can check the [disko.nix](nix/disko/default/disko.nix) file to see the configurations.
You can also check the [disko documentation here](https://github.com/nix-community/disko)

But basically we are enabling flakes and using their flake to generate the partitions using the [disko.nix](nix/disko/default/disko.nix) file;

##### Generating the hardware configuration

After bootstrapping the disks you need to generate the hardware configuration, to do it you can use the following command:

```bash
nixos-generate-config --root /mnt --no-filesystems && \
rm /mnt/etc/nixos/configuration.nix && \
cp /mnt/etc/nixos/hardware-configuration.nix /root/nixos-configuration/nix/hardware-configuration.nix
```

Or you can use the [nioscli](#nioscli) tool to do it:

```bash
/root/nixos-configuration/nix/tools/nioscli create hardware --no-filesystem --move-file --destination /root/nixos-configuration/nix
```

##### Generating the variables from the templates

If you choose to use the nioscli tool you can generate the variables from the templates using the following command:

```bash
./nixos-config/nix/tools/nioscli templates --src ./nixos-config/nix/templates --dest ./nixos-config/nix/ 
```

Or you can do it manually:

```bash
mkdir -p /root/nixos-configuration/nix/templates && \
cp -r /root/nixos-configuration/nix/templates/* /root/nixos-configuration/nix/
```

###### Changing the variables

After copying the templates to the variables directory, you can change according to your needs.
The idea of those files are not to replace the nixos way of doing things, but to make some common configurations that may vary from system to system easier to change.

Take a look at the files in the [templates folder](nix/templates/) to see the variables that you can change

- [common.template.nix](nix/templates/variables/common.template.nix) - A common sets of variables that will be used to all hosts.
- [hostname.template.nix](nix/templates/variables/hostname.template.nix) - A host specific configuration file.

##### Running NixOS Install

If you followed all the steps above you are ready to install NixOS.
Run the following command to install NixOS:

```bash
nixos-install --root /mnt --flake /root/nixos-configuration/nix#default
```

> Note: The `--flake /root/nixos-configuration/nix#default` is the path to the flake, you can change it to your own path if you want, and change the `#default` to the. name of the system you want to install.


##### Post Installation

After the installation copy the `/root/nixos-configuration/nix` directory to `/mnt/etc/nixos`:
This way you can keep the configurations in the default nixos configuration directory.

```bash
[ -d /mnt/etc/nixos ] && cp -r /mnt/etc/nixos /mnt/etc/nixos.bkp;  rm -Rf /mnt/etc/nixos/* && cp -r ./nixos-config/nix/* /mnt/etc/nixos
```

The command above will:

- Create a backup of the nixos configuration files;
- Remove the current configuration files;
- Copy the files from the repository to the nixos configuration directory.

Shutdown your machine and remove the USB drive(or the ISO) and boot your machine.

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

### Nixoscli

Nioscli is a cli tool that I've created to help me run some commands in the nixos installation process.
The main goal is not to create a tool to replace the nixos tools, but to help use the terminal in a more verbose way.
Currently I didn't have time to create a documentation for it, but you can use the `nioscli --help` to see the available commands.

Basically you can run bootrap the disks, generate the hardware configuration, generate the nixos configuration files;

## A Command To Rule Them All

If you want to run all the commands in one go you can use the following command:

```bash
nix-shell -p git && \
chmod +x ./nixos-config/nix/tools/nioscli && \
./nixos-config/nix/tools/nioscli create disko --path ./nixos-config/nix/disko/default/disko.nix  && \
./nixos-config/nix/tools/nioscli create hardware --no-filesystem --move-file --destination ./nixos-config/nix/hosts/example && \
./nixos-config/nix/tools/nioscli templates --src ./nixos-config/nix/templates --dest ./nixos-config/nix/ 

# I didn't put the nixos-install command together with the others, because you may want to personalize the variables before running the nixos-install command
# After running the commands above you can run the following command to install nixos
nixos-install --root /mnt --flake ./nixos-config/nix#example  && \
[ -d /mnt/etc/nixos ] && cp -r /mnt/etc/nixos /mnt/etc/nixos.bkp;  rm -Rf /mnt/etc/nixos/* && cp -r ./nixos-config/nix/* /mnt/etc/nixos
```
