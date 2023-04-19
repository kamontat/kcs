
<a name="v1.0.0-beta.1"></a>
## v1.0.0-beta.1 - 2023-04-19

### Features
- initiate ssh utils to connect server using pre-configure config
- a new features and improve a lot of things
- start new project
- **hooks:** support tag when adding hooks
- **main:** change how KCS_MODE works and use KCS_ROOT to resolve root directory instead
- **mode:** support lib mode, then all hooks will not run
- **utils:** implement ssh copy and ssh cmd function
- **utils:** support namespace on utils so we can separate builtin from custom utils

### Performance Improvements
- **hook:** add new main_hooks for validate config
- **hook:** move __kcs_main_utils to init hook instead of post_init
- **hooks:** add KCS_HOOK_NAME and improve DRY_RUN mode
- **hooks:** remove unused hook
- **internal:** move all utils function to it's file
- **internal:** add _commands.sh to base internal as ssh use their apis
- **internal:** improve debug logging in core function
- **internal:** kcs_load_utils will load only if utils never load before
- **logger:** add new disable env to disable debug log by namespace
- **utils:** update ssh utils with more customizable
- **utils:** create new temp apis to create directory
- **utils:** add new temp apis
- **utils:** add more apis on checker and validator

### Bug Fixes
- wrong mode configure in main.sh
- **core:** cannot set script info via exported variable
- **core:** all commands should default to command mode not library mode
- **core:** avoid using $status because conflict with `source` command
- **internal:** utils file resolver cannot handle non-scope utils
- **lint:** help command not newline correctly
- **option:** long option cause infinite loop

### Chore
- update file document comment
- update commands comments and documents
- change validate hooks to check
- use variable syntax on _default script as it shorter
- shorten logging message and enabled info by default
- improve debug message and make code cleaner
- new error code when depends on utils not loaded
- update commands README
- ssh utils no longer requires temp
- add documents on kcs_add_hook function
- add utils documents and add prompt utils
- move utils add_hook to utils file itself
- add new errcode when user provide invalid args
- remove newline in README
- unified file comments and function document
- move _temp helper to utils instead
- **debug:** add more debug information on utils _debug.sh
- **docs:** add [@example](https://github.com/example) on shell docs
- **logger:** add info log when run cmd on ssh server


[Unreleased]: https://github.com/kc-workspace/kcs/compare/v1.0.0-beta.1...HEAD
