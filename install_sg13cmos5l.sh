#!/usr/bin/env bash
# Install ihp-sg13cmos5l PDK into $PDK_ROOT
# Pinned to a revision compatible with LibreLane 3.0.0rc1 (magic 8.3.616)
set -euo pipefail

: "${PDK_ROOT:?PDK_ROOT must be set}"

git clone --branch dev https://github.com/IHP-GmbH/IHP-Open-PDK.git "$PDK_ROOT"
git clone https://github.com/IHP-GmbH/ihp-sg13cmos5l.git "$PDK_ROOT/ihp-sg13cmos5l"
cd "$PDK_ROOT/ihp-sg13cmos5l"
git checkout ae7613984daf3ac2b14897321399df497278068f

# Fix broken symlink: IHP_rcx_patterns.rules moved to openrcx/ subdir upstream
ln -sf openrcx/IHP_rcx_patterns.rules "$PDK_ROOT/ihp-sg13g2/libs.tech/librelane/IHP_rcx_patterns.rules"

python3 << 'PYEOF'
import pathlib

# Patch config.tcl: add magic and netgen setup
cfg = pathlib.Path("libs.tech/librelane/config.tcl")
text = cfg.read_text()
patch_lines = [
    '## magic setup',
    'set ::env(MAGICRC) "$::env(PDK_ROOT)/$::env(PDK)/libs.tech/magic/ihp-sg13cmos5l.magicrc"',
    'set ::env(MAGIC_TECH) "$::env(PDK_ROOT)/$::env(PDK)/libs.tech/magic/ihp-sg13cmos5l.tech"',
    '',
    '# netgen setup',
    'set ::env(NETGEN_SETUP) "$::env(PDK_ROOT)/$::env(PDK)/libs.tech/netgen/ihp-sg13cmos5l_setup.tcl"',
    '',
]
patch = "\n".join(patch_lines) + "\n"
text = text.replace("# GPIO Pads", patch + "# GPIO Pads")
cfg.write_text(text)

# Add SOURCES file (IHP-Open-PDK dev branch revision used as PDK_ROOT)
import subprocess
ihp_rev = subprocess.check_output(
    ["git", "-C", str(pathlib.Path("../")), "rev-parse", "HEAD"],
    text=True
).strip()
pathlib.Path("SOURCES").write_text(f"IHP-Open-PDK {ihp_rev}\n")

# Fix DRC: KLayout preprocessor processes %include even after # comment.
# Remove rule_decks includes that reference undefined vars (svaricap etc).
# Keep layers_def.drc include as it defines essential layer variables.
drc = pathlib.Path("libs.tech/klayout/tech/drc/ihp-sg13cmos5l.drc")
drc_text = drc.read_text()
drc_text = "\n".join(
    line for line in drc_text.splitlines()
    if not ("%include rule_decks/" in line and "layers_def" not in line)
) + "\n"
drc.write_text(drc_text)
PYEOF
