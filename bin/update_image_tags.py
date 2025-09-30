#!/usr/bin/env python3
"""
Update Docker image tags from :latest to a provided version across selected files.

Targets:
- docker-compose.yml and compose fragments under deploy/compose/*.yaml
- kustomization.yaml or kustomize.yaml at repo root (updates images[].newTag)
- Any README.md files (only project image references: jeboehm/* or ghcr.io/jeboehm/*)

Usage:
  bin/update_image_tags.py <new_tag> [--dry-run] [--verbose]

Notes:
- Skips commented lines in YAML when updating image: ...:latest
- Preserves existing indentation/spacing by using regex replacements
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Iterable, List, Tuple


REPO_ROOT = Path(__file__).resolve().parents[1]


def find_target_files(repo_root: Path) -> List[Path]:
    targets: List[Path] = []

    # docker-compose root file
    compose_root = repo_root / "docker-compose.yml"
    if compose_root.exists():
        targets.append(compose_root)

    # compose fragments
    targets.extend(sorted((repo_root / "deploy" / "compose").glob("*.yaml")))

    # root kustomize files
    for name in ("kustomization.yaml", "kustomize.yaml"):
        p = repo_root / name
        if p.exists():
            targets.append(p)

    # README.md files anywhere
    targets.extend(sorted(repo_root.glob("**/README.md")))

    # De-duplicate while preserving order
    seen: set[Path] = set()
    unique_targets: List[Path] = []
    for t in targets:
        if t not in seen and t.is_file():
            seen.add(t)
            unique_targets.append(t)
    return unique_targets


def replace_in_compose_yaml(content: str, new_tag: str) -> Tuple[str, int]:
    """Replace image: <name>:latest with image: <name>:<new_tag>, ignoring commented lines.

    Matches lines not starting with optional whitespace followed by '#'.
    Preserves whitespace around keys and colon.
    """
    pattern = re.compile(
        r"^(?!\s*#)(?P<prefix>\s*image\s*:\s*)(?P<name>[^:\s#]+):latest(?!\S)",
        re.MULTILINE,
    )

    def _sub(m: re.Match[str]) -> str:
        return f"{m.group('prefix')}{m.group('name')}:{new_tag}"

    new_content, count = pattern.subn(_sub, content)
    return new_content, count


def replace_in_kustomization(content: str, new_tag: str) -> Tuple[str, int]:
    """Replace newTag: latest with newTag: <new_tag> only when it's part of images list.

    We avoid YAML parsing to preserve formatting; instead we:
    - Detect we're inside an 'images:' block by simple state machine
    - Within that, replace 'newTag: latest' occurrences
    """
    lines = content.splitlines(keepends=False)
    in_images_block = False
    images_indent: int | None = None
    replacements = 0
    for idx, line in enumerate(lines):
        # Track entering images block
        if re.match(r"^\s*images\s*:\s*$", line):
            in_images_block = True
            images_indent = len(line) - len(line.lstrip(" \t"))
            continue

        if in_images_block:
            current_indent = len(line) - len(line.lstrip(" \t"))
            if images_indent is not None and current_indent <= images_indent and line.strip():
                # Left the images block
                in_images_block = False
                images_indent = None
            else:
                # Replace within images block only
                m = re.match(r"^(?P<prefix>\s*newTag\s*:\s*)latest(\s*(#.*)?)?$", line)
                if m:
                    lines[idx] = f"{m.group('prefix')}{new_tag}"
                    replacements += 1

    return ("\n".join(lines) + ("\n" if content.endswith("\n") else ""), replacements)


def replace_in_readme(content: str, new_tag: str) -> Tuple[str, int]:
    """Carefully replace :latest tags in README files for project images only.

    We target:
      - jeboehm/<name>:latest
      - ghcr.io/jeboehm/<name>:latest
    """
    pattern = re.compile(
        r"(?P<name>\b(?:ghcr\.io/)?jeboehm/[\w\-\.]+):latest\b"
    )
    new_content, count = pattern.subn(lambda m: f"{m.group('name')}:{new_tag}", content)
    return new_content, count


def process_file(path: Path, new_tag: str) -> Tuple[int, int]:
    content = path.read_text(encoding="utf-8")
    total_replacements = 0

    if path.name in {"docker-compose.yml"} or path.match("**/deploy/compose/*.yaml"):
        new_content, c = replace_in_compose_yaml(content, new_tag)
        total_replacements += c
        content = new_content

    if path.name in {"kustomization.yaml", "kustomize.yaml"} and path.parent == REPO_ROOT:
        new_content, c = replace_in_kustomization(content, new_tag)
        total_replacements += c
        content = new_content

    if path.name == "README.md":
        new_content, c = replace_in_readme(content, new_tag)
        total_replacements += c
        content = new_content

    if total_replacements > 0:
        path.write_text(content, encoding="utf-8")

    return total_replacements, len(content)


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Update :latest image tags to a specific version")
    parser.add_argument("new_tag", help="New tag to set (e.g., v1.2.3)")
    parser.add_argument("--dry-run", action="store_true", help="Show what would change without writing files")
    parser.add_argument("--verbose", action="store_true", help="Print per-file details")
    args = parser.parse_args(argv)

    new_tag = args.new_tag
    targets = find_target_files(REPO_ROOT)

    total_changes = 0
    changed_files: List[Tuple[Path, int]] = []

    for path in targets:
        original = path.read_text(encoding="utf-8")
        replacements = 0
        new_content = original

        if path.name in {"docker-compose.yml"} or path.match("**/deploy/compose/*.yaml"):
            new_content, c = replace_in_compose_yaml(new_content, new_tag)
            replacements += c

        if path.name in {"kustomization.yaml", "kustomize.yaml"} and path.parent == REPO_ROOT:
            new_content, c = replace_in_kustomization(new_content, new_tag)
            replacements += c

        if path.name == "README.md":
            new_content, c = replace_in_readme(new_content, new_tag)
            replacements += c

        if replacements > 0:
            total_changes += replacements
            changed_files.append((path, replacements))
            if not args.dry_run:
                path.write_text(new_content, encoding="utf-8")

        if args.verbose:
            print(f"{path}: {replacements} replacements")

    if args.verbose or args.dry_run:
        print(f"Total replacements: {total_changes} across {len(changed_files)} files")
        for path, cnt in changed_files:
            print(f" - {path} -> {cnt}")

    # Exit code 0 even if no changes; this is useful in idempotent runs
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

