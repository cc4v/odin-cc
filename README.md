# odin-cc

> [!WARNING]
> ***WORK IN PROGRESS*** (Currently at very early stage. API design may change.)<br>
> (see [docs/coverage.md](docs/coverage.md))

Creative Coding framework on [Odin language](https://odin-lang.org/). Forked from [cc4v](https://github.com/cc4v/cc4v).

Aiming to provide APIs like [openFrameworks](https://openframeworks.cc/documentation/) or [Processing](https://processing.org/reference) on [Sokol](https://github.com/floooh/sokol) ([sokol-odin](https://github.com/floooh/sokol-odin/)), kind of like [V](https://vlang.io/) / [gg](https://modules.vlang.io/gg.html) and [cc4v](https://github.com/cc4v/cc4v), with a little essence of [Ebitengine](https://ebitengine.org/). (Please check [docs/api_design.md](docs/api_design.md))

Tested on Odin dev-2025-12-nightly

## Pre-requisites

### Install sokol-odin

odin-cc assumes `import "shared:sokol"` works. So you need:

- First, `git clone` [https://github.com/floooh/sokol-odin](https://github.com/floooh/sokol-odin)
- and build it by reading [README](https://github.com/floooh/sokol-odin/blob/main/README.md)
- then, copy `sokol` folder in it into `$ODIN_ROOT/shared/sokol` (`$ODIN_ROOT` can be found from `odin root` co
mmand.)

## Install

> [!NOTE]
> `$ODIN_ROOT` directory can be found by `odin root`

```bash
$ git clone https://github.com/cc4v/odin-cc $ODIN_ROOT/shared/cc
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
