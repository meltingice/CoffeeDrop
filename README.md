<h1>RubyDrop</h1>

RubyDrop is my first ever Ruby project that aims to be an open-source, roll-your-own, Dropbox clone.  There's still a lot of details to work out, so you'll have to bear with me (it's a process).

<h1>How to Run</h1>

While the app doesn't really do anything right now (all it does is print file/directory changes to stdout), you can start it by simply running:

<pre>
./RubyDrop
</pre>

By default, the RubyDrop folder that it monitors is created (if it doesn't exist already) at ~/RubyDrop. To change this path, simply edit config.yml.

<h1>Handling Remote File Syncing</h1>

Perhaps the biggest question for this project is: how will the files sync between the client and server?  Some possibilities I thought of (some good, some bad):

* rsync
* simple tcp connection
* git
* capistrano
* scp/sftp

If you have any other (better?) ideas, feel free to share your thoughts in the wiki.
