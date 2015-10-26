# docker-cookery

[![Build Status](https://img.shields.io/travis/kisoku/docker-cookery)](https://travis-ci.org/kisoku/docker-cookery)

[![Code Climate](https://img.shields.io/codeclimate/github/kisoku/docker-cookery)](https://codeclimate.com/github/kisoku/docker-cookery)

docker-cookery is a build system built around docker, fpm-cookery and aptly
that permits you to perform multi platform builds of fpm-cookery recipes from a
single linux machine.

It is heavily inspired by and intended to replace Debian's sbuild and reprepro tools.

Currently the following platforms are supported

* Ubuntu 10.04 LTS
* Ubuntu 12.04 LTS
* Ubuntu 14.04 LTS
* Centos 6
* Centos 7
* Debian 7
* Debian 8

## Getting Started

You will need the following pieces of software installed to use this tool

* docker
* aptly
* createrepo

Once you have installed these prerequisites you will need to build the docker
images and import them to your docker instance before being able to build any
packages

    $ docker-cook image build ubuntu-10.04

## Primitives

### image

The image primitive is responsible for managing the docker images used by
docker-cookery. It searches in the `docker_dir` for directories that contain
Dockerfiles. The names of these directories will be used as distribution
names.

docker-cookery searches the current user's directory for a
`.docker-cookery/docker` directory and falls back to the `docker` directory
contained in the docker-cookery gem if not found.

### recipe


### repo



<!--
vim: ft=markdown tw=80
-->
