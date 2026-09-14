#!/usr/bin/env bash
# Install the ihp-sg13cmos5l PDK into $PDK_ROOT
#
set -euo pipefail

: "${PDK_ROOT:?PDK_ROOT must be set}"

IHP_PDK_REPO="https://github.com/IHP-GmbH/IHP-Open-PDK.git"
# IHP-Open-PDK dev branch, 2026-09-08 ("Merge pull request #1219 from IHP-GmbH/feat/chipText")
IHP_PDK_REV="2bbec755dc67ca3db0261c3d6163e15735d66710"

mkdir -p "$PDK_ROOT"
git -C "$PDK_ROOT" init -q
git -C "$PDK_ROOT" fetch -q --depth 1 "$IHP_PDK_REPO" "$IHP_PDK_REV"
git -C "$PDK_ROOT" checkout -q FETCH_HEAD

# Record the PDK source revision, like ciel-installed PDKs do
echo "IHP-Open-PDK $IHP_PDK_REV" > "$PDK_ROOT/ihp-sg13cmos5l/SOURCES"
