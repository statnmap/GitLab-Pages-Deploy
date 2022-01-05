# GitLab-Pages-Deploy  
Bash to deploy GitLab Pages in a branch like gh-pages  
_(Highly inspired from https://github.com/marketplace/actions/gh-pages-deploy)_

It allows to keep track of modifications between to publications

- This creates a branch named "gh-pages"
- This stores the content of your branch "public/" directory inside

Also, if you want to be able to render the website for some specific branches, without deleting the 'main' one, you can use sub-website build. See [Publish one sub-website for each branch](https://github.com/statnmap/GitLab-Pages-Deploy#publish-one-site-for-each-branch)

## Prepare the "gitlab-ci.yml"
On GitLab, you can choose to publish the "gh-pages" branch instead of the public artifacts using this in the ".gitlab-ci.yml":

```yaml
gh-pages-prep:
    stage: prepare-deploy
    only:
      - main
    script:
      # Deploy a unique site in gh-pages branch,
      # or a sub-website for each branch if SITE_BY_BRANCH: "TRUE"
      - wget https://raw.githubusercontent.com/statnmap/GitLab-Pages-Deploy/main/deploy_pages_branch.sh
      - /bin/bash deploy_pages_branch.sh
      
pages:
    stage: deploy
    script:
        - echo "deploy"
    artifacts:
        paths:
            - public
    only:
        # Because we use "deploy_pages_branch", only gh-pages branch needs to be deployed
        # All outputs from other branches in "prepare-deploy" step will push in "gh-pages"
        - gh-pages
```

Also think about using `except: gh-pages` in your other stages because no file is available for this branch.

## Create your token to allow push

### Create New project token  

- Go to: Settings > Access Token
  - If it is not activated, use a personal access token: https://gitlab.com/-/profile/personal_access_tokens
- Choose a proper name to recognize it when you'll want to revoke it
- Check access: read_repository and write_repository
- Save your token, you will only see it once

<img src="https://user-images.githubusercontent.com/21193866/144649526-59017727-a804-48c0-934c-8306d2059f36.png" alt="drawing" width="600"/>

### Add token in the CI/CD variables as `PROJECT_ACCESS_TOKEN`

- Go to: Settings > CI/CD > Variables
- Expand the section
- Add variable
- Fill key with `PROJECT_ACCESS_TOKEN`
- Fill the token with the one you saved above
- Add variable

<img src="https://user-images.githubusercontent.com/21193866/144649687-d18ce555-827e-44ad-82e8-dfb7f3966bec.png" alt="PROJECT_ACCESS_TOKEN" width="600"/>


## Publish one sub-website for each branch

If you use the environment variable :
```yaml
variables:
  SITE_BY_BRANCH: "TRUE"
  
 gh-pages-prep:
    stage: prepare-deploy
    only:
      - master
      - main
      - production
      - validation
    script:
      # Deploy a unique site in gh-pages branch,
      # or a sub-website for each branch if SITE_BY_BRANCH: "TRUE"
      - wget https://raw.githubusercontent.com/statnmap/GitLab-Pages-Deploy/main/deploy_pages_branch.sh
      - /bin/bash deploy_pages_branch.sh
      
pages:
    stage: deploy
    script:
        - echo "deploy"
    artifacts:
        paths:
            - public
    only:
        # Because we use "deploy_pages_branch", only gh-pages branch needs to be deployed
        # All outputs from other branches in "prepare-deploy" step will push in "gh-pages"
        - gh-pages
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
