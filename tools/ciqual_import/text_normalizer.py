"""Accent-folding / case-folding used to build the `search_name` column.

Mirrored exactly in Dart at lib/core/text/text_normalizer.dart so that a
query typed on-device normalizes to the same string that was indexed here.
"""

_ACCENT_MAP = {
    "à": "a", "â": "a", "ä": "a", "á": "a", "ã": "a", "å": "a",
    "ç": "c",
    "è": "e", "é": "e", "ê": "e", "ë": "e",
    "ì": "i", "î": "i", "ï": "i", "í": "i",
    "ñ": "n",
    "ò": "o", "ô": "o", "ö": "o", "ó": "o", "õ": "o",
    "ù": "u", "û": "u", "ü": "u", "ú": "u",
    "ý": "y", "ÿ": "y",
    "œ": "oe", "æ": "ae",
}


def normalize(text: str) -> str:
    """Lowercase + strip accents so search is case- and accent-insensitive."""
    lowered = text.lower()
    return "".join(_ACCENT_MAP.get(ch, ch) for ch in lowered)
