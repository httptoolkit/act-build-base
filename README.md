# act-build-base ![CI](https://github.com/httptoolkit/act-build-base/workflows/CI/badge.svg?branch=main)

> _Part of [HTTP Toolkit](https://httptoolkit.tech): powerful tools for building, testing & debugging HTTP(S)_

A base image for local GitHub Action builds with [Act](https://github.com/nektos/act).

By default, includes enough to allow use of `setup-node` and `setup-python` actions, along with enough of the GitHub base image dependencies to successfully run Puppeteer or Karma tests in Chrome, but whilst remaining far far smaller than Act's full-fat environment.
