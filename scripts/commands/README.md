# Script commands

Commands are well defined and able to run either 
using `main.sh` or `bash <cmd>.sh` itself.
This directory should contains all commands
defined in scripts. With 2 special commands:
`__example.sh` is a starter template file for create new command,
and `_default.sh` is a default command if no matches command
when run with `main.sh`.

- [Callback functions](#callback-functions)
  - [Main function](#main-function)
  - [Information function](#information-function)
  - [Option function](#option-function)
  - [Hooks function](#hooks-function)
  - [Utilities function](#utilities-function)
  - [Configurations function](#configurations-function)
  - [Validates function](#validates-function)
  - [Clean function](#clean-function)
- [Useful functions and variables](#useful-functions-and-variables)
  - [Generic variables](#generic-variables)
  - [Generic functions](#generic-functions)
  - [Temporary functions](#temporary-functions)
  - [Information functions](#information-functions)
  - [Hook functions](#hook-functions)

## Callback functions

The command file are using hooks design pattern.
Normally, you only need to create function with correct name
on **User defined function** section in command file
then you will automatically register your action to global hooks.

There are several functions you can define listed below.

### Main function

<details><summary>The main entry of command</summary>

```sh
## desc      : The main entry of command;
##             all business logic should be here,
##             or called from here.
## return    : <none>
## tags      : @required, @hook:main
__kcs_main() {
  return 0
}

## caller    : hooks
## arguments : <none>
__kcs_main
```

</details>

### Information function

<details><summary>Script name</summary>

```sh
## desc      : printf script name
## return    : single line name
## tags      : @optional, @hook:pre_init
__kcs_main_name() {
  printf "default"
}

## desc      : static script name
## tags      : @optional
export KCS_NAME="default"

## caller    : hooks
## arguments : <none>
__kcs_main_name
```

</details>

<details><summary>Script version</summary>

```sh
## desc      : printf script version
## return    : single line version
## tags      : @optional, @hook:pre_init
__kcs_main_version() {
  printf "v1.0.0"
}

## desc      : static script version
## tags      : @optional
export KCS_VERSION="v1.0.0"

## caller    : hooks
## arguments : <none>
__kcs_main_version
```

</details>

<details><summary>Script description</summary>

```sh
## desc      : printf script description
## return    : single line description
## tags      : @optional, @hook:pre_init
__kcs_main_description() {
  printf "default command"
}

## desc      : static script description
## tags      : @optional
export KCS_DESCRIPTION="default command"

## caller    : hooks
## arguments : <none>
__kcs_main_description
```

</details>

<details><summary>Script help</summary>

```sh
## desc      : printf script help
## return    : multiple line help message
##             must prefix,suffix with newline
## tags      : @optional, @hook:pre_init
__kcs_main_help() {
  printf "
Options:
  [--test,-t]
    - [required] run test
"
}

## desc      : static script help
## tags      : @optional
export KCS_HELP="
Options:
  [--test,-t]
    - [required] run test
"

## caller    : hooks
## arguments : <none>
__kcs_main_help
```

</details>

### Option function

<details><summary>Option keys</summary>

```sh
## desc      : The output of this function will pipe to
##             getopts command for parser later.
## return    : single line string with only [a-zA-Z:]
## tags      : @optional, @hook:pre_init
__kcs_main_option_keys() {
  printf "abc"
}

## caller    : hooks
## arguments : <none>
__kcs_main_option_keys
```

</details>

<details><summary>Option parser</summary>

```sh
## desc      : parsing option
## tags      : @optional
__kcs_main_option() {
  local flag="$1" value="$2"
  case "$flag" in
  N | name)
    kcs_require_argument "$flag"
    NAME="$value"
    ;;
  Y | yes)
    kcs_no_argument "$flag"
    YES=true
    ;;
  *)
    return 1
    ;;
  esac
}

## caller    : internal/options.sh
## arguments : flag name and value
__kcs_main_option "name" "kcs"
```

</details>

### Hooks function

<details><summary>Register new hooks</summary>

```sh
## desc      : you can register new hooks on this function
## tags      : @optional, @hook:post_init
__kcs_main_hook() {
  ## add new hook on check stage
  kcs_add_hook "check" "__kcs_main_check"
  ## disable main entry
  kcs_disable_hook "main:__kcs_main"
}

## caller    : hooks
## arguments : <none>
__kcs_main_hook
```

</details>

### Utilities function

<details><summary>Register new utilities</summary>

```sh
## desc      : register new utilities function
## tags      : @optional, @hook:init
__kcs_main_utils() {
  local utils=(
    ## Builtin utilities
    "builtin/validator"
    ## Custom utilities
    "example"
  )

  printf "%s" "${utils[*]}"
}

## caller    : hooks
## arguments : <none>
__kcs_main_utils
```

</details>

### Configurations function

<details><summary>Config command</summary>

```sh
## desc      : configure utilities setting
## tags      : @optional, @hook:pre_main
__kcs_main_config() {
  ## Create new ssh profile
  kcs_conf_ssh \
    "server1" "192.168.1.100" \
    "admin" "~/.ssh/id_rsa"

  # kcs_conf_*
}

## caller    : hooks
## arguments : <none>
__kcs_main_config
```

</details>

### Validates function

<details><summary>Check command</summary>

```sh
## desc      : validate configuration;
##           : requires 'builtin/validator' utils
## tags      : @optional, @hook:check
__kcs_main_validate() {
  kcs_verify_present \
    "$__USERNAME" "username"
  # kcs_verify_*
}
## desc      : all kcs_verify_* are 
##           : from builtin/validator utils
__kcs_main_utils() {
  printf "builtin/validator"
}

## caller    : hooks
## arguments : <none>
__kcs_main_validate
```

</details>

### Clean function

<details><summary>Clean command</summary>

```sh
## desc      : cleanup main variable and function
## tags      : @optional, @hook:clean
__kcs_main_clean() {
  unset __NAME __PASSWORD
}

## caller    : hooks
## arguments : <none>
__kcs_main_clean
```

</details>

## Useful functions and variables

The useful internal functions and variables.

### Generic variables

| Variables name  | Description                                    |
| --------------- | ---------------------------------------------- |
| `KCS_COMMANDS`  | Array of arguments after `--` options          |
| `KCS_HOOK_NAME` | Running hook name, exist only on hook callback |

### Generic functions

| Function name              | Description                            |
| -------------------------- | -------------------------------------- |
| `kcs_exec <cmd> <args...>` | Run **command** with dry-run supported |

### Temporary functions

| Function name    | Description               |
| ---------------- | ------------------------- |
| `kcs_clean_temp` | Clean temporary directory |

### Information functions

| Function name  | Description              |
| -------------- | ------------------------ |
| `kcs_get_help` | Print help message       |
| `kcs_get_info` | Print script information |

### Hook functions

| Function name           | Description                           |
| ----------------------- | ------------------------------------- |
| `kcs_add_hook <n> <cb>` | Add new **callback** on hook **name** |
