# Introduction to Advanced Git

If you use git, your knowledge lies somewhere on a scale I have defined below.

## 5 Levels of git knowledge

1. I know almost nothing about git except maybe a few commands and roughly what they do.
2. I know the basics but nothing of how git works behind the scenes. I will ask for help if anything goes wrong
3. I know my way around and am comfortable googling for an answer if something goes wrong. I know a little bit about how git works under the hood.
4. I know how git works on a deeper level and can work out how to fix problems myself. I use google mainly as a reference when I forget commands.
5. I know basically everything there is to know and have set up advanced workflows.

This introduction is aimed at those who fit into levels 2 and 3.

## Confusing Git

Git was created by Linus Torvalds to achieve three goals:
 - Distributed
 - Performant
 - Highlights any corruption

He also considered CVS to be a perfect example of how 'not to do it' and tried to deviate as much as possible.

Note that "Easy to use" was not on that list.

Awesome talk by Linus from 2007: https://www.youtube.com/watch?v=4XpnKHJAok8

The more you learn about how git works behind the scenes, the more you will realise that the commands are a less than perfect way of interacting with the git data model.

If you learn how git actually works, it can go a long way to trying to understand the commands.

### Some fun git error messages and quirks

Git has many fun error messages

> fatal: unknown style 'diff' given for 'merge.conflictstyle'

> refusing to update checked out branch: refs/heads/master. By default, updating the current branch in a non-bare repository is denied, because it will make the index and work tree inconsistent with what you pushed, and will require ‘git reset –hard’ to match the work tree to HEAD.

>  Updates were rejected because the tip of your current branch is behind its remote counterpart. Merge the remote changes (e.g. 'git pull') before pushing again. See the 'Note about fast-forwards' in 'git push --help' for details.

`git checkout` Does 4 different things based on the flags given
(move the head, create a new branch, detach head and create patches)

https://git-man-page-generator.lokaltog.net

Git can be non intuitive at times but it's super simple when you know how it works.

https://xkcd.com/1597/

## Key Value Pairs

At it's core, git is a collection of key value pairs. The keys are SHA1 hashes of the values. (This is how we can spot corruption)

You might have seen these hashes before. In general you only ever have to provide enough of the hash to uniquely identify it (but at least 4 characters)

## File structure

Git makes a bunch of folders in .git/

If we look at a new project we have the following structure:

HEAD
config
description
hooks
info
objects
refs

The bare minimum needed to be a git repo is HEAD, an objects folder and a refs folder.
A lot of the folders aren't hugely interesting or important.

 - HEAD points to the working copy (what's actually in your file system)
 - Config stores project specific configuration
 - Description is used by gitweb. Old and mainly unused by devs.
 - Hooks stores hook scripts. Let's not discuss them for now.
 - Info stores things like file exclusions that you don't want committed via the usual .gitignore

Objects and Refs is where it starts getting interesting

## Objects

These will start off more or less empty when the repo is made.
If we create a new file and `git add` it, will will see that a new object is created in the objects folder. Specifically a new folder with the first two characters of the hash with a file named after the remaining characters.

We didn't even have to commit anything but git has already started remembering our files.

This is one of the reasons we say that it is hard to lose work that is tracked by git.

If we look at the new object created we will see some unhelpful binary. To see the contents of the object we need to use `git cat-file -b <hash>`. We can also use `git show <hash>` though this is a newer command and won't work on older versions of git.

Looking at the object we see that it contains exactly the file that we just created.

Contrary to what many believe, git does not work by storing incremental patches. We store the entire file system every time we commit. Sort of. (More on this coming up)

If we commit our added files we will see that there are now two more objects created. Why two?

Let's have a look at our two new objects. If we use `git cat-file -t <hash>` we can inspect the type of our new objects. 

We can see that they are type 'commit' and 'tree'. (The first one was of type 'blob') Let's now take a look at their contents. We can use `git cat-file -b <hash>` again to do this.

Let's first look at our commit. We will see something that looks like this:

```
tree 0000000000000000000000000000000000000000
author Your Name <> 0000000000 +0000
committer Your Name <> 0000000000 +0000

First commit!
```

Which is more or less what we would expect. We see an author name, a committer name (Both are usually the same) and a commit message. This is our first commit so we don't have a parent commit but if we did, that would be listed as well.
There is one line of note here though. The first line. What is a tree object anyway?

Let's look at the tree object now. We can see using the trusty `git cat-file -b <hash>` command that it contains pointers to the blobs that make up the commit. This is how the git magic works. We have commit -> tree -> files. 

Most interestingly, when you only change a few files, the tree can continue to point to the old blobs for files that haven't changed. Old blobs aren't however thrown away. This is why we can say that git stores the entire copy of your directory at each commit but not take up vast amounts of space on your HDD.

## Refs

There are three main folders here.
 - heads
 - remotes
 - tags

Heads is just another way of saying branches and the latter two should be obvious.
In these folders are files/folders who's name matches your refs. If your branch/tag names include slashes this is reflected in the folder structure.

These files contain just one line each, the commit hash that they point to. That is all they are, glorified pointers.

HEAD (found in the root folder and in refs/remotes) is a little bit different. Typically this will point to a branch or tag name. e.g. `ref: refs/heads/master`.
This isn't always the case though. If you are in a detached head state (more on that later) then this will point to a commit in the same way as other refs.

## Index / Staging area

You will have noticed that there is two steps to the committing process in git. We first add files to the staging area `git add` and then commit these changes. But what is really going on here?

When we add files to git, we have seen before that blobs are immediately created and stored as objects but how does git keep track of what is ready to be committed?

Remember that git does not work on a system of diffs or patches. When we commit, we commit everything and that is exactly what git remembers in the index.

The index can be found in the root .git file but trying to inspect it's contents isn't very helpful. It is just a binary file. If we want to have a look at the index we need to use `git ls-files --stage`

The index contains a list of all of our tracked files and the object hashes that link to the the blobs that represent them. Which blobs though? There might be many blobs that represent a single file. Various different versions of the file's history.

The easiest way to imagine the index is as a snapshot of what a new commit would look like if we committed right now. If a file is unchanged compared to our current HEAD, then the blob will be the blob referenced in the HEAD tree. if the file is changed and staged (with a `git add`) then the index will reference the new blob.

We can build up a picture of the differences between the working copy of files, the index and HEAD using `git diff`.

`git diff --cached` Will show us the difference between the index and HEAD. This is a simple way of seeing exactly what the overall changes of our next commit would be.

`git diff` Will show the differences between the index and the working copy of files. In other words, unstaged changes.

`git diff HEAD` Will show the difference between the working copy and HEAD (or any other given hash). This is probably what most people will use the diffing tool for.

An important point to note is that untracked files (files git has never heard of) won't show up in any of these diffs.

So to summarise, a tracked file is one that appears in the index. A staged file is the one that referenced by the index. The index contains references to whatever git currently considers to be the most up to date blobs and whatever is in the index when we commit becomes the new commit.

## What is going on when I...

Now that we know how the file structure is working for us under the hood, let's take a step back and look at the commit hierarchy and how git manipulates it for us as we run various commands.

### Commit

The first fundamental building block of a git history is the commit. This one isn't that difficult but let's break it down.

1. First we create our new commit.
2. Set parent of the new commit to our current commit.
3. Update current branch pointer to point at our new commit.
4. Update HEAD to point to new commit if in a detached head state.

Not too difficult. The final step rarely happens. It's not often that you will be committing in a detached head state, but I put it in for completeness sake. Bonus question, why don't we need step 4 if we aren't in a detached head state?

### Merge

This time, things get a bit more complicated, but only due to the branching possibilities.

The typical flow here is: 

1. Compare current commit (HEAD) with the target commit.
2. Resolve any merge conflicts and create a new commit with changes.
3. Set parents of the new commit to be the current commit and the target.
4. Update current branch pointer to point at our new commit
5. Update HEAD to point to new commit if in a detached head state.

First off, yes a commit can have multiple parents. Secondly, yes this looks a lot like committing. What we are basically doing is creating a new commit and setting it to have two parents instead of one. 

A lot of our merges are actually the result of a `git pull`. (Which is just a fetch and merge) In this case, there is a high probability we are just pulling updates to our current branch added by someone else.

More precisely, we can say that HEAD is an ancestor of the target commit. (i.e. the target commit is a decedent of HEAD). In this case, git can do a fast forward merge. Skipping steps 1 - 3.

If you don't want this to happen and still want a commit (You probably don't want to do this) you can run `git merge --no-ff`.

### Rebase

This one is often seen as the more complicated and scary version of a merge. These fears are mostly unfounded but it is easy to see why people might think this way.

Rebasing achieves many of the same goals as merging. We have some work on another branch or commit and we want it in our current branch. Rebasing goes about it in a slightly different way.

The clue to what happens in a rebase is in the name. We are taking our current branch of work and changing it's base commit. Imagine picking up the branch and moving it on top of another commit.

The difficult part is making sure that the transition from the tip of the target branch to the root of our current branch is seamless.

The steps we take are as follows:

1. Step back through the current branch until we find a common ancestor of both our HEAD and target commit. For each commit, create a patch and store them in order.
2. Checkout the target commit.
3. For each patch:
    * Apply on top of the target. (now current) 
    * Prompt user for fixes if we run into conflicts. 
    * If possible we keep the commit message from the patch.

Git gives us interesting messages explaining this process using words like 'rewinding' and 'replaying' but in simple terms, we are just taking the current branch and recommitting it on top of our target commit.

This does mean that we will need to manually stitch the commits back together if there discrepancies. Git will open up vim (or whatever you have configured) if this happens and you will have to manually create a resolution commit.

The practical upshot of this is that the history will read as one line of continuous commits. 

### Various others

There are various other commands that modify our git history, far too many to mention. The three most essential have been mentioned above. All others tend to be more geared towards editing the contents of the object files or are variants of those mentioned already. 

Some notable mentions:

#### Checkout

1. If a known branch name is given, find commit hash of branch.
2. Update contents of working directory to those of the target commit.
3. Update HEAD to point to new branch (or target commit if hash is given).

#### Branch

1. Create a new branch in refs
2. Point branch at HEAD commit.

#### Tag

1. Create a new tag in tags
2. Point tag at HEAD commit.

Notice how tags and branches are basically the same.

## Reflog

Git stores comprehensive logs of all actions made upon each of its refs. (Remember that ref is just a fancy word for 'branch') You can have a look at these logs by running `git reflog <ref>` There is a reflog for HEAD too which is the default if you don't supply a ref.

The logs are stores in `.git/logs/<ref>` and are stored in plaintext so you can you read them without using git if you wish. They look a little bit like this:

> 675b59 HEAD@{1}: checkout: moving from master to 77c5bc1  
> d675b59 HEAD@{2}: checkout: moving from 77c5bc1cb22a6aa0fa5551e9e0f14905e8f85ebe to master

People will often jump to the reflog when trying to piece together what went wrong after some slipup. The reflog also retains references to lost commits (more on that coming up)

The reflog will automatically prune itself of old entries. By default this is 90 days but you can change this if you wish, or manually clear it out yourself.

## Losing Work

It is very hard to lose work in git. So long as you have tracked a file (`git add`) then it is 'safe'. The only way that work can be lost forever in git is typically through deliberate actions that git is very quick to warn you about. 

Let's examine some of the more common ways you might accidentally find yourself losing work.

### Unreachable commits

We have mentioned a 'detached head state' before. This is what happens when you checkout a commit that is not pointed to by any branch. In other words, a commit that is not at the tip of any branch.

Git can easily see if this is the case by checking HEAD and seeing that it points to a commit hash instead of a branch name.

Git tells you that you are in a detached head state and sums up what you can do in this state:

> You are in 'detached HEAD' state. You can look around, make experimental changes and commit them, and you can discard any commits you make in this state without impacting any branches by performing another checkout.

Basically anything you can do before, just remember that you won't affect any of the branches in this state.

If you were to make a commit in this state and then checkout a branch again, git will give you a warning something like the following:

> Warning: you are leaving 1 commit behind, not connected to any of your branches

This might seem as though the new commit is going to disappear but that is not the case. If you remember the commit hash or look it up in the reflog you can checkout the commit again. At least for now.

You can also 'lose' commits during interactive rebases and the such. When you think you have 'deleted' a commit or removed it from existence by squashing it away, it is still alive, hidden away from the git history.

The reflog will eventually prune the entry for being too old and after this the git garbage collection will see the commit as being both unreachable and no longer referenced. In this case, your commit will be deleted.

If you want, you can try this out by running the following two commands:

```
git reflog expire --expire-unreachable=now --all
git gc --prune=now
```

This is one of the very few ways that it is possible to lose committed work. The other being the use of the --force flag when pushing.

### --Force

Another possibly more egregious example of commit erasure in git is through the notorious `git push --force`. This command is strongly discouraged and with good reason. It will forcibly push your changes to the remote and update the branch to point at your newest commit. 

This is basically the same as copy-pasting your local repo on top of whatever is on the remote. This is a destructive operation, removing any work that has already been pushed by someone else. If they try to push afterwards they will likely get the nasty error message we saw earlier.

Many people recognise the need for the --force command, for example when rebasing on top of changes added by others after you have already initially pushed. They will sometimes use phrases like "Never use --force _unless you know what you are doing_". 

This is still wrong. Unless you are deliberately trying to erase history, **there is no reason to ever use the --force option**.

You could try to mitigate the damage by specifying only a single branch by using 
`git push --force +branch_name`

But this is still wrong. Instead, if you ever feel that a force push is needed, you should use

`git push --force-with-lease branch_name`

What does this do? Think of it as a safer version of --push. When we force with lease, we first check that the remote branch we are pushing to is in the state that we expect it to be in. 

This can be configured but by default it will check the hash of your local tracked remote branch against that of the remote. If the two differ, the command will fail and you will have to resolve by pulling and merging/rebasing first.

### Deleting Git Files

One obvious way of losing git history is to delete files in the .git folder.

Don't do that.

## Cool Bits and Pieces

### Pretty log

`git log --graph --oneline --decorate --all` 
and 
`git config --global alias.lg 'log --graph --oneline --decorate --all'`

--graph prints out pretty ACSII art.

--oneline removes the message and author name.

--decorate prints the commit hash in short form.

--all shows branches we are not currently on. 

You might want to remove --all or set up multiple aliases with and without it.

### Bisect

`git bisect start`

`git bisect good <hash>`

`git bisect bad <hash>`

`git bisect run <script> <args>`

We can use git bisect to identify a breaking commit. Internally does this by doing a binary search between the last commit you mark as being 'good' and the first that you mark as being 'bad'. (Not supplying a hash defaults to HEAD)

Git will keep checking out new commits until you mark one as good and the following as bad. At this point the bisect process will end and HEAD will be pointed at the 'bad' commit.

You can also set up bisect to automatically find the offending commit by using `git bisect run <script> <args>`. This will run the script and interpret a 1 - 125 exit code as a bad commit and a 0 exit as a good. An obvious example of such a script is running your tests.

Be careful when running bisect as git does actually checkout the code at each step. This means that whatever tools or processes you are using to verify the commit needs to either not be part of the source control or needs to exist in every commit. You can run using --no-checkout but it is unlikely that this will actually be useful.

### What has changed

`git whatchanged --since="2 hours ago"`
Prints out files changes and commits within the specified time
You can use plain english in the since flag string

### A peek into git blobs

`git show <hash>`
Shoes the contents of a commit, blob or tree. More modern alternative to `cat-file` and `ls-tree`

### Quick amend

`git commit -v --amend`
Lets you reword your most recent commit.

### Revert/Reverse

`git revert <hash>`

Creates a new commit with the opposite change set as the target commit. Effectively this reverses this commit but leaves a record of both in the history. 

This feels clunky but is much better than any alternative if your code is already pushed and shared with others.

### Blame

`git blame <file>`
`git blame -L <start>,<end>`

Annotates a file with the name of who was last responsible for each line. You can limit the lines by passing them in as parameters. Useful for obvious reasons.

https://www.google.co.uk/search?q=git+blame