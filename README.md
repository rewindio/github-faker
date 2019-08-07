# github-faker
Create GitHub repositories / issues with fake data

## Usage

1. git clone this repo
2. Create a personal access token for your GitHub user
3. Create a `.env` file and set the token as well as the username
    ```
    GITHUB_TOKEN=not_the_token
    GITHUB_TARGET_USER=not_the_user
    ```
4. Install gem dependencies
    ```bash
    bundle install --path vendor/bundle
    ```
5. bundle exec rake --tasks
    ```bash
    # Create fake repositories
    bundle exec rake github_faker:create_repositories[quantity]
    
    # Create fake issues
    bundle exec rake github_faker:create_issues[repository,quantity]
```
