# AWS RDS Interface Wrapper

## Description

This package serves the purpose to provide the interface between an alien non-Habitat service to fullfill a Habitat supervisor Runtime Binding contract, commonly refered with the `--bind` parameter.

For more details see 
*https://www.habitat.sh/docs/run-packages-binding/*

The benefit is the ability to use Habitat common interface standards, thus being able to _replace_ the AWS RDS easily with a real _core/mysql Habitat service_.

This will be usefull especially to test setup in a `Vagrant` setup.

## Function

This wrapper aims to fullfill the `Producer Contract` for an MySQL service, thus exporting to the supervisor configuration:
```bash
pkg_exports=(
  [port]=port
  [password]=app_password
  [username]=app_username
  [ipaddress]=ipaddress
)
```

As the documentation says:

> "All pkg_exports must define a default value in default.toml but their values may change at runtime by an operator configuring the service group. If this happens, the consumer will be notified that their producer's configuration has changed."

We make use of this and change the values listed in `Default.toml` which we aquire from AWS.

## Flow

1. Provide the AWS configuration as a [Configuration update](https://www.habitat.sh/docs/run-packages-apply-config-updates/) in runtime **to this wrapper**(!), not the application that should be the consumer.
  1. pass the config into the EC2 node, see infra-repo moodle.rb
  1. convert to toml file
  1. apply this toml file: 
  `hab config apply mysql-rds.default $(date +%s) mysql_moodle.toml`
1. This will update the producers configuration, output to the binding and cause a supervisor reconfig.
1. On the consumer you can now make use with normal binding like `hab start my/moodle --bind database:mysql-rds.default`

## Issues

Currently, I cant find a way to overwrite the `sys` variables like `ip`, `hostname` which are commonly used to retrieve the producers address.

A workaroud is to create an `optional binding`,
```bash
pkg_binds_optional=(
  [database]="ipaddress"
)
```
test against and use it instead, like here:

```php
{{#if bind.database.first.cfg.ipaddress}}
  $CFG->dbhost    = '{{bind.database.first.cfg.ipaddress}}';
{{/if}}

{{#unless bind.database.first.cfg.ipaddress}}
  CFG->dbhost    =  '{{bind.database.first.sys.ip}}';
{{/unless}}

```

