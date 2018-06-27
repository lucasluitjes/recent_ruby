Feature: My bootstrapped app kinda works
  Background:
    Given I set the environment variables to:
      | variable          | value                          |
      | VERSION_BASE_URL  | http://localhost:8000/version/ |
      | VERSIONS_URL      | http://localhost:8000/versions |

    And the endpoint "/versions" returns "versions.json"
    And the endpoint "/version/1.8.7-p375" returns this content:
    """
    require_gcc
    install_svn "ruby-1.8.7-p375" "http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8_7" "44351" warn_eol autoconf auto_tcltk standard
    install_package "rubygems-1.6.2" "https://rubygems.org/rubygems/rubygems-1.6.2.tgz#cb5261818b931b5ea2cb54bc1d583c47823543fcf9682f0d6298849091c1cea7" ruby

    """

  Scenario: Up-to-date Ruby (At the time these fixtures were created)
    When I run `recent_ruby --version-string 2.3.7`
    Then the exit status should be 0
    And the stderr should not contain anything
    And the output should contain:
    """
    Downloading latest list of Rubies from Github...
    Comparing version numbers...
    Downloading details for 2.3.7...
    Checking EOL status...
    Ruby version check completed successfully.
    """

  Scenario: Outdated minor version
    When I run `recent_ruby --version-string 2.3.1`
    Then the exit status should be 1
    And the stderr should not contain anything
    And the output should contain:
    """
    Downloading latest list of Rubies from Github...
    Comparing version numbers...
    Current version is 2.3.1, but the latest patch release for 2.3 is 2.3.7!
    """

  Scenario: End of Life minor version
    When I run `recent_ruby --version-string 1.8.7-p375`
    And the stderr should not contain anything
    Then the exit status should be 1
    And the output should contain:
    """
    Downloading latest list of Rubies from Github...
    Comparing version numbers...
    Downloading details for 1.8.7-p375...
    Checking EOL status...
    EOL warning found for 1.8.7-p375!
    """

  Scenario: No arguments
    When I run `recent_ruby`
    Then the exit status should be 1
    And the stderr should not contain anything
    And the output should contain:
    """
    Please supply either a gemfile path or a version string. Run with -h for more information.
    """

  Scenario: Too many arguments
    When I run `recent_ruby --version-string 1.8.7-p375 --gemfile Gemfile`
    Then the exit status should be 1
    And the stderr should not contain anything
    And the output should contain:
    """
    Please supply only one argument. Run with -h for more information.
    """

  Scenario: Check version from gemfile
    Given a file named "Gemfile" with:
    """
    source "https://rubygems.org"

    ruby "2.3.3"

    gem "rbnacl-libsodium"
    """
    When I run `recent_ruby --gemfile Gemfile`
    And the stderr should not contain anything
    And the output should contain:
    """
    Downloading latest list of Rubies from Github...
    Comparing version numbers...
    Current version is 2.3.3, but the latest patch release for 2.3 is 2.3.7!
    """
    Then the exit status should be 1

  Scenario: Check version from gemfile
    Given a file named "Gemfile" with:
    """
    source "https://rubygems.org"

    ruby "1.8.7", :patchlevel => 375

    gem "rbnacl-libsodium"
    """
    When I run `recent_ruby --gemfile Gemfile`
    And the stderr should not contain anything
    And the output should contain:
    """
    Downloading latest list of Rubies from Github...
    Comparing version numbers...
    Downloading details for 1.8.7-p375...
    Checking EOL status...
    EOL warning found for 1.8.7-p375!
    """
    Then the exit status should be 1

  Scenario: Try to check missing version from gemfile
    Given a file named "Gemfile" with:
    """
    source "https://rubygems.org"

    gem "rbnacl-libsodium"
    """
    When I run `recent_ruby --gemfile Gemfile`
    Then the exit status should be 1
    And the stderr should not contain anything
    And the output should contain:
    """
    Unable to find ruby version in gemfile.
    """

  Scenario: Only MRI is supported
    When I run `recent_ruby --version-string jruby-1.5.6`
    Then the exit status should be 1
    And the stderr should not contain anything
    And the output should contain:
    """
    Only stable release MRI version strings are currently supported. (e.g. 2.3.1 or 2.3.1-p12)
    """

  Scenario: What if Github is rate limiting us?
    Given Github is rate limiting us
    When I run `recent_ruby --version-string 2.3.1`
    Then the exit status should be 2
    And the stderr should not contain anything
    And the output should contain:
    """
    Downloading latest list of Rubies from Github...
    Error: received HTTP 429 response from Github:

    Please try again in a few moments.
    """
