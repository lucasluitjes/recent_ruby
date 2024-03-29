# Recent Ruby

This script takes a Ruby version number, compares it to all available Ruby versions, and throws an error unless the supplied version number contains the latest security patches. Put it in your build pipeline and you'll never deploy an app to an unpatched Ruby again.

## Why

Heroku (and other platforms) use the Gemfile to determine which version of Ruby to use. This means, whenever a Ruby vulnerability is found, you need to update your Gemfile in order to be safe. More importantly it means you need to pay close attention to the Ruby security notices. On smaller teams, this is often overlooked.

For gems, you can use Brakeman or Hakiri to stay up-to-date with security patches. For your Ruby version, use recent_ruby.

## Installation

Recent Ruby's installation is pretty standard:

```
$ gem install recent_ruby
```

Or just put it in your Gemfile:

```
gem 'recent_ruby', require: false
```

## Usage

Just add Recent Ruby in your CI/CD build process, wherever you would put Rubocop or Brakeman. Recent Ruby can check either your Gemfile (`recent_ruby --gemfile Gemfile`), or whatever is supplied as a command line argument (`recent_ruby --version-string 2.3.5`), and checks if that version of Ruby is the most recent TEENY/PATCH release for that minor version.

It also makes sure that your minor version is not End-of-Life yet. If your version of Ruby does happen to be out of date and potentially insecure, it exits with status code 1. This means you can simply drop it into your .circle.yml or your Semaphore build step, or wherever you usually put these things. 

## Examples

Outdated version number supplied on command line (2.3.7 was the latest 2.3 release at the time of this writing):

```
$ recent_ruby --version-string 2.3.1
Downloading latest list of Rubies from Github...
Comparing version numbers...
Current version is 2.3.1, but the latest patch release for 2.3 is 2.3.7!
```

Latest release for 2.3:
```
$ recent_ruby --version-string 2.3.7
Downloading latest list of Rubies from Github...
Comparing version numbers...
Downloading details for 2.3.7...
Checking EOL status...
Ruby version check completed successfully.
```

Latest release for 2.0, which is End-of-Life (no longer getting security patches):
```
$ recent_ruby --version-string 2.0.0-p648
Downloading latest list of Rubies from Github...
Comparing version numbers...
Downloading details for 2.0.0-p648...
Checking EOL status...
EOL warning found for 2.0.0-p648!
``` 

Version number specified in Gemfile:

```
$ cat path/to/Gemfile
source "https://rubygems.org"

ruby "2.3.3"

gem "rbnacl-libsodium"

$ recent_ruby --gemfile path/to/Gemfile
Downloading latest list of Rubies from Github...
Comparing version numbers...
Current version is 2.3.3, but the latest patch release for 2.3 is 2.3.7!
```

Build steps I use in the project settings on SemaphoreCI:

```
# Setup:
gem install recent_ruby --no-rdoc --no-ri

# Build:
recent_ruby --gemfile Gemfile
```

## How

If `--gemfile` was supplied, we use the parser gem to extract the Ruby version and patchlevel from the Gemfile.

First, we check that we’re being supplied an MRI stable release. If not, we immediately stop and error with exit code 1. Next, we grab the list of releases from the ruby-build repository and do some comparison to make sure we’re on the latest TEENY/PATCH release. Then we download the build specification from the ruby-build repository, and make sure an End-of-Life warning is not present.

Since the ruby-build repository is well maintained and used in production by many, it’s a reliable source for this purpose.

## Contributing

Feel free to create issues for any problems you may have. Patches are welcome, especially if they come with a Cucumber scenario.

### New release

* Bump version in `lib/recent_ruby/version.rb`, in this example to 0.1.5
* `git commit lib/recent_ruby/version.rb -m "v0.1.5"`
* `git tag -a v0.1.5 -m "Version 0.1.5"`
* `gem build recent_ruby`
* `gem push recent_ruby-0.1.5.gem`

## Contributors

- Lucas Luitjes
- Cedric Hartskeerl

## License

This project is MIT licensed.
