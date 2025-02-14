# (c) Meta Platforms, Inc. and affiliates. Confidential and proprietary.

# getdeps.py install directory
GD_INSTALL_DIR=/data/users/jmswen/scratch/dataZusersZjmswenZfbsource/fbcode_builder_getdeps/installed

# Order is important – fbcode libs should precede everything else
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/fbcode/platform010/lib:/lib64:/usr/lib64:/data/users/jmswen/test/.venv

for lib_dir in $GD_INSTALL_DIR/*; do
  if [ -d "$lib_dir" ]; then
    if [ -d "$lib_dir/lib" ]; then
      LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$lib_dir/lib"
    elif [ -d "$lib_dir/lib64" ]; then
      LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$lib_dir/lib64"
    else
      echo "[ERROR] Failed to find library subdirectory within "$lib_dir""
    fi
  fi
done

LD_LIBRARY_PATH=$LD_LIBRARY_PATH python server.py
