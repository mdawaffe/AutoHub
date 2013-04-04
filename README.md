AutoHub
=======

Creates a Gist or GitHub repository out of the current directory.


Creating a Gist
---------------

By default, newly created **Gists are private**.

```bash
git gist [--description DESCRIPTION] [--public] [--remote REMOTE=origin]
```

`git gist` creates a new Gist, adds it as a remote to the current directory, and syncs its history and contents with the local repository.

If the directory is not already a git repository, a new git repository is initialized and **all files** in the directory are added/committed prior to the Gist creation.

Note: Gists cannot store directories.  This tool will fail ungracefully if the current directory has any subdirectories.

Note: If the directory is already a git repository, it must be in a clean state (nothing to commit, and no untracked files) or `git gist` will bail.
The clean state is necessary for the repository syncing hackery Gists require.


Creating a GitHub Repository
----------------------------

By default, newly created **GitHub repositories are public**.

```bash
git hubbit --name NAME [--description DESCRIPTION] [--private] [--org ORGANIZATION] [--team TEAM_ID] [--remote REMOTE=origin]
```

`git hubbit` creates a new GitHub repository, adds it as a remote to the current directory, and runs `git push`.

If the directory is not already a git repository, a new git repository is initialized and READMEs are added/committed prior to the GitHub repository creation.


Installation
------------

1. `./install.sh`
2. Enter your GitHub username and password when prompted.
3. That's it :)

Neither your username nor your password are stored locally.  An API token is stored in `git config --global AutoHub.token`.
