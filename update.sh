REPO=https://github.com/dcg-udl-cat/ScientificAnalyzer.git

git pull $REPO

# Check for changes in the master branch
if [ -n "$(git status --porcelain)" ]; then
    echo "Changes detected, recreating project..."
    
    # Rebuild the project
    make build

    echo "Project successfully recreated."
else
    echo "No changes detected. Project is up to date."
fi