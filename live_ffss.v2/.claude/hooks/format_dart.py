"""Formate le fichier Dart que Claude vient d'écrire ou de modifier.

Appelé par le hook PostToolUse de .claude/settings.json, avec l'appel de
l'outil en JSON sur l'entrée standard. Seul le fichier touché est formaté :
`dart format lib test` reformaterait plus de 300 fichiers à chaque
modification. Le code généré est laissé à build_runner et gen-l10n. Ne bloque
jamais : un échec de formatage n'empêche pas le travail de continuer.
"""

import json
import re
import shutil
import subprocess
import sys

_GENERATED = re.compile(r"(\.g\.dart|\.freezed\.dart|/l10n/gen/[^/]+\.dart)$")


def main() -> None:
    try:
        call = json.load(sys.stdin)
    except ValueError:
        return
    path = (call.get("tool_input") or {}).get("file_path") or ""
    normalized = path.replace("\\", "/")
    if not normalized.endswith(".dart") or _GENERATED.search(normalized):
        return
    # Sous Windows, `dart` est un script .bat : il faut son chemin complet.
    dart = shutil.which("dart")
    if dart is None:
        return
    subprocess.run([dart, "format", path], capture_output=True, timeout=60)


if __name__ == "__main__":
    try:
        main()
    except Exception:  # noqa: BLE001 - le hook ne doit jamais bloquer
        pass
