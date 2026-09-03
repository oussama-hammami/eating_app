#!/usr/bin/env python3
"""Push supabase/seed/community_recipes.json into the community_recipies table
via the Supabase REST (PostgREST) API.

Usage:
    export SUPABASE_SERVICE_ROLE_KEY="..."   # service_role key, bypasses RLS
    python3 supabase/seed/push_community_recipes.py
"""
import json
import os
import sys
import urllib.request

SUPABASE_URL = "https://bipjodhqsldkyjoecrix.supabase.co"
TABLE = "community_recipies"
ENDPOINT = f"{SUPABASE_URL}/rest/v1/{TABLE}"

key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
if not key:
    sys.exit("Set SUPABASE_SERVICE_ROLE_KEY in your environment first.")

with open(os.path.join(os.path.dirname(__file__), "community_recipes.json")) as f:
    recipes = json.load(f)

body = json.dumps(recipes).encode("utf-8")

req = urllib.request.Request(
    ENDPOINT,
    data=body,
    method="POST",
    headers={
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
    },
)

try:
    with urllib.request.urlopen(req) as resp:
        print(f"Success: HTTP {resp.status}")
except urllib.error.HTTPError as e:
    print(f"Failed: HTTP {e.code}")
    print(e.read().decode())
    sys.exit(1)
