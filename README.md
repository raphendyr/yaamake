Yet Another AVR Make
====================

Yaamake is handy makefile system to be used with gnu make for building and programming AVR projects
IT allows you to write simple `Makefile` with few variable definitions and supplies lot of defined targets (actions).

Yaamake is mainly used by [YAAL](https://github.com/raphendyr/yaal) project, but it's also very useful separately.

Usage
-----

Ideally yaamake would be installed trough distributions package management, but that's not yet possible (working on it).
For now and when some project members are unable to do that, you should add yaamake as submodule.
Follow these commands:

```sh
mkdir my_project_path
cd my_project_path
git init .
git submodule add https://github.com/raphendyr/yaamake.git vendor/yaamake
(cd vendor/yaamake && make NO_TEENSY=1)
./vendor/yaamake/yaamake --init-project --make-initial
git commit --amend -m "Project initialization"
```

Last line is optional as yaamake creates you the initial commit. You should edit the message (the last line) to be more suitable to you.

Then start by editing `Makefile` to match your hardware and write test code into `main.c` or `main.cpp` (or anything else and use `SRC` variable).
After that run `make` to build it and `make program` to flash your chip.

If you are using teensy, remove parameter `NO_TEENSY=1` from above (building `teensy_loader_cli` requires libusb-dev or similar package).

License and using
-----------------

There is no known license for now, but you are allowed to use this for non commercial use.

For commercial use, please create an issue and we will fix this issue then.

If you happen to use this project to anything, please be nice and create issue for adding link to your project.

Any feedback is also very welcome.
