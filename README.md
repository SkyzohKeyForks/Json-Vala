# Json-Vala #

#### *A JSON library written in Vala* ####

Discussion and support on IRC channel [#canaldev](http://webchat.freenode.net/?channels=#canaldev) (freenode).

[![Build Status](https://travis-ci.org/inizan-yannick/Json-Vala.png)](https://travis-ci.org/inizan-yannick/Json-Vala)

## Manual installation ##

### Requirements
 * valac (>= 0.17)
 * pkg-config
 * gobject-2.0 (>= 2.43)
 * glib-2.0 (>= 2.43)
 * gio-2.0 (>= 2.43)
 * gee-0.8 (>= 0.10.5)
 * at least libvala-0.24 (recommended) or libvala-0.22
 * mee-1.0 [Mee](https://github.com/inizan-yannick/mee)

On Debian based systems install following packages:

    sudo apt-get install build-essential valac-0.24 libvala-0.24-dev pkg-config libgee-0.8-dev

you have to include [vala-libs PPA](https://code.launchpad.net/~inizan-yannick/+archive/vala-libs) and [Ricotz PAP](https://launchpad.net/~ricotz/+archive/ubuntu/testing) first.

### Building ###
 1. `./autogen.sh`
 1. `make`

### Installation ###
 1. `sudo make install`
 1. `sudo ldconfig` (to update linker cache for the shared library)

## Contribution ##
See the wiki page for some information [Wiki](https://github.com/inizan-yannick/Json-Vala/wiki) or drop in on [#canaldev](http://webchat.freenode.net/?channels=#canaldev) (irc.freenode.net).

## License ##
Mee is distributed under the terms of the GNU General Public License version 3 or later and published by:
 * Yannick Inizan
