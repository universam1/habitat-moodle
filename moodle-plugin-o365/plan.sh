pkg_name=moodle-plugin-o365
pkg_origin=my
pkg_version=20170511_m32
pkg_shasum=undefined
pkg_source="https://github.com/Microsoft/o365-moodle.git"
pkg_upstream_url="https://github.com/universam1/habitat-moodle"
pkg_dirname="moodle-plugin-o365"
pkg_maintainer="universam1"
pkg_description="Install Office 365 plugins for Moodle"
pkg_license=()
pkg_build_deps=(core/git)

pkg_deps=( my/moodle )

do_download() {
   return 0
}

do_build() {
  return 0
}

do_install() {
  cp -r . "${pkg_prefix}/moodle-plugin-o365"
  return 0
}

do_verify() {
  return 0
}
do_unpack() {
  git clone "$pkg_source" $HAB_CACHE_SRC_PATH/$pkg_name
  pushd $HAB_CACHE_SRC_PATH/$pkg_name
  git checkout tags/v"$pkg_version"
  # return 0
}
