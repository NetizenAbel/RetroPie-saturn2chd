# RetroPie PSX2CHD

A tool to compress PSX games into CHD format.

## Installation

```
cd /home/pi/
git clone https://github.com/kashaiahyah85/RetroPie-psx2chd
cd RetroPie-psx2chd
sudo chmod +x psx2chd.sh
```

## Updating

```
cd /home/pi/RetroPie-psx2chd/
git pull
```

## Usage

```
./RetroPie-psx2chd.sh [OPTIONS]
```

If no options are passed, you will be prompted with a usage example:

```
USAGE: ./RetroPie-psx2chd.sh [OPTIONS]

Use '--help' to see all the options.
```

## Options

* `--help`: Print the help message and exit.
* `--version`: Show script version.
* `--delete`: Delete original .bin and .cue files.

## Examples

### `--help`

Print the help message and exit.

### `--version`

Show script version.

## Changelog

See [CHANGELOG](/CHANGELOG.md).

## Contributing

See [CONTRIBUTING](/CONTRIBUTING.md).

## Authors

* Kashaiahyah85

## Credits

Thanks to:

* [hiulit](https://github.com/hiulit).

## License

[MIT](/LICENSE).
