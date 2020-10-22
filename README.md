# act-build-base ![CI](https://github.com/httptoolkit/act-build-base/workflows/CI/badge.svg?branch=main)

> _Part of [HTTP Toolkit](https://httptoolkit.tech): powerful tools for building, testing & debugging HTTP(S)_

A base image for local GitHub Action builds with [Act](https://github.com/nektos/act).

By default, includes enough of the GitHub base image dependencies to:

* Run `setup-node` and `setup-python`
* Install & test standard node.js projects (with `setup-node`)
* Build & install native node modules (with `setup-python` too)
* Run Puppeteer or Karma tests in Chrome
* Remain far far smaller than Act's [full-fat environment](https://hub.docker.com/r/nektos/act-environments-ubuntu)