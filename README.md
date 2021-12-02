# GitLab-Pages-Deploy  
Bash to deploy GitLab Pages in a branch like gh-pages  
_(Highly inspired from https://github.com/marketplace/actions/gh-pages-deploy)_

It allows to keep track of modifications between to publications

- This creates a branch named "gh-pages"
- This stores the content of your "public/" directory inside
- On GitLab, you can choose to publish the "gh-pages" branch instead of the public artifacts using this in the ".gitlab-ci.yml":

```yaml
pages:
    stage: deploy
    script:
        - echo "deploy"
    artifacts:
        paths:
            - public
    only:
        - gh-pages
```
