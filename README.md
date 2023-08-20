# Kamontat's Shell

A shell collection with highly customizable.

## Install

run `./scripts/setup.sh <output>` to install script on output

## Variables

1. `KCS_DEV=true` - Enabled dev mode.
    - set `DEBUG=kcs` - enabled debug mode
    - set `KCS_TMPBFR=true` - enabled always clean tmp
    - force `KCS_TMPDIR` to **/tmp**
2. `DEBUG=<name:ns>` - Enable debug logs on specific namespace
    - To print only test namespace, use `DEBUG=kcs:test`
    - To print all namespace, use either `DEBUG=kcs` or `DEBUG=kcs:*`
    - To print multiple namespace, use `DEBUG=kcs:test,hello,world`
3. `KCS_LOGLVL=<levels...>` - Customize only specific level to logs
    - **debug** - Enabled debug logs (same as `DEBUG=kcs`)
    - **info** - Enabled info logs
    - **warn** - Enabled warning logs
    - **error** - Enabled error logs
    - **silent** - Disable all logs
4. `KCS_LOGFMT="{dt}"` - Customize log output format, variables supported in format listed below:
    - **{dt}** - Current datetime
    - **{d}** - Current date
    - **{t}** - Current time
    - **{lvl}** - Logged level
    - **{msg}** - Formatted message
    - **{fmt}** - Templated message
    - **{args}** - All message arguments (separated by space)
5. `KCS_LOGOUT=/tmp/test.out` - Write logs to file instead
    - By default all logs will write on **STDERR**
6. `KCS_PATH=/home/kcs` - Customize resolving base directory
7. `KCS_CMDSEP='/'` - Customize commands seperator in **commands** directory
    - By default it fallback to `/` if no string provided
8. `KCS_CMDDEF='_default'` - Customize default command name (if command is missing)
    - By default it will use `_default` if no string provided
9. `KCS_TMPDIR=/tmp/kcs` - Customize temporary directory
    - By default it will use `$TMPDIR/kcs` or fallback to **/tmp/kcs** directory
10. `KCS_TMPCLE=10000` - Auto cleaning temporary directory
    - The number is represent different between now and created date on `%Y%m%d%H%M` format, e.g.
    - **10000** = 1 day (default)
    - **100** = 1 hour
    - **1** = 1 minute
11. `KCS_TMPBFR=<str>` - Force clean temporary directory before start
