# Kamontat's Shell

A shell collection with highly customizable.

## Variables

1. `$DEBUG=<name:ns>` - Enable debug logs on specific namespace
  - To print only test namespace, use `DEBUG=kcs:test`
  - To print all namespace, use either `DEBUG=kcs` or `DEBUG=kcs:*`
  - To print multiple namespace, use `DEBUG=kcs:test,hello,world`
2. `$LOG_FORMAT="{dt}"` - Customize log output format, variables supported in format listed below:
  - **{dt}** - Current datetime
  - **{d}** - Current date
  - **{t}** - Current time
  - **{lvl}** - Logged level
  - **{msg}** - Formatted message
  - **{fmt}** - Templated message
  - **{args}** - All message arguments (separated by space)
