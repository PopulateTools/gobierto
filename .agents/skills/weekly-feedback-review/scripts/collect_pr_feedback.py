#!/usr/bin/env python3
import json
import subprocess
import sys
from datetime import datetime, timedelta, timezone

REPO = subprocess.check_output(
    ["gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner"],
    text=True
).strip()

since = (datetime.now(timezone.utc) - timedelta(days=7)).strftime("%Y-%m-%dT%H:%M:%SZ")

# Get merged PR numbers
pr_list = json.loads(subprocess.check_output(
    ["gh", "pr", "list", "--repo", REPO, "--state", "merged", "--base", "master",
     "--limit", "100", "--json", "number,title,author,mergedAt"],
    text=True
))
prs = [p for p in pr_list if p["mergedAt"] >= since]

if not prs:
    print("NO_PRS")
    sys.exit(0)

results = {}
for pr in prs:
    n = pr["number"]
    entry = {"title": pr["title"], "author": pr["author"]["login"], "feedback": []}

    for endpoint, label in [
        (f"repos/{REPO}/pulls/{n}/reviews", "review"),
        (f"repos/{REPO}/pulls/{n}/comments", "inline"),
        (f"repos/{REPO}/issues/{n}/comments", "discussion"),
    ]:
        r = subprocess.run(["gh", "api", "--paginate", endpoint],
                           capture_output=True, text=True)
        if r.returncode != 0:
            continue
        items = json.loads(r.stdout)
        # flatten paginated arrays-of-arrays if needed
        if items and isinstance(items[0], list):
            items = [i for sub in items for i in sub]
        for item in items:
            if item["user"]["type"] == "Bot":
                continue
            body = item.get("body", "").strip()
            if not body:
                continue
            feedback_item = {
                "type": label,
                "user": item["user"]["login"],
                "body": body,
            }
            if label == "inline":
                feedback_item["path"] = item.get("path", "")
            entry["feedback"].append(feedback_item)

    if entry["feedback"]:
        results[n] = entry

print(json.dumps(results, indent=2, ensure_ascii=False))
