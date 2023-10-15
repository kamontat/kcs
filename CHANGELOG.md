# Changelog

## [1.1.0](https://github.com/kc-workspace/kcs/compare/v1.0.0...v1.1.0) (2023-10-15)


### ⚠ BREAKING CHANGES

* **lib:** migrate commands to use new APIs and change function kcs_commands_load to kcs_commands_find

### Features

* **lib:** add templates for parsing template directory using eval ([375a61e](https://github.com/kc-workspace/kcs/commit/375a61e94d486d8012798f3ec5d90374ad2d2b97))


### Improvements

* **lib:** add new kcs_env_get for getting environment from named ([d3b610a](https://github.com/kc-workspace/kcs/commit/d3b610a35097371ec3e18d9f7d12afcfb1f7d095))
* **lib:** migrate commands to use new APIs and change function kcs_commands_load to kcs_commands_find ([f4795f9](https://github.com/kc-workspace/kcs/commit/f4795f905d3959e844ceb7efcd08eb658516e935))
* **lib:** move environment loader from private loader to environment lib ([8242da7](https://github.com/kc-workspace/kcs/commit/8242da7d0247c135b16164aeb79b230fbe126ddb))
* **private:** migrate loader to using new APIs ([28ebae4](https://github.com/kc-workspace/kcs/commit/28ebae47a65e32cc182e1a0231ae0f02d26b04b2))
* **script:** auto resolve latest version on setup script ([99b08c4](https://github.com/kc-workspace/kcs/commit/99b08c4651e7d1651dd165dbe75715d4b3634d50))
* **script:** auto snap output if no snapshot found ([9f6db1a](https://github.com/kc-workspace/kcs/commit/9f6db1a6847030abfce193a24d096a67cdb7d70a))


### Bugfixes

* **lib:** add missing local variable defined on options ([84622bf](https://github.com/kc-workspace/kcs/commit/84622bff2d58eed56adbcbb2b7890ee6cd76ed5a))
* **script:** setup script didn't get latest version correctly ([116bcf7](https://github.com/kc-workspace/kcs/commit/116bcf7c8ee169f9840fcd3718807d8c43421b66))
* **test:** update test snapshots for logs namespace changed ([a7cf737](https://github.com/kc-workspace/kcs/commit/a7cf737cb0df69ad248c8da7a2650faa4cf2fb8a))
* **test:** update tests from last changes ([95002b7](https://github.com/kc-workspace/kcs/commit/95002b739452bf49ac6879808a8fc39e55172e0e))


### Miscellaneous

* release v1.1.0 ([6cc2160](https://github.com/kc-workspace/kcs/commit/6cc2160b1c5d1d46ae425ec5ae8a9916fa736797))
* **test:** add test of template library ([74991af](https://github.com/kc-workspace/kcs/commit/74991af3cb30a92a5b0c4f37837257e37ee47919))

## [1.0.0](https://github.com/kc-workspace/kcs/compare/v1.0.0-beta.6...v1.0.0) (2023-10-14)


### Features

* update test to use internal v1.1 ([231b1ba](https://github.com/kc-workspace/kcs/commit/231b1bac9a963417fe21c679dbac165065588694))


### Improvements

* **cmd:** update all default commands with new internal code v1.1 ([0296da5](https://github.com/kc-workspace/kcs/commit/0296da550dc8f1b5a887c06f247c3ba9c379c972))
* **script:** replace internal file if exist when setup same directory ([24455de](https://github.com/kc-workspace/kcs/commit/24455de2f302433cebcf7e24926b17c8432f621d))


### Bugfixes

* **private:** add missing clean up variable ([6ae41bb](https://github.com/kc-workspace/kcs/commit/6ae41bb573f6c1e4f6a94e88196d27ffcc9a6515))
* **script:** update setup script when run without local git ([ac6abdf](https://github.com/kc-workspace/kcs/commit/ac6abdf909365eefc09b63362aff1f9741aee371))


### Miscellaneous

* **doc:** add how to setup script automatically ([0723363](https://github.com/kc-workspace/kcs/commit/0723363f3a03105ebd667d456d22278182084dea))
* update version ([100b5e5](https://github.com/kc-workspace/kcs/commit/100b5e5824317dd3b6750c6b30665b96d784a55e))

## [1.0.0-beta.6](https://github.com/kc-workspace/kcs/compare/v1.0.0-beta.5...v1.0.0-beta.6) (2023-10-02)


### Features

* **script:** rewrite setup.sh script to support latest version ([0319efe](https://github.com/kc-workspace/kcs/commit/0319efeefb87e9847158aa06729ca132c9395df6))


### Improvements

* **command:** add new _example.sh command for showcase how to create command script ([b89cc09](https://github.com/kc-workspace/kcs/commit/b89cc093329783b3198288e4faaaf74c90d9fbaf))


### Bugfixes

* **command:** hello command should not print warning about duplicated options ([6396366](https://github.com/kc-workspace/kcs/commit/6396366e8a6d3b47a4b03513d193667d6a1abe05))
* **env:** LOGFMT cannot set using default env file ([810bb27](https://github.com/kc-workspace/kcs/commit/810bb27ac445a4f3c3ce63877e9ba82e9a4d82b2))
* **lib:** information didn't list command correctly from other command directory ([c5f7e20](https://github.com/kc-workspace/kcs/commit/c5f7e20572a68727e23cc7a3344c212e074a7f32))
* **lib:** options didn't clean up variable correctly ([d6f47f9](https://github.com/kc-workspace/kcs/commit/d6f47f9da999dbd84e5053f2fc5a2150074cda2f))


### Miscellaneous

* clean up unused test commands ([12e8648](https://github.com/kc-workspace/kcs/commit/12e86487dd0fb2c8b72c28c9b03f8fadab90c252))
* prepare for v1.0.0-beta.6 ([5cf7b5b](https://github.com/kc-workspace/kcs/commit/5cf7b5b0b6e7109a7fd25a9aa0d1e5125ce13a25))
* **test:** update test snapshots ([dba305b](https://github.com/kc-workspace/kcs/commit/dba305b73fbfcc70508bfd38ca8bc4724586c458))

## [1.0.0-beta.5](https://github.com/kc-workspace/kcs/compare/v1.0.0-beta.4...v1.0.0-beta.5) (2023-10-02)


### ⚠ BREAKING CHANGES

* **libs:** change hook name and sequence of hooks running
* **env:** move configs to envs instead and refer this as environment instead of config
* **core:** change KCS_CMD_ARGS to _KCS_CMD_ARGS as read-only type

### Features

* add colors and initiate information&options libs ([723caf6](https://github.com/kc-workspace/kcs/commit/723caf69c2d23a4e1026be473e44aa2e4123bd78))
* add kcs_tmp command as private library ([cd27b7a](https://github.com/kc-workspace/kcs/commit/cd27b7a2b759d0e2bb02a34d19423c3a099d2c22))
* add several features ([aee950c](https://github.com/kc-workspace/kcs/commit/aee950c15d5834d7744e8382e97f06901a9064e0))
* **core:** add new dev mode ([17a3940](https://github.com/kc-workspace/kcs/commit/17a39403ece73473942411c81ad68fe5f99c5b1f))
* **env:** move configs to envs instead and refer this as environment instead of config ([dac9e5c](https://github.com/kc-workspace/kcs/commit/dac9e5c5b7a90724be7f2868bd6d1a1a9beb4294))
* **libs:** add config as a libraries settings ([a5493bc](https://github.com/kc-workspace/kcs/commit/a5493bce6d37d9808b8733e11fe92735246f4eb3))
* **libs:** add new hook tag [@rawargs](https://github.com/rawargs) for add raw argument ([9a91fab](https://github.com/kc-workspace/kcs/commit/9a91fabed3cb7da52c5c3c3ccac48b80a050df53))
* **libs:** final design of option lib ([a05098c](https://github.com/kc-workspace/kcs/commit/a05098c8b9f3df0fd843c1bae155c2349aca89f1))
* **libs:** update loader to support lifecycle function after loaded ([1cd97df](https://github.com/kc-workspace/kcs/commit/1cd97df515141cc69510ab789985d3e67a3203c7))
* **private:** logging namespace are filter from left to right instead ([34b8600](https://github.com/kc-workspace/kcs/commit/34b860038132f023afd3424a79a2de4b3caa7a81))
* separate internal lib to private directory ([356ea98](https://github.com/kc-workspace/kcs/commit/356ea98da8364afcd4c1cae60b2eefccc9d699b6))


### Improvements

* **config:** support window, linux and mac with 4 indent on markdown ([1071093](https://github.com/kc-workspace/kcs/commit/10710935b1e549dd8682f40ab2719a62fe11ae9e))
* **core:** change KCS_CMD_ARGS to _KCS_CMD_ARGS as read-only type ([5cd4246](https://github.com/kc-workspace/kcs/commit/5cd4246b770105eceeb20e5c53b201daa0144a07))
* **core:** improve kcs_exit to support no log and success exit ([a4c9ccb](https://github.com/kc-workspace/kcs/commit/a4c9ccb283c116dbade330a46be002966765d118))
* enabled color by default ([42ab826](https://github.com/kc-workspace/kcs/commit/42ab8267d6821fc56f10c191c5d527eafb08e65b))
* **env:** support load default env and custom env separately ([e7d8e98](https://github.com/kc-workspace/kcs/commit/e7d8e98b69a5dd9773656d278ee84da67ccd147e))
* **libs:** add help function using cmd desc ([40e379f](https://github.com/kc-workspace/kcs/commit/40e379f1c3b0012bf0eb723d9518a73f05583350))
* **libs:** change hook name and sequence of hooks running ([6f770ff](https://github.com/kc-workspace/kcs/commit/6f770ff0a78e2aaf872a3b83c8cbdd6c0db86d1e))
* **libs:** commands resolver from args will ignore options arguments for resolving path ([d3d754b](https://github.com/kc-workspace/kcs/commit/d3d754bb5a9270b3bc1f8dd16d8bc69dcce5d640))
* **libs:** move environment to lib instead of private ([c63057f](https://github.com/kc-workspace/kcs/commit/c63057fff1a1c521adf9af9452ca12df7c02fefe))
* **libs:** remove argument requirement on option lib loader, add skip duplicate options, and add default --help, --version, and --full-version ([71087f0](https://github.com/kc-workspace/kcs/commit/71087f0bcdc0d77898c3bcc9b82b93649a6ea950))
* **libs:** support commands and options in help options ([49c7fb2](https://github.com/kc-workspace/kcs/commit/49c7fb277d87ba81db0754488c7156ea3b098b6a))
* **libs:** support error when user provide optional argument without argument ([10a8332](https://github.com/kc-workspace/kcs/commit/10a83321a869b2716b0b2ff22549e548c1335e1a))
* **libs:** support grateful exit when loader fail ([b390906](https://github.com/kc-workspace/kcs/commit/b390906867649fca8645306ba91732d6d75a2302))
* **libs:** support kcs version in full version info ([a4e5af1](https://github.com/kc-workspace/kcs/commit/a4e5af19d107ee1d53874e58d15f73e58ae1c525))
* **libs:** update kcs_argument callback syntax ([0092d31](https://github.com/kc-workspace/kcs/commit/0092d316683949a24cdf233db005bfc009559d61))
* **loader:** add warning message if loading loaded module ([4c15df9](https://github.com/kc-workspace/kcs/commit/4c15df963474e14a07c00f329e16b7da9f43a90a))
* **loader:** separate env loader to default and non-default; ignore empty line ([a321817](https://github.com/kc-workspace/kcs/commit/a3218171bcc56c93e8e74051f930ce631538c606))
* **logger:** enabled normalize mode only on test ([55fc543](https://github.com/kc-workspace/kcs/commit/55fc5433ea88d572532d2b100db5232b990f7a1a))
* **logger:** filtering namespace now use glob resolver ([764290b](https://github.com/kc-workspace/kcs/commit/764290bf9e3a0b52fd7a13aa7205866ce7935745))
* **logger:** improve logging message and typo ([4691836](https://github.com/kc-workspace/kcs/commit/4691836c0280135063712d135617877010950beb))
* **logging:** remove logging about create timestamp file ([d28da28](https://github.com/kc-workspace/kcs/commit/d28da282e44015f51184a488cc29f418f0db49b7))
* **private:** add new logs when initiate command ([aca1df4](https://github.com/kc-workspace/kcs/commit/aca1df4c5fd8dbb038f2877ad0698b23c68da4e6))
* **private:** disable pre_main and main if exit as marked ([d5cdc0f](https://github.com/kc-workspace/kcs/commit/d5cdc0f0bc9d2091cd6119f2f62be8544021d5dd))
* **scripts:** update setup with new design ([56de706](https://github.com/kc-workspace/kcs/commit/56de70603592e551175e23fe715563eee2928616))
* **test:** add test on optional argument without default value ([3c34d0c](https://github.com/kc-workspace/kcs/commit/3c34d0c51043577f9e43a9a30ac1570d1dabf10d))
* **tests:** add support wring command to file for debugging later ([040591f](https://github.com/kc-workspace/kcs/commit/040591f6007c00041e8fd60d52cb8dd5d12102a9))
* **test:** test will summary the result on the end instead ([ea2a1db](https://github.com/kc-workspace/kcs/commit/ea2a1db387cc1de9884f3317e648d6d60bd51911))


### Bugfixes

* **color:** color should not always enable ([c98370e](https://github.com/kc-workspace/kcs/commit/c98370e49f290f50bffa5ca162b0f4229e08f6ed))
* **lib:** info didn't parse command correctly ([1cfd41f](https://github.com/kc-workspace/kcs/commit/1cfd41fe16b5d3dbacd92c7a4bc817e258c3325d))
* **lib:** no arg option might resolve definition wrong and default might use desc instead ([189ec73](https://github.com/kc-workspace/kcs/commit/189ec7350ea818a11788af922098e1f241e2e7c9))
* **lib:** option accidently delete argument ([0b6e181](https://github.com/kc-workspace/kcs/commit/0b6e181e6970719f7931a13b9c3d3c11c304eadc))
* **lib:** option parser didn't configure regex correctly ([b19438f](https://github.com/kc-workspace/kcs/commit/b19438f54eb4bc60f23ec03143eb6b1586397b1c))
* **libs:** create default option value before parsing input to ensure variable always exist ([6ca148f](https://github.com/kc-workspace/kcs/commit/6ca148f8c73b778b2ca3761db3811cfef04a75fc))
* **libs:** environment will use env default loader instead ([7aa3c24](https://github.com/kc-workspace/kcs/commit/7aa3c24b612345e8bd1806aed665da1afe2e7667))
* **libs:** improve logging and fix config not found errors on lib:configs ([c84bed2](https://github.com/kc-workspace/kcs/commit/c84bed25dc2134fe1d4ebffcd6d99b6da3b0ac4f))
* **libs:** options description is missing ([a43f11c](https://github.com/kc-workspace/kcs/commit/a43f11c18ed439c7d74958b2a2a5cf8c764dea35))
* **logger:** now logging can contains '=' (equal sign) ([3b5dfde](https://github.com/kc-workspace/kcs/commit/3b5dfdebf3b42151f57743571216573737927816))
* **logger:** warn and error log should always log to console even KCS_LOGOUT exist ([7a34d47](https://github.com/kc-workspace/kcs/commit/7a34d472f834c82ed001f3d7572a5273488d3ca1))
* **private:** command argument should not include command name ([947105f](https://github.com/kc-workspace/kcs/commit/947105fc47013c0c6ede52f24807dc7397fad0bb))
* **test:** update test snapshots ([f6a2e14](https://github.com/kc-workspace/kcs/commit/f6a2e14f79b682ec3b3478b6e5b65fd8fbc769ab))
* tmp logs should not happen on testing ([45c3bcf](https://github.com/kc-workspace/kcs/commit/45c3bcf7efbb6e376feb3f12aa95d06c42cc5bf4))
* **tmp:** all temp relate logs will be disabled on test ([9dba855](https://github.com/kc-workspace/kcs/commit/9dba855889356d1f6d3a20a17452990608822862))


### Miscellaneous

* **docs:** add how to simulate test on linux using docker ([fdeda13](https://github.com/kc-workspace/kcs/commit/fdeda13b723e612b689faad9df9f21c0fcd762aa))
* **docs:** initiate contributing guide ([0159486](https://github.com/kc-workspace/kcs/commit/01594867d859bacda2a5cfb700734c1226fc0b91))
* **docs:** update function syntax for private and auto resolver function ([f213588](https://github.com/kc-workspace/kcs/commit/f2135889e652cf217660a71bf59ff9cfcd11bd56))
* refactor loader to follow new design of function name ([93406ce](https://github.com/kc-workspace/kcs/commit/93406ce5f494ac0a390bcac00774a7fd9e5fddf3))
* release 1.0.0-beta.5 ([e19a980](https://github.com/kc-workspace/kcs/commit/e19a980240487b18d1a29b397dd758c7776e41b6))
* remove test scripts on main src ([97ac072](https://github.com/kc-workspace/kcs/commit/97ac072b3760bcde2359026f99ca6c6c8353b413))
* save progress ([6c3b801](https://github.com/kc-workspace/kcs/commit/6c3b80171ff0d5165c70383f8b23120e24534041))
* save progress of options parser ([e642e77](https://github.com/kc-workspace/kcs/commit/e642e77ba1ebeb45e65719902dfdc76a294cfe24))
* take tests snapshot ([ef03a51](https://github.com/kc-workspace/kcs/commit/ef03a518cf39190d6a1e86e4d8b676f13be8e485))
* **test:** add more tests for new command override setting ([c0c1573](https://github.com/kc-workspace/kcs/commit/c0c1573aa11d24057065214ede7ae45f35c30cb5))
* **test:** add new features tests and update test name ([de5ac59](https://github.com/kc-workspace/kcs/commit/de5ac597aa2ef1fb4cc743f291d2691162a52dc6))
* **test:** add test cmd key transformer ([9f44168](https://github.com/kc-workspace/kcs/commit/9f44168af31b46494df0611236f0e24e8438a5ea))
* **test:** remove custom log format and fix debug namespace ([3b3bde0](https://github.com/kc-workspace/kcs/commit/3b3bde0f2a33818aa85a28806aed5b8b1463213a))
* **test:** save latest snapshot ([de7f787](https://github.com/kc-workspace/kcs/commit/de7f787a47deeeb0fed6bf2429a0eb6f56e28e94))
* **test:** update snapshot ([7a74471](https://github.com/kc-workspace/kcs/commit/7a744715737228706b2424239cecad9534f69576))
* **test:** update snapshot all options ([d6d3e97](https://github.com/kc-workspace/kcs/commit/d6d3e977d53e759ff471f3ec752e79e0987d0fa7))
* **test:** update snapshot for new logs format ([46edf13](https://github.com/kc-workspace/kcs/commit/46edf13ec2ff963e1e927c191b3b4a4a3cbca5b2))
* update commands for new hook name ([071bd7f](https://github.com/kc-workspace/kcs/commit/071bd7f31ac22829be62e8e5f2eab43de65f9941))
* update other components to support new functions syntax and hook name ([d157f2b](https://github.com/kc-workspace/kcs/commit/d157f2b31c4b6bb3e15c133028c1196c7579f470))

## [1.0.0-beta.4](https://github.com/kc-workspace/kcs/compare/v1.0.0-beta.3...v1.0.0-beta.4) (2023-07-31)


### Features

* add command testing ([26024c1](https://github.com/kc-workspace/kcs/commit/26024c1527484b44a13072f2ecc76b419ab19ddc))
* add raw to __kcs_default_setup callback ([7a6625f](https://github.com/kc-workspace/kcs/commit/7a6625f6b4269a74dc14cb04bb17eb6dbb0a4f58))
* initiate new version for 0.2.x ([605d1bd](https://github.com/kc-workspace/kcs/commit/605d1bd0b1fddb639c24e8cae4f11327a126561d))
* **internal:** now utils will automatically load it's dependencies ([5ea223f](https://github.com/kc-workspace/kcs/commit/5ea223fdcfb446cc209bf22e010ea5a56b23eda9))
* **test:** reworks testing ([5b3bc96](https://github.com/kc-workspace/kcs/commit/5b3bc96c3a68562a84cff646b5a3b92a6d926459))
* **tests:** add test autodiscovery ([ad7383d](https://github.com/kc-workspace/kcs/commit/ad7383d5d24fde538490790c6c920189dae3650e))
* try setup script ([a7515b1](https://github.com/kc-workspace/kcs/commit/a7515b132e16b4a48956fd4a6c3869f95c99ae35))
* **utils:** add builtin/fs utils and tests ([e443b5a](https://github.com/kc-workspace/kcs/commit/e443b5a16c8d2cb856c57788fbdcee3abb489228))
* **utils:** change name kcs_lazy_copy to kcs_copy_lazy ([460a910](https://github.com/kc-workspace/kcs/commit/460a9103ebbb9576b9f067acb39d0d606e9d58c9))
* **utils:** copier will support cp and rsync and new config ([8dc3a8b](https://github.com/kc-workspace/kcs/commit/8dc3a8b2879a198bf435225f04d65d194f6ca092))


### Improvements

* **hook:** add default init and default setup same as main ([38276cb](https://github.com/kc-workspace/kcs/commit/38276cb1db1c65c492aa98faf7825c995b396624))
* **hook:** pass raw arguments to main_setup callback as well ([b7074e9](https://github.com/kc-workspace/kcs/commit/b7074e989a3d946e20a1c83ee7439ed755d62c71))
* **internal:** add debug log when register new errors code ([79eee30](https://github.com/kc-workspace/kcs/commit/79eee307eada8f285602add0a0b10509b94d8fd5))
* **internal:** kcs_exit will return input error code ([660fbe1](https://github.com/kc-workspace/kcs/commit/660fbe176c29d80b2579202f46ff505d038c6ad7))
* **internal:** loaded utils should not return error ([439a023](https://github.com/kc-workspace/kcs/commit/439a023065e3d10330c83044fa16c3af38e5b777))
* move main clean to pre_clean instead ([32f6795](https://github.com/kc-workspace/kcs/commit/32f6795991a8db544f2d636c9e523f5a32f74a01))
* set default log-level and fix error typo ([926eeb7](https://github.com/kc-workspace/kcs/commit/926eeb7b145205c88cdfd0c2405d2b891a03dbdd))
* **test:** refactor test and snapshots ([9e5b7a9](https://github.com/kc-workspace/kcs/commit/9e5b7a9ab7ce903a4c0358fec51853b1a5889041))
* **tests:** add more tests ([cd11fad](https://github.com/kc-workspace/kcs/commit/cd11fad656966633c31cd297e24c691f83b03b93))
* **tests:** support test minimal mode in CI ([ea49e11](https://github.com/kc-workspace/kcs/commit/ea49e111e43e41f92f3ee4b90e8c042aeec24161))
* **utils:** add more logs on ssh and fix missing DEBUG_ONLY on ssh command ([7956ed9](https://github.com/kc-workspace/kcs/commit/7956ed94f7b6bb1935951a034b02131dbf5a6a23))
* **utils:** add new apis on builtin/arguments ([968a2e2](https://github.com/kc-workspace/kcs/commit/968a2e293c51597f279438725aa06e9abb355991))
* **utils:** new builtin/arguments to modify/override user argument ([7f41718](https://github.com/kc-workspace/kcs/commit/7f4171881fdbaf1c56683bd9e51291e7f87a98da))
* **utils:** separate builting/debug to 2 hooks ([5800b9d](https://github.com/kc-workspace/kcs/commit/5800b9db442ee5163dc9087cf2194e424fc57bbf))
* **utils:** use redirect command in lazy-copy instead of write to file ([961e8cd](https://github.com/kc-workspace/kcs/commit/961e8cdfe910ffc3f737dc18e7c0ef3402178f97))


### Bugfixes

* **internal:** raw arguments doesn't pass to hook correct when override on same hook name ([f2719b2](https://github.com/kc-workspace/kcs/commit/f2719b20ad04c1f8a241890d04d4fba665f6f99a))
* **logger:** debug disabled and only not works correctly ([4bb747e](https://github.com/kc-workspace/kcs/commit/4bb747ef221064d62c58d3caec115290aa086eba))
* **tests:** remove root directory with constant name ([b6634e3](https://github.com/kc-workspace/kcs/commit/b6634e379d67ef890264b1261e2417f2285e08d9))
* **utils:** add copier configs and fix fs decode fail ([de0640e](https://github.com/kc-workspace/kcs/commit/de0640ed1584354639e1626f4064af72c7dcd1c5))
* **utils:** argument override not works when override with empty array ([0c88eb8](https://github.com/kc-workspace/kcs/commit/0c88eb8e26f3842da4726fb7c39cccff6f7b5d15))
* **utils:** copy to function in builtin/ssh will return correct error code ([c3585fe](https://github.com/kc-workspace/kcs/commit/c3585fe088c51280cbccbea37c79b271bbbf4cd5))
* **utils:** is_option in builtin/arguments not check correctly ([569a0ee](https://github.com/kc-workspace/kcs/commit/569a0eeaa7607444a6c8c60a51f545332cf6db0e))
* **utils:** rsync not handle directory correctly ([99ff8d5](https://github.com/kc-workspace/kcs/commit/99ff8d5f0c57557713d0b9348497ae6f8ee98da6))


### Miscellaneous

* add release-please action to release new version ([3cf3084](https://github.com/kc-workspace/kcs/commit/3cf3084a0833cab5509a63c39586e8583726a128))
* add testing on macos as well ([7800422](https://github.com/kc-workspace/kcs/commit/7800422fb9ac96f8e7bf556e5aab3341053600c9))
* change `config temp` namespace to `temp-configure` ([0780318](https://github.com/kc-workspace/kcs/commit/0780318769051dc88b77cc628b39fa31d2f0509a))
* **ci:** add github action ([a4218d0](https://github.com/kc-workspace/kcs/commit/a4218d04ce2e18f8079c9add9bc63279c5369caf))
* cleanup ([55f2143](https://github.com/kc-workspace/kcs/commit/55f2143d3ef5dd8b0668ee99c28f492e83afb533))
* **docs:** update internal comment ([4df1f29](https://github.com/kc-workspace/kcs/commit/4df1f2991f8ee6cf1dba9b57e0c189c385839e18))
* **internal:** add more debug logs ([c8d6b33](https://github.com/kc-workspace/kcs/commit/c8d6b33b488055515834718d6880ce9062a64ed0))
* move commands to scripts/commands ([e0716f8](https://github.com/kc-workspace/kcs/commit/e0716f85ebb3a67c44865033bc62f33c046b6636))
* move kcs internal command from example/commands to commands directory ([0013a1d](https://github.com/kc-workspace/kcs/commit/0013a1d84606af92490dcfcc3dad4d326da53c76))
* release v1.0.0-beta.4 ([624cd68](https://github.com/kc-workspace/kcs/commit/624cd680a0f6575dac9b29c6bcfba1ff4c8a7444))
* remove example function in copier utils ([73e956e](https://github.com/kc-workspace/kcs/commit/73e956e6d44bab6ecbc1ff3b4619fed0496bc929))
* **tests:** add function tests when call is-options in builtin/arguments utils ([83a6ce8](https://github.com/kc-workspace/kcs/commit/83a6ce8781d6cdeca8dbf3f23ab03a166c8d3050))
* **tests:** add test when main method is missing ([3a1450b](https://github.com/kc-workspace/kcs/commit/3a1450b93b19fb54cd3965bf5c0323f43a21e2c5))
* **tests:** add tests to check raw arguments when override ([e1fabf5](https://github.com/kc-workspace/kcs/commit/e1fabf5b0e7a845132cdf4579084632b3db66e80))
* update fail result for debugging ([27b43d8](https://github.com/kc-workspace/kcs/commit/27b43d840ae4fcb5d1b10a5f48a7926a10868b4f))
* **utils:** reduce duplicate logs in builtin/ssh utils ([e85e1a7](https://github.com/kc-workspace/kcs/commit/e85e1a7a0a19d6d7f312b924946d6fd7319e313b))

## Release notes
