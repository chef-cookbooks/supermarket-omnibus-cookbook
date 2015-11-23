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

If you wish to specify a package version, a repository or a source, you can do that now:
```ruby
default['supermarket_omnibus']['package_version'] = '1.2.3'

# install from the repository of nightly packages
default['supermarket_omnibus']['package_repo'] = 'chef-current'

# OR, specify a Supermarket package explicitly from a location of your choosing
default['supermarket_omnibus']['package_url'] = 'http://bit.ly/98K8eH'
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
