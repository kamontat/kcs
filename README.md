# Kamontat's Shell (aka Kcs)

This is a scripts collection for highly customizable shell scripts.

## Variable convension

1. `KCS_*` - Publicly, external variable
2. `_KCS_*` - Internal variable
3. `__KCS_*` - private variable

## Function convension

1. `kcs_*` - Publicly, external function
2. `_kcs_*` - Internal only function
3. `__kcs_*` - File scoped, private function

## Release flow

1. Create git tag `git tag v1.0.0 --message ""`
2. Generate changelog `git-chglog --output CHANGELOG.md`

OR

Using `./scripts/main.sh release` to release new version

## Example

You can try example command using below script:

```bash
./scripts/main.sh test
```

## Tests

- To run tests: `./tests/start.sh`
- To re-save snapshot: `TEST_MODE=snapshot ./tests/start.sh`

