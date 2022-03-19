unpackCmdHooks+=(_tryUnpackPkg _tryUnzip)
_tryUnzip() {
    if ! [[ "$curSrc" =~ \.zip$ ]]; then return 1; fi
    unzip -qq "$curSrc"

    echo Debug
    for file in *
    do
      if [[ "${file}" =~ \.pkg$ ]]
      then 
        curSrc=$file
        _tryUnpackPkg
      fi
    done
}
_tryUnpackPkg() {
  if ! [[ "${curSrc}" =~ \.pkg$ ]]; then return 1; fi
  xar --dump-header -f "${curSrc}" | grep -q "^magic:\s\+[0-9a-z]\+\s\+(OK)$"
  [ $? -ne 0 ] && return 1
  xar -tf "${curSrc}" | grep -q "/Payload$"
  dir="$(mktemp -d)"
  xar -xf "${curSrc}" -C "${dir}"
  zcat ${dir}/*/Payload | cpio -idm --no-absolute-filenames
  rm -rf --preserve-root "${dir}"
}