# Tutorial

## Setup

- Is usually run on Github Actions
- Can be run locally, see `run.sh` for plain R, or `render.sh` using Docker
- If run locally, a `.Renviron` file is needed with the requisite API key.

## API keys

Read the tutorial (natch) and get an API key.

## Setting up the API key for Github

Edit the `.Renviron` file, then set the API key using the `gh` command line tool:

```
gh secret set -f .Renviron
```

then check that they were actually set:

```
gh secret list
```


