# CoffeeDrop

CoffeeDrop aims to be an open-source, roll-your-own, Dropbox clone written in Coffeescript that runs in NodeJS. It is currently under heavy development and is not in a working state. I was storing the code in a private repository, but I decided to go public with it in case anyone wants to give feedback or contribute to the early stages.

Originally, the project was written in Ruby and was named RubyDrop, but for various reasons (mostly frustration), I decided to try something completely new and fresh. The [old Ruby code](http://github.com/meltingice/RubyDrop) is still available on Github.

# Prerequisites

* NodeJS
* CoffeeScript (if developing)
* NPM packages
	* colors
	* cli
	* daemon
	* sqlite
	
# Install

Since CoffeeDrop is in such an early state, it is not available to install via NPM yet. You can install all the dependencies by running:

	npm install coffee-script colors cli daemon sqlite -g
	
# Running

To run CoffeeDrop, simply execute the CoffeeDrop binary in your Terminal.  Use the --help option to show the help text to see the various commands (most of which are useless at this point in time).