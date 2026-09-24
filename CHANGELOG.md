# Changelog

## 1.3.4

- Honor `-f` and `--script_file` for the generated launcher in test and install modes.
- Add `(AirPrint)` to the advertised service name to avoid the native macOS Printer Sharing IPP name collision.
- Reload the installed advertiser when `-i` is run again after an upgrade.

Thanks to [@RaulGomezI2a](https://github.com/RaulGomezI2a) for reporting the launcher and service-name problems in [#39](https://github.com/sapireli/AirPrint_Bridge/issues/39), and to [@mfbergmann](https://github.com/mfbergmann) for confirming the collision and suggesting the AirPrint name suffix.
