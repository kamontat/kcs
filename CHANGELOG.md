# Changelog

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
