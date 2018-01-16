
From: https://stackoverflow.com/questions/37471740/how-to-copy-commits-from-one-git-repo-to-another

Is there a way I have get the commits into new repo (this time the first commit is the LICENSE file) and still keep the commit meta info?

Yes, by adding a remote and cherry-picking the commits on top of your first commit.

# add the old repo as a remote repository 
git remote add oldrepo https://github.com/path/to/oldrepo

# get the old repo commits
git remote update

# examine the whole tree
git log --all --oneline --graph --decorate --abbrev-commit

# copy (cherry-pick) the commits from the old repo into your new local one
git cherry-pick sha-of-commit-one
git cherry-pick sha-of-commit-two
git cherry-pick sha-of-commit-three

# check your local repo is correct
git log

# send your new tree (repo state) to github
git push origin master

# remove the now-unneeded reference to oldrepo
git remote remove oldrepo
