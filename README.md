# odin-cc

![docs/screenshot_logo.png](docs/screenshot_logo.png)

(code of above: [examples/logo_icon](https://github.com/cc4v/odin-cc-examples/blob/main/logo-icon/main.odin))

> [!WARNING]
> Currently at very early stage. API design may change.<br>
> (see [docs/coverage.md](docs/coverage.md))

Creative Coding framework on [Odin language](https://odin-lang.org/). Forked from [cc4v](https://github.com/cc4v/cc4v).

Aiming to provide APIs like [openFrameworks](https://openframeworks.cc/documentation/) or [Processing](https://processing.org/reference) on top of [Sokol](https://github.com/floooh/sokol) framework ([sokol-odin](https://github.com/floooh/sokol-odin/)), kind of like [V language](https://vlang.io/)'s [gg](https://modules.vlang.io/gg.html) wrapper and [cc4v](https://github.com/cc4v/cc4v), with a little essence of [Ebitengine](https://ebitengine.org/). (Please check [docs/api_design.md](docs/api_design.md))

Tested on Odin dev-2025-12-nightly

## Pre-requisites

### Install sokol-odin

odin-cc assumes `import "shared:sokol"` works. So you need:

- First, `git clone` [https://github.com/floooh/sokol-odin](https://github.com/floooh/sokol-odin)
- and build it by reading [README](https://github.com/floooh/sokol-odin/blob/main/README.md)
- then, copy `sokol` folder in it into `$ODIN_ROOT/shared/sokol` (`$ODIN_ROOT` can be found from `odin root` command.)

> [!NOTE]
> And more, you may need additional instructions for `stb` library use.<br>
> Instructions are shown if you have error, by Odin language compiler itself while using as normal.

## Install odin-cc (as a odin shared module)

```bash
$ export ODIN_ROOT="$(odin root)"
$ git clone https://github.com/cc4v/odin-cc $ODIN_ROOT/shared/cc

# NOTE: `$ODIN_ROOT` directory can be found by `odin root`.
#       You don't need first line if you copy it manually for example on Windows.
```

## Examples

see [odin-cc-examples](https://github.com/cc4v/odin-cc-examples) and [docs/coverage.md](docs/coverage.md).

```bash
$ git clone https://github.com/cc4v/odin-cc-examples
$ cd odin-cc-examples
$ odin run hello_world
```

## Contribution

Please check [docs/api_design.md](docs/api_design.md), [docs/coverage.md](docs/coverage.md), and [LICENSE.md](LICENSE.md).

Fork and create your version as you like. Feel free to create PR. If you have any questions or ideas, please use [discussions](https://github.com/cc4v/odin-cc/discussions) instead of issues. Issues are only for task tracking.
