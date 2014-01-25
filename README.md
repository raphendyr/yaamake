Yet Another AVR Make
====================

Yaamake is handy makefile system to be used with gnu make for building and programming AVR projects
IT allows you to write simple `Makefile` with few variable definitions and supplies lot of defined targets (actions).

Yaamake is mainly used by [YAAL](https://github.com/raphendyr/yaal) project, but it's also very useful separately.

Installation
------------

Ideally yaamake would be installed trough distributions package management, but that's not yet possible (working on it).
Best what you can do now is to add my [PPA](http://deb.n-1.fi) and install from there.
That site contains debian packages made from branch `debian` (Debian packaging branch).

When you do not have administration rights (to install packages) use `make install`.
It will install `yaamake` into `$HOME/.local/bin` (add that into your `PATH`).

Alternatively you can add yaamake as submodule:

```sh
git submodule add https://github.com/raphendyr/yaamake.git vendor/yaamake
(cd vendor/yaamake && make NO_TEENSY=1)
```

Test your installation running command `yaamake --version`


Usage
-----

You would start project using yaamake with following commands:

```sh
mkdir my_project_path
cd my_project_path
git init .
# add yaamake submodule here, if needed
yaamake --init-project --make-initial # or ./vendor/yaamake/yaamake if using submodule
git commit --amend -m "Project initialization"
```

Last line is optional as yaamake creates you the initial commit. You should edit the message (the last line) to be more suitable to you.

Then start by editing `Makefile` to match your hardware and write test code into `main.c` or `main.cpp` (or anything else and use `SRC` variable).
After that run `make` to build it and `make program` to flash your chip.

If you are using teensy, remove parameter `NO_TEENSY=1` from above (building `teensy_loader_cli` requires libusb-dev or similar package).


User defaults
-------------

You can create `~/.yaamake.mk` which will be included by yaamake when you run `make` in your project.
This allows you to define personal style variables and to give default values to variables.

For example:

```makefile
# Makefile defaults for yaamake

COLORS := 1

PORT ?= /dev/ttyUSB0
YAAL ?= $(HOME)/custom/yaal/path
```


License and using
-----------------

There is no known license for now, but you are allowed to use this for non commercial use.

For commercial use, please create an issue and we will fix this issue then.

If you happen to use this project to anything, please be nice and create issue for adding link to your project.

Any feedback is also very welcome.
