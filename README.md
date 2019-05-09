[![Build Status](https://travis-ci.org/DFE-Digital/manage-courses-frontend.svg?branch=master)](https://travis-ci.org/DFE-Digital/manage-courses-frontend)
[![Build Status](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_apis/build/status/Find/manage-courses-frontend?branchName=master)](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build/latest?definitionId=29&branchName=master) [![Greenkeeper badge](https://badges.greenkeeper.io/DFE-Digital/manage-courses-frontend.svg)](https://greenkeeper.io/)

# Manage Courses Frontend

## Prerequisites

- Ruby 2.6.1
- NodeJS 8.11.x
- Yarn 1.12.x

## Setting up the app in development

1. Run `yarn` to install node dependencies
2. Run `bundle install` to install the gem dependencies
3. Run `touch config/settings/development.local.yml` and set a value for `dfe_signin.secret`
4. Run `bundle exec foreman start -f Procfile.dev` to launch the app on https://localhost:3000.

You will also need to add the automatically generated SSL certificate to your OS keychain. On macOS:

```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain config/localhost/https/localhost.crt
```

## Docker

Install Docker and Docker Compose.

```bash
docker-compose up --build
```

*Warning*: Running docker seems to slow down local development significantly on macOS.

## Running specs and linter (SCSS and Ruby)
```
bundle exec rake
```

## Running specs

```
bundle exec rspec
```

Or through guard (`--no-interactions` allows the use of `pry` inside tests):

```bash
bundle exec guard --no-interactions
```

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```bash
bundle exec rubocop app config db lib spec Gemfile --format clang -a

or

bundle exec govuk-lint-sass app/webpacker/styles
```

### Prettier

Auto-formatting is available using [prettier](https://github.com/prettier/plugin-ruby). To run on the entire project:

```bash
yarn
./node_modules/.bin/prettier --write '{app,config,lib,spec}/**/*.rb'
```

It's easier if you install a [plugin for your editor](https://prettier.io/docs/en/editors.html) and run it automatically when you save a file.

## Secrets vs Settings

Refer to the [the config gem](https://github.com/railsconfig/config#accessing-the-settings-object) to understand the `file based settings` loading order.

To override file based via `Machine based env variables settings`
```bash
cat config/settings.yml
file
  based
    settings
      env1: 'foo'
```

```bash
export SETTINGS__FILE__BASED__SETTINGS__ENV1="bar"
```

```ruby
puts Settings.file.based.setting.env1

bar
```

Refer to the [settings file](config/settings.yml) for all the settings required to run this app

## Sentry

To track exceptions through Sentry, configure the `SENTRY_DSN` environment variable:

```
SENTRY_DSN=https://aaa:bbb@sentry.io/123 rails s
```
