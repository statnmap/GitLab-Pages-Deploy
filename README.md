# GitLab-Pages-Deploy  
Bash to deploy GitLab Pages in a branch like gh-pages  
_(Highly inspired from https://github.com/marketplace/actions/gh-pages-deploy)_

It allows to keep track of modifications between to publications

- This creates a branch named "gh-pages"
- This stores the content of your branch "public/" directory inside
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

Also think about using `except: gh-pages` in your other stages because no file is available for this branch.

## Create your token to allow push

### Create New project token  
<img src="https://user-images.githubusercontent.com/21193866/144649526-59017727-a804-48c0-934c-8306d2059f36.png" alt="drawing" width="600"/>

### Add token in the CI/CD variables as `PROJECT_ACCESS_TOKEN`
<img src="https://user-images.githubusercontent.com/21193866/144649687-d18ce555-827e-44ad-82e8-dfb7f3966bec.png" alt="PROJECT_ACCESS_TOKEN" width="600"/>


## Publish one site for each branch

If you use the environment variable :
```yaml
variables:
  SITE_BY_BRANCH: "TRUE"
```

The 'gh-pages' branch will keep site content of other published branches in a dedicated subdirectory.  
This will then create an index file at the root of your website to let you choose which version you want to see.

```html
<h2>Index of branch directories</h2>

- index.html
- master
- production
- validation
- other-branch
```
