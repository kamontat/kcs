# Kamontat's Shell

A shell collection with highly customizable.

## Install

run `./scripts/setup.sh <output>` to install script on output

## Variables

1. `DEBUG=<name:ns>` - Enable debug logs on specific namespace
    - To print only test namespace, use `DEBUG=kcs:test`
    - To print all namespace, use either `DEBUG=kcs` or `DEBUG=kcs:*`
    - To print multiple namespace, use `DEBUG=kcs:test,hello,world`
2. `KCS_LOGLVL=<levels...>` - Customize only specific level to logs
    - **debug** - Enabled debug logs (same as `DEBUG=kcs`)
    - **info** - Enabled info logs
    - **warn** - Enabled warning logs
    - **error** - Enabled error logs
    - **silent** - Disable all logs
3. `KCS_LOGFMT="{dt}"` - Customize log output format, variables supported in format listed below:
    - **{dt}** - Current datetime
    - **{d}** - Current date
    - **{t}** - Current time
    - **{lvl}** - Logged level
    - **{msg}** - Formatted message
    - **{fmt}** - Templated message
    - **{args}** - All message arguments (separated by space)
4. `KCS_LOGOUT=/tmp/test.out` - Write logs to file instead
    - By default all logs will write on **STDERR**
5. `KCS_PATH=/tmp` - Custom resolving base directory
