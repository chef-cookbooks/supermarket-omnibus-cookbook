# supermarket-omnibus-cookbook

This cookbook installs the [Chef Supermarket](https://github.com/opscode/supermarket) server using the [omnibus-supermarket](https://github.com/opscode/omnibus-supermarket) packages from PackageCloud.

# Usage

## Attributes

Set the following attributes in the [`.kitchen.local.yml`](https://github.com/irvingpop/supermarket-omnibus-cookbook/blob/master/.kitchen.local.yml.example) or via a wrapper cookbook.  The values will be obtained from your oc-id server.  For more information see: [Getting Started with oc-id and Supermarket](http://irvingpop.github.io/blog/2015/04/07/setting-up-your-private-supermarket-server/)

```ruby
default['supermarket_omnibus']['chef_server_url'] = 'https://chefserver.mycompany.com'
default['supermarket_omnibus']['chef_oauth2_verify_ssl'] = false
```
Create a chef vault called `supermarket` with an item called `secrets`.
This will contain the app_id and secret for the supermarket application, for
the oc_id auth.
```json
{
    "chef_oauth2_app_id": "<....app_id....>",
    "chef_oauth2_secret": "<....app_secret....>"
}
```

If you wish to specify a package version, a repository or a source, you can do that now:
```ruby
default['supermarket_omnibus']['package_version'] = '1.2.3'

# install from the repository of nightly packages
default['supermarket_omnibus']['package_repo'] = 'chef-current'

# OR, specify a Supermarket package explicitly from a location of your choosing
default['supermarket_omnibus']['package_url'] = 'http://bit.ly/98K8eH'
```

# License and Authors

- Author: Irving Popovetsky (<irving@getchef.com>)

- Copyright (C) 2014, Chef Software, Inc. (<legal@getchef.com>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

