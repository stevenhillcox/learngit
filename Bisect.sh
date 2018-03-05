cd "$( dirname "${BASH_SOURCE[0]}" )";

mkdir Bisect;

cd Bisect;

git init;

cat > package.json <<- EOM
{
  "name": "gitbisect",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "jasmine *.spec.js"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "jasmine": "^3.0.0"
  }
}
EOM

npm install;

echo "node_modules" >> .gitignore;

cat > example.spec.js <<- EOM
describe("A basic example test", function() {
    it("Always passes", function() {
        expect(true).toBe(true);
    });
});
EOM

git add .

git commit -m "First Commit";

seq 10 | xargs -Iz git commit --allow-empty -m "An empty commit";

sed -i '' "s/toBe(true)/toBe(false)/g" example.spec.js;

git commit -a -m "Breaking Commit";

seq 10 | xargs -Iz git commit --allow-empty -m "An empty commit";

