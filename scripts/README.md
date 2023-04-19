# Scripts directory

> Templated by https://github.com/kc-workspace/kcs

This contains main entry and all utilities to start main.sh file.
You have 2 options to execute commands: either via main.sh file or any files in commands directory.

## Upgrade steps

1. Replace `internal` and `utils/builtin` directory with new version
2. Replace `main.sh` if **template** version has been changed
3. Merge files from `commands` directory
4. Check all `commands` file for **command-example** version
5. If **command-example** version changes, take a look on APIs change from [CHANGELOG.md][../CHANGELOG.md]
