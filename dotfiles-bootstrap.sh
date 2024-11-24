#!/bin/bash

# Check if Git is installed
if ! command -v git &> /dev/null; then
  echo "Error: Git is not installed."
  exit 1
fi

# Check if a repository URL is provided as an argument
if [ -z "$1" ]; then
  echo "Error: Please provide the repository URL as an argument."
  echo "Usage: $0 <repository_url>"
  exit 1
fi

# URL of the remote dotfiles repository (taken from the first argument)
REPO_URL="$1"

# Clone the dotfiles repository
git clone --bare "$REPO_URL" $HOME/.dotfiles

# Define the dotfiles function
function dotfiles {
  /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
}

mkdir -p .config-backup
dotfiles checkout

if [ $? = 0 ]; then
  echo "Checked out dotfiles.";
else
  echo "Backing up pre-existing dot files.";
  dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;

dotfiles checkout
dotfiles config status.showUntrackedFiles no

# not needed due to option preset in .gitconfig
#dotfiles push --set-upstream origin main

echo "Make sure to source ~/.bashrc."
exit 0
