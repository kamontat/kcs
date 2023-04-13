# Script commands

Commands are well defined and able to run either 
using `main.sh` or `bash <cmd>.sh` itself.
This directory should contains all commands
defined in scripts. With 2 special commands:
`__example.sh` is a starter template file for create new command,
and `_default.sh` is a default command if no matches command
when run with `main.sh`.

## Hook functions

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
## arguments : raw user arguments
__kcs_main "$@"
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
## arguments : raw user arguments
__kcs_main_option_keys "$@"
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
    return 10
    ;;
  esac
}

## caller    : internal/options.sh
## arguments : flag name and value
__kcs_main_option "name" "kcs"
```

</details>

## Useful functions

The useful built-in functions.

### Temporary functions

| Function name      | Description               | Syntax           |
| ------------------ | ------------------------- | ---------------- |
| **kcs_clean_temp** | Clean temporary directory | `kcs_clean_temp` |
