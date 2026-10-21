"""List the UI strings other catalogs translate but ko.tsv doesn't (new strings after an update).

    python ko-patch/missing-ko.py            # print them
    python ko-patch/missing-ko.py --tsv      # print as ko.tsv rows with an empty translation

Untranslated strings show in English in the app, so this is never urgent. Translate the rows and
append them to crates/ui-egui/src/i18n/ko.tsv: keep {placeholders}, a trailing "…" only when the
English has one, and leading/trailing spaces exactly as in the English.
"""
import glob
import os
import sys

I18N = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'crates', 'ui-egui', 'src', 'i18n')


def keys(path):
    out = []
    with open(path, encoding='utf-8') as f:
        for line in f:
            line = line.rstrip('\n')
            if not line or line.startswith('#'):
                continue
            parts = line.split('\t')
            if len(parts) >= 3:
                out.append((parts[0], parts[1]))
    return out


have = set(keys(os.path.join(I18N, 'ko.tsv')))
missing = []
for path in sorted(glob.glob(os.path.join(I18N, '*.tsv'))):
    if os.path.basename(path) == 'ko.tsv':
        continue
    for k in keys(path):
        if k not in have:
            have.add(k)
            missing.append(k)

for ctx, src in missing:
    print(f'{ctx}\t{src}\t' if '--tsv' in sys.argv else (f'[{ctx}] ' if ctx else '') + src)
print(f'{len(missing)} untranslated', file=sys.stderr)
