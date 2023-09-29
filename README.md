# redmine_amzn_alb_authn

Redmine plugin to use [Amazon ALB for user authentication](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html).

## Redmine version support

`~> 5.0.5`

## Installation

Clone this repository to the Redmine plugins directory.

    $ cd path/to/redmine
    $ git clone https://github.com/arkedge/redmine_amzn_alb_authn ./plugins/redmine_amzn_alb_authn

Run `bundle install` to install [`PluginGemfile`](PluginGemfile) gems.

    $ bundle install

And execute DB migration.

    $ bin/rails redmine:plugins:migrate

## Development

### Setup

Since [Redmine loads plugin's `Gemfile`](https://github.com/redmine/redmine/blob/deb792981b75040001258ecc780dd0b277e7362e/Gemfile#L116-L119),
the required gems for plugin development are listed in `Gemfile.local`.

    $ bundle config --local gemfile Gemfile.local
    $ bundle install

### Run the tests

    $ bundle exec rake
