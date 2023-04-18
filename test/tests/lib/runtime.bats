# Test the runtime selection

# source the Nos framework
. /opt/microbox/nos/common.sh

# source the nos test helper
. util/nos.sh

# source stub.sh to stub functions and binaries
. util/stub.sh

# initialize nos
nos_init

# source the ruby libraries
. ${engine_lib_dir}/ruby.sh

setup() {
  rm -rf /tmp/code
  mkdir -p /tmp/code
  nos_reset_payload
}

@test "detects runtime from Gemfile" {
  skip
  # todo: implement functionality
}

@test "default runtime uses Gemfile if available" {

  stub_and_echo "gemfile_runtime" "ruby-from-package-json"

  default=$(default_ruby_runtime)

  restore "gemfile_runtime"

  [ "$default" = "ruby-from-package-json" ]
}

@test "default runtime falls back to a hard-coded default" {

  stub_and_echo "gemfile_runtime" "false"

  default=$(default_ruby_runtime)

  restore "gemfile_runtime"

  [ "$default" = "ruby-2.2" ]
}

@test "runtime is chosen from the Boxfile if present" {

    nos_init "$(cat <<-END
{
  "config": {
    "ruby_runtime": "boxfile-runtime"
  }
}
END
)"

  runtime=$(ruby_runtime)

  [ "$runtime" = "boxfile-runtime" ]
}

@test "runtime falls back to default runtime" {

  stub_and_echo "default_ruby_runtime" "default-runtime"

  default=$(default_ruby_runtime)

  restore "gemfile_runtime"

  [ "$default" = "default-runtime" ]
}

@test "will install ruby" {
  called="false"

  stub_and_eval "nos_install" "called=\"true\""

  install_runtime_packages

  restore "is_node_installed"
  restore "nos_install"

  [ "$called" = "true" ]
}

@test "generates a valid condensed runtime" {
  stub_and_echo "ruby_runtime" "ruby-2.2"

  condensed=$(condensed_ruby_runtime)

  restore "runtime"

  [ "$condensed" = "ruby22" ]
}
