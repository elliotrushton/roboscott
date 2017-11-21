Roboscott
=========

![Image of Robo Scott](https://robohash.org/robo%20scott)

A simple tool to parse YAML files and attempt to detect if secrets are stored in them.

Named after Scott who (rightfully) flips tables when secrets are commited to config files but was away one day and needed a proxy. 

Forked from [yaml-lint](https://github.com/Pryz/yaml-lint)

Motivation
----------

Secret and key management can be challenging if it's not already setup. Many legacy code bases have secrets or keys peppered through config files (or worse, hard coded - which is beyond the scope of this!). Detecting those keys quickly and easily, even if naively, is the goal of this project. For more information on best practices on storing keys see [12 Factor - Config](https://12factor.net/config "12-Factor Config")

Install
-------

# TODO NOT GEMIFIED YET

```shell
gem install roboscott
```

Usage
-----

Check a file

```shell
roboscott config.yml
```

Check all files, recursively, in a folder

```shell
roboscott my-legacy-app/
```

By default, roboscott will redact any sensitive findings, to remove this use `-u` or `--unredacted`
```shell
roboscott my-legacy-app/config/database.yml
Running in unredacted mode
File my-legacy-app/config/database.yml - The value 'hunter2' for key 'password' looks sensitive
```
