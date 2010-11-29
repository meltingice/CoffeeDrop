<h1>RubyDrop</h1>

RubyDrop is my first ever Ruby project that aims to be an open-source, roll-your-own, Dropbox clone using Git as the backend.  There's still a lot of details to work out, and the code may be a little messy, so you'll have to bear with me (it's a process).

<h1>Prerequisites</h1>

* RubyGems
* <a href="https://github.com/schacon/grit">Grit</a>

<h1>How to Run</h1>

You can start RubyDrop by simply running:

<pre>
./RubyDrop &
</pre>

By default, the RubyDrop folder that it monitors is created (if it doesn't exist already) at ~/RubyDrop. To change this path, simply edit config.yml. It also initializes a Git repository in the folder automatically, if it doesn't already exist.

<h1>Handling Remote File Syncing and Tracking</h1>

After much deliberation, I have decided to go with Git for handling file tracking and remote file syncing.  We'll see how well this pans out...

Currently, you must manually create the git repo on your remote server. This will be automated as soon as I can write RubyDrop-Server.  If you are new to Git, this is how you do it (assuming you are SSH'd into your remote server):

First, you will probably want to make a new user for RubyDrop:

<pre>
adduser rubydrop
</pre>

Then, make it possible for RubyDrop to make a passwordless SSH connection to the server:

["Shortest passwordless ssh tutorial, ever"](http://blogs.translucentcode.org/mick/archives/000230.html)

Finally, you will need to make the repository folder on the remote server:
<pre>
cd ~/
git init RubyDrop.git --bare
</pre>

That's it! Yes, I'm aware that was a really rough guide.

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