# Json-Vala #

#### *A JSON library written in Vala* ####

Discussion and support on IRC channel [#canaldev](http://webchat.freenode.net/?channels=#canaldev) (freenode).

[![Build Status](https://travis-ci.org/inizan-yannick/Json-Vala.png)](https://travis-ci.org/inizan-yannick/Json-Vala)

## Manual installation ##

### Requirements
 * valac (>= 0.30)
 * pkg-config
 * gio-2.0 (>= 2.43)
 * gee-0.8

On Debian based systems install following packages:

    sudo apt-get install valac-0.28 libgee-0.8-dev

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
