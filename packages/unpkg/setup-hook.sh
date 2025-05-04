unpackCmdHooks+=(_tryUnpack)

unpkg() {
  local file="$1"
  xar --dump-header -f "${file}" | grep -q "^magic:\s\+[0-9a-z]\+\s\+(OK)$"
  [ $? -ne 0 ] && return 1
  xar -tf "${file}" | grep -q "/Payload$"
  dir="$(mktemp -d)"
  xar -xf "${file}" -C "${dir}"
  zcat ${dir}/*/Payload | cpio -idm --no-absolute-filenames
  rm -rf --preserve-root "${dir}"
}

function processFile() {
  local file="$1"
  echo "Processing file: $file"
  if [[ "$file" =~ \env-vars$ ]]; then
    return
  elif [[ "$file" =~ \.zip$ ]]; then
    unzip -qq "$file"
  elif [[ "$file" =~ \.pkg$ ]]; then
    unpkg "$file"
  elif [[ "$file" =~ \.dmg$ ]]; then
    7zz x "$file"
  else
    echo "Unknown file type: $file"
  fi
}

processFolder() {
  local folder="$1"
  echo "Processing folder: $folder"
  for file in "$folder"/*; do
    if [[ "${file}" =~ \.app$ ]]; then 
      if [[ "${folder}" == "." ]]; then
        echo "No moving"
        continue
      else
        echo "Moving app to parent directory"
        mv "$file" .
      fi
    elif [[ -d "$file" ]]; then
      processFolder "$file"
    else
      processFile "$file"
    fi
  done
}

_tryUnpack() {
  processFile "$curSrc"
  processFolder .
}
