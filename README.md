# tt-gds-action

GitHub action for hardening your Tiny Tapeout design into a manufacturable GDS file.

## Usage

Use the [tt05-submission-template](https://github.com/TinyTapeout/tt05-submission-template) as a starting point for your submission.

## Updating the action

To update the release tag of the action, run the following command (replace `tt05` with the current tiny tapeout version):

```bash
git tag -fa tt05 -m "Update action to tt05"
git push origin tt05 --force
```

## License

Copyright 2023 Uri Shaked

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
