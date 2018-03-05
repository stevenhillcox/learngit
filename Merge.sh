cd "$( dirname "${BASH_SOURCE[0]}" )";

mkdir Merge;

cd Merge;

git init;

echo "Hello World" >> file.txt;

git add file.txt;

git commit -m "First Commit";

git checkout -b branch;

echo "Another file" >> file2.txt;

git add file2.txt;

git commit -m "Branch commit";

git checkout master;

echo "Some more text" >> file.txt;

git commit -a -m "Second commit";