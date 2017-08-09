pkg_name=moodle
pkg_origin=my
pkg_version=3.3
pkg_filename="${pkg_name}-latest-${pkg_version/\./}.tgz"
pkg_dirname="moodle"
pkg_source="https://download.moodle.org/download.php/direct/stable${pkg_version/\./}/${pkg_filename}"
pkg_shasum=d567c6899eb8aa5b25091dd486c396a6032726dbe27a6319e2a809423a0008d7
pkg_upstream_url="https://github.com/universam1/habitat-moodle"
pkg_maintainer="universam1"
pkg_description="Run Moodle"
pkg_license=()

pkg_deps=(
  my/moodle-php5
  my/moodle-nginx-proxy
  core/findutils
  core/coreutils
  core/bash
  core/mysql-client
)
pkg_svc_run="php-fpm --fpm-config ${pkg_svc_config_path}/php-fpm.conf -c ${pkg_svc_config_path}"
pkg_svc_user="root"
pkg_svc_group=$pkg_svc_user

pkg_binds=(
  [database]="port username password"
)

# This optional bind is used in conjunction with my/moodle-aws-rds.
# my/moodle-aws-rds configures an AWS RDS for moodle and provides the
# RDS IP address to the my/moodle habitat service.
# When core/mysql or core/postresql fullfill the contract, the DB
# IP address can easily be obtained from: {{bind.database.first.sys.ip}}
# using "ipaddress" since "ip" is a system variable
pkg_binds_optional=(
  [database]="ipaddress"
)

do_build() {
  return 0
}

do_install() {
  # durig the init hook the tarball is extracted to /hab/svc/moodle/static
  cp -r . "${pkg_prefix}/moodle"
  return 0
}

do_verify() {
  return 0
}
