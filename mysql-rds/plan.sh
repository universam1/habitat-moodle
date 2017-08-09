pkg_name=mysql-rds
pkg_origin=my
pkg_version=0.2.0
pkg_shasum=undefined
pkg_source=nosuchfile.tar.xz
pkg_upstream_url="https://github.com/universam1/habitat-moodle"
pkg_maintainer="universam1"
pkg_description="MySQL binding against AWS RDS SQL service"
pkg_license=()

pkg_deps=(
  core/mysql-client
  core/coreutils
  core/bash
  core/wget
)
pkg_svc_user="root"
pkg_svc_group=$pkg_svc_user

pkg_exports=(
  [port]=port
  [password]=app_password
  [username]=app_username
  [ipaddress]=ipaddress
)

do_verify() {
  return 0
}

do_begin() {
  return 0
}

do_build() {
  return 0
}

do_download() {
  return 0
}

do_install() {
  return 0
}

do_prepare() {
  return 0
}

do_unpack() {
  return 0
}
