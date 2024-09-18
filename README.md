# redmine_amzn_alb_authn

Redmine plugin to use [Amazon ALB for user authentication](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html).

This plugin verifies the JWT from the `X-Amzn-Oidc-Data` header with every request and makes users logged-in based on the `email` claim.
Note that this plugin does not create users, so users must be pre-created.

## Redmine version support

`>= 5.0.5`

## Installation

Clone this repository to the Redmine plugins directory.

    $ cd path/to/redmine
    $ git clone -b v0.2.1 https://github.com/arkedge/redmine_amzn_alb_authn ./plugins/redmine_amzn_alb_authn

Run `bundle install` to install the depended gems listed in [`PluginGemfile`](PluginGemfile).

    $ bundle install

And execute the database migration.

    $ bin/rails redmine:plugins:migrate

## Configuration

The plugin can be configured using the following environment variables:

- `REDMINE_AMZN_ALB_AUTHN_KEY_ENDPOINT`
  - **(required)** Public key endpoint, e.g., `https://public-keys.auth.elb.ap-northeast-1.amazonaws.com` when the ALB is in the `ap-northeast-1` region.
- `REDMINE_AMZN_ALB_AUTHN_ALB_ARN`
  - **(required)** The ARN of the Application Load Balancer expected by the `signer` field in the JWT header.
- `REDMINE_AMZN_ALB_AUTHN_ISS`
  - If set, the plugin will verify that the `iss` claim has the same value.

## Development

### Setup

Since [Redmine loads plugin's `Gemfile`](https://github.com/redmine/redmine/blob/deb792981b75040001258ecc780dd0b277e7362e/Gemfile#L116-L119),
the required gems for plugin development are listed in `Gemfile.local`.

    $ bundle config --local gemfile Gemfile.local
    $ bundle install

### Run the tests

    $ bundle exec rake

## License

[MIT License](LICENSE)
