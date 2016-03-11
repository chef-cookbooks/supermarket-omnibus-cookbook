[![Build Status](https://travis-ci.org/chef-cookbooks/supermarket-omnibus-cookbook.svg?branch=master)](https://travis-ci.org/chef-cookbooks/supermarket-omnibus-cookbook)

# supermarket-omnibus-cookbook

This cookbook installs the [Chef Supermarket](https://github.com/opscode/supermarket) server using the [omnibus-supermarket](https://github.com/opscode/omnibus-supermarket) packages from PackageCloud.
This cookbook also renders supermarket.json file which is used for managing configuration of Supermarket.

# Usage

## Attributes

Set the following attributes in the [`.kitchen.local.yml`](https://github.com/irvingpop/supermarket-omnibus-cookbook/blob/master/.kitchen.local.yml.example) or via a wrapper cookbook.  The values will be obtained from your oc-id server.  For more information see: [Getting Started with oc-id and Supermarket](http://irvingpop.github.io/blog/2015/04/07/setting-up-your-private-supermarket-server/)

```ruby
default['supermarket_omnibus']['chef_server_url'] = 'https://chefserver.mycompany.com'
default['supermarket_omnibus']['chef_oauth2_app_id'] = '14dfcf186221781cff51eedd5ac1616'
default['supermarket_omnibus']['chef_oauth2_secret'] = 'a49402219627cfa6318d58b13e90aca'
default['supermarket_omnibus']['chef_oauth2_verify_ssl'] = false
```

# Install from the repository of nightly packages
```ruby
default['supermarket_omnibus']['package_repo'] = 'chef-current'
```

```ruby
# OR, specify a Supermarket package explicitly from a location of your choosing
default['supermarket_omnibus']['package_url'] = 'http://bit.ly/98K8eH'
```

# Enable easy upgrades of your Supermarket installation (disabled by default)
```ruby
# set the following in a wrapper cookbook
default['supermarket_omnibus']['upgrades_enabled'] = true # enables upgrade action
default['supermarket_omnibus']['reconfig_after_upgrades'] = true # run `supermarket-ctl reconfigure` after upgrades
default['supermarket_omnibus']['restart_after_upgrades'] = true # run `supermarket-ctl restart` after upgrades
default['supermarket_omnibus']['package_version'] = '2.3.3' # pin to a desired semantic version; upgrade will occurr if necessary
```

If you wish to specify additional settings, you can pass them via the `default['supermarket_omnibus']['config']` attribute.
Example: for custom SSL certificates define the following `config` attributes:

```ruby
default['supermarket_omnibus']['config']['ssl']['certificate'] = '/full/path/to/ssl.crt'
default['supermarket_omnibus']['config']['ssl']['certificate_key'] = '/full/path/to/ssl.key'
```
Above attributes, if defined in supermarket.rb directly, would look like this:
```ruby
supermarket['ssl']['certificate'] = '/full/path/to/ssl.crt'
supermarket['ssl']['certificate_key'] = '/full/path/to/ssl.key'
```

To enable a recent [collaborator groups](https://www.chef.io/blog/2015/12/18/collaborator-groups-on-supermarket/) [feature](https://www.youtube.com/watch?v=1t1T5CQ0j48) you'll need to add the following attribute into your cookbook wrapper:
```ruby
default['supermarket_omnibus']['config']['features'] = 'tools, gravatar, collaborator_groups'
```

:warning: It’s super important to be aware that __supermarket.json always wins__. Best practice is to modify your supermarket configuration via `['config']` setting in a wrapper cookbook.

To find out all supermarket `config` attributes you can override, see [omnibus-supermarket](https://github.com/chef/omnibus-supermarket/blob/master/cookbooks/omnibus-supermarket/attributes/default.rb). Translation of attributes from `supermarket-omnibus-cookbook` to attributes in `omnibus-supermarket` occurs in the `supermarket_server` resource provided by this cookbook which produces a JSON(`/etc/supermarket/supermarket.json`) that `omnibus-supermarket` reads. For example:

```ruby
# an attribute you define via this supermarket-omnibus-cookbook
default['supermarket_omnibus']['config']['nginx']['log_rotation']['num_to_keep'] = 10

# becomes the following in omnibus-supermarket
default['supermarket']['nginx']['log_rotation']['num_to_keep'] = 10
```

# License and Authors

- Author: Irving Popovetsky (<irving@chef.io>)

- Copyright (C) 2015, Chef Software, Inc. (<legal@chef.io>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
