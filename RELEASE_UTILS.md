# Releases Utils

Quick redo a release:

```bash

export RELEASE_VERSION='0.0.1'

git push --delete origin ${RELEASE_VERSION} && git tag -d ${RELEASE_VERSION} && git flow release start ${RELEASE_VERSION} && git flow release finish ${RELEASE_VERSION} && git push -u origin --all && git push -u origin --tags
```
