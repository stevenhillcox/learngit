cd "$( dirname "${BASH_SOURCE[0]}" )";

mkdir Unreachable;

cd Unreachable;

git init;

seq 3 | xargs -Iz git commit --allow-empty -m "An empty commit";

git tag release

git commit --allow-empty -m "A soon-to-be unreachable commit";