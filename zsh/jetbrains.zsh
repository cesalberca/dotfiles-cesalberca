_jetbrains_open() {
  local launcher="$1"; shift
  local args=()
  for arg in "$@"; do
    if [[ -e $arg ]]; then
      args+=("${arg:A}")
    else
      args+=("$arg")
    fi
  done
  command "$launcher" "${args[@]}"
}

for _jb in webstorm rustrover goland idea pycharm phpstorm clion rider datagrip rubymine fleet; do
  if command -v "$_jb" >/dev/null 2>&1; then
    eval "$_jb() { _jetbrains_open $_jb \"\$@\"; }"
  fi
done
unset _jb
