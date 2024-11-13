# tt-gds-action

GitHub action for hardening your Tiny Tapeout design into a manufacturable GDS file.

## Usage

Use the [tt10-verilog-template](https://github.com/TinyTapeout/tt10-verilog-template) as a starting point for your submission.

## Updating the action

To update the release tag of the action, run the following command (replace `tt10` with the current tiny tapeout version):

```bash
git push
git tag -fa tt10 -m "Update action to tt10"
git push origin tt10 --force
```

## License

Copyright 2023, 2024 Tiny Tapeout LTD

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
