# Contributors

Thank you for investing your time in contributing to our project!

## Conventions

Because how bash script works, we need to set some convention
to make our code clean and easy to read.

There are 2 parts for naming convention: **variables** and **functions**.

### Variables

- For publicly **read-write** variables (setting), should be `KCS_<name>` template
- For publicly **read-only** variables (data), should be `_KCS_<name>` template
- For internal **read-write** variables (internal), should be `__KCS_<name>` template
    - Subject to change without notice

For Testing all variables should be `KCT_<name>` template.

### Functions

- For public APIs, should be `kcs_<module>_<name>` template
    - This can be used on either place including commands
    - It has notice period before deprecate and remove
- For internal APIs, should be `_kcs_<module>_<name>` template
    - This should not been use in commands directory
    - This might use in utils directory if you like to access some internal APIs
    - It has notice period before deprecate and remove
- For private APIs, should be `__kcs_<module>_<name>` template
    - All hooks should defined using this template
    - It will move change or remove without notice
