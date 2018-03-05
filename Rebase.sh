cd "$( dirname "${BASH_SOURCE[0]}" )";

mkdir Rebase;

cd Rebase;

git init;

echo "Hello World" >> file.txt;

git add file.txt;

git commit -m "First Commit";

git branch branch;

echo "Some more text" >> file.txt;

git commit -a -m "Second commit";

git checkout branch;

echo "Another file" >> file2.txt;

git add file2.txt;

git commit -m "Branch commit";

echo "Another file" >> file3.txt;

git add file3.txt;

git commit -m "Branch commit 2";