
<a name="v1.0.0-beta.3"></a>
## [v1.0.0-beta.3] - 2023-05-05

### Features
- pump example version to v1
- **alias:** add alias variable option
- **core:** support alias command to shorten command
- **hook:** move main setup to load hook because post_load will be disable on lib mode
- **hooks:** rename main_init to main_setup and use main_init on pre_init hook
- **utils:** add kcs_exit $code to grateful exit scripts
- **utils:** on builtin/copier utils, will log info if successully copied
- **utils:** add auto_clean_all on temp to clean temp directory to initiate stage

### Performance Improvements
- **internal:** use grateful exit instead of force exit on all places
- **utils:** move builtin/command func to internal and remove builtin/command

### Bug Fixes
- **core:** lib mode should not run check anything

### Chore
- update default of example command
- example alias command for release
- cleanup some code
- **log:** add debug log when parsing options
- **log:** normalize log output on copier utils


<a name="v1.0.0-beta.2"></a>
## [v1.0.0-beta.2] - 2023-05-01

### Features
- remove unused hook callback
- add release command to create new kcs version
- **command:** new pre-defined command named "__exec" to exec function directly
- **core:** add new DRY_HOOK environment for debugging hook command
- **core:** update docs for help and help-all options
- **example:** new deployment command for deploy kcs to target
- **example:** add new example command as a example how to write command script
- **hook:** new load hooks for loading external apis or functions
- **hook:** add new hook tag [@args](https://github.com/args) for parse array variable as argument
- **hook:** adjust hook callback based on new load phase
- **internal:** support override commands utils temp and logs directory
- **internal:** remove `__kcs_register` as it unused
- **internal:** add new __kcs_default_option function for setup default option on utilities
- **logger:** add DEBUG_ONLY for enabled only namespaced debug
- **logger:** support write logs to file using LOG_FILE or --log-file (prefer env style)
- **utils:** add copier utils to copy file or directory
- **utils:** new register utils function for dependencies resolver
- **utils:** add csv utils
- **utils:** add checker and validator 2 more utilities
- **utils:** add new builtin/command for call command from other command

### Performance Improvements
- remove all check hooks and use post_init or post_load instead, change callback name as well. `__kcs_default_validate` changed to `__kcs_load_check` and `__kcs_main_validate` changed to `__kcs_main_check`
- minor improve on default command
- **command:** update example command to use short syntax
- **core:** separate help command to --help and --help-all
- **core:** reimplement lib mode but disable main and clean hook instead
- **example:** ssh must loaded on init-utils
- **hook:** remove check hook as check will perform on all post steps except main which run pre step
- **hook:** disable hook now support disable hook by name
- **hook:** new [@silent](https://github.com/silent) tag for ignore if cmd not exist or fail
- **hook:** kcs_add_hook will not re-add hook action with the same name
- **hook:** add new hook for cleanup main command variables/functions
- **hook:** add new __kcs_main_pre_utils function to load utilities on the beginning of hooks
- **hooks:** add __kcs_main_init for initiate command script after parsed options
- **internal:** built utils path only if it's pass creating condition
- **internal:** if utils load failed, throw error and stop
- **internal:** add new __kcs_default_validate same as __kcs_main_validate but for utils
- **internal:** _kcs_find_command now support sent raw argument after <> separator
- **main:** support load utils using variable instead of function
- **options:** option keys will be merged with KCS_OPTIONS variables
- **utils:** improve builtin/temp by kcs_temp_create_* function will automatically cleanup itself
- **utils:** add function to disable auto cleanup temp file/folder
- **utils:** new kcs_check_args utils for validate command argument

### Bug Fixes
- **core:** invalid function name on hook
- **error:** array variable cannot be exported
- **hook:** duplicated execution on hook callback
- **hook:** if hook command failed, it should throw error not only print warning
- **internal:** if utils not found, logs it
- **internal:** kcs_exec use invalid arguments
- **utils:** if ssh command copy failed, stop the script
- **utils:** ssh command cannot execute if KCS_NAME contains '/'
- **utils:** ssh proxy environment support debug_disable and fix some invalid variable name
- **utils:** fix ssh command not work as expected with new design
- **utils:** temp auto-clean didn't works as expected
- **utils:** kcs_verify_present signature not same with docs

### Chore
- add debug message when searching for required utils
- initiate release command to release new kcs version
- change example deploy command to upgrade
- add upgrade steps
- add list of utils loaded to debug utils as well
- prepare to release version 'v1.0.0-beta.2'
- **docs:** ssh no longer require builtin/temp utils
- **docs:** update deprecated function name
- **docs:** add kcs_dir on default help command
- **docs:** add naming appendix on command README
- **docs:** update utils docs
- **docs:** update command header document
- **docs:** update typo
- **docs:** add release flow on README
- **docs:** add changelog config and generate changelog
- **docs:** add example deploy cmd help
- **error:** refactor errcode with new EC namespace
- **log:** use debug on reuse config log instead of warn
- **utils:** add hostname and os to debug utils


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


[Unreleased]: https://github.com/kc-workspace/kcs/compare/v1.0.0-beta.3...HEAD
[v1.0.0-beta.3]: https://github.com/kc-workspace/kcs/compare/v1.0.0-beta.2...v1.0.0-beta.3
[v1.0.0-beta.2]: https://github.com/kc-workspace/kcs/compare/v1.0.0-beta.1...v1.0.0-beta.2
