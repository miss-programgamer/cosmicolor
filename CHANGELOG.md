# Changelog

## v0.1.4 - Future

- Now checking STDOUT and STDERR separately. This means piping to a file will no longer disable colors for STDERR & vice-versa.
- Fixed bugs in `cwritef` that had gone unnoticed due to low usage on my part.

## v0.1.3 - October 2nd 2025

- Made console automatically use UTF-8 on Windows.

## v0.1.2 - September 30th 2025

- Made entire API surface explicitly @safe.
- Documented constant enable_color.

## v0.1.1 - September 30th 2025

- Added changelog (this file).
- Removed erroneous version tag in dub recipe.

## v0.1.0 - September 29th 2025

- Initial release.