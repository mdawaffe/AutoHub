AutoHub
=======

Creates a Gist out of the current directory. By default, the newly created Gist is private.

```bash
git gist DESCRIPTION [PUBLIC=private]
```

If the directory was already a repository, a new Gist is created and added as a remote (as origin!).  The Gist's history is altered to match the local repository's.

If the directory is not already a repository, a new repository is initialized, all files in the directory are added to it, and the Gist remote is added.

Note: Gists cannot have directories.  This tool will fail if the current directory has any subdirectories in it.


Installation
------------

`./install.sh`

Enter your GitHub username and password when prompted.

That's it :)


Coming Soon(?)
--------------

Create a GitHub Repository out of any directory.
