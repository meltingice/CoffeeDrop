<h1>RubyDrop</h1>

RubyDrop is my first ever Ruby project that aims to be an open-source, roll-your-own, Dropbox clone using Git as the backend.  There's still a lot of details to work out, so you'll have to bear with me (it's a process).

<h1>Prerequisites</h1>

* RubyGems
* <a href="https://github.com/schacon/grit">Grit</a>

<h1>How to Run</h1>

While the app doesn't really do much right now, you can start it by simply running:

<pre>
./RubyDrop &
</pre>

By default, the RubyDrop folder that it monitors is created (if it doesn't exist already) at ~/RubyDrop. To change this path, simply edit config.yml. It also initializes a Git repository in the folder automatically, if it doesn't already exist.

<h1>Handling Remote File Syncing and Tracking</h1>

After much deliberation, I have decided to go with Git for handling file tracking and remote file syncing.  We'll see how well this pans out...

Currently, you must manually create the git repo on your remote server. This will be automated as soon as I can write RubyDrop-Server.  If you are new to Git, this is how you do it (assuming you are SSH'd into your remote server):

First, you will probably want to make a new user for RubyDrop, and add your public SSH key to the list of authorized keys for the new user (not shown below)
<pre>
adduser rubydrop
</pre>

Then you will need to make the repository folder
<pre>
cd /home/rubydrop/
mkdir RubyDrop.git
</pre>

and finally, initialize the repository
<pre>
cd RubyDrop.git
git init --bare
</pre>

and that's it! Yes, I'm aware that was a really rough guide. It's only temporary for now anywyas.

<h1>Controlling RubyDrop</h1>
RubyDrop has a TCP interface that you can use to communicate with it while its running.  The simplest and easiest way to do so is by using telnet.

Here's an example that halts the RubyDrop daemon (by sending 'stop'):

<pre>
telnet localhost 11311
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Thu Nov 25 03:23:48 2010
Welcome to RubyDrop
stop
RubyDrop daemon halting!
Connection closed by foreign host.
</pre>

<h2>TCP Interface Commands</h2>
* config_get [name]
  * Retrieves the value from the RubyDrop config specified by [name]
* stop
  * Halts the daemon
* quit
  * Ends the TCP session, but leaves the daemon and TCP server running