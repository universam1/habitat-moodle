# Office 365 plugins for Moodle #

## Prerequisites ##

* a working habitat studio
* my/moodle habitat package running as service. For details read README.md for moodle package.
* command are executed from working directory: `/src/` inside the studio

### Build the package ###

```shell
build moodle-plugin-o365
```

### Start this theme as service ###

```shell
hab start my/moodle-plugin-o365 # alias of "hab sup start"
sl # alias to see the Supervisor Log; Ctrl + C to exit it
```
