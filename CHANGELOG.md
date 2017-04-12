# supermarket-omnibus-cookbook Cookbook CHANGELOG

This file is used to list changes made in each version of the supermarket-omnibus-cookbook cookbook.

## 3.0.0 (2017-04-11)

- Require Chef 12.5+ (for custom resources) and remove compat_resource &
  fancy_execute dependencies

## 2.0.1 (2017-01-20)

- Upgrade chef-ingredient to use updated mixlib-install (PackageRouter support)

## 2.0.0 (2016-09-12)

- Convert the LWRP to a custom resource and use compat_resource for Chef 12.1+ compatibility
- Depend on the latest chef-ingredient cookbook
- Add a proper requirements section to the readme
- Fix licensing to correctly state Apache 2.0
- Add chef_version metadata
- Add contributing and testing docs
- Avoid node.set deprecation warnings
- Fix cookstyle warnings
- Add a Rakefile for testing
- Test entirely with ChefDK in Travis and use kitchen-dokken / cookstyle
- Cache chefspec to speed up specs and improve output / mocked OS releases
- Test on additional platforms in Travis
