# openkeychain

Key-based Authentication


## Latest

v1.0.0


## Build

### Prerequisites

- [Aergo Ship](https://github.com/aergoio/ship/releases)
- AergoLuac from [Aergo](https://github.com/aergoio/aergo/releases)


### Build and Package

- Build

```console
$ ship build
```

- Binary

```console
$ aergoluac --payload openkeychain.lua
```


## Test

### Prerequisites

- Brick from [Aergo](https://github.com/aergoio/aergo/releases)

```console
$ brick src/test/brick/test-openkeychain.brick -v
```
