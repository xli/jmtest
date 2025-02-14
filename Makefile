BUILD_SHARED_LIBS="BUILD_SHARED_LIBS": "ON", "BOOST_LINK_STATIC": "OFF"
INSTALL_DIR=/usr/local
PYTHON_INSTALL_DIR=/usr/local
PYTHON_INCLUDE_DIR=/usr/include/python3.12/
PYTHON_LIBRARY=/usr/lib/aarch64-linux-gnu/libpython3.12.so
PY_CMAKE="PYTHON_PACKAGE_INSTALL_DIR": "$(PYTHON_INSTALL_DIR)", "PYTHON_INCLUDE_DIR": "$(PYTHON_INCLUDE_DIR)", "PYTHON_LIBRARY": "$(PYTHON_LIBRARY)", "PYTHON_LIBRARIES": "$(PYTHON_LIBRARY)", "PYTHON_EXTENSIONS": "ON", "thriftpy3": "ON"
CMAKE_C_FLAGS=
CMAKE_CXX_FLAGS=-std=gnu++20 -O2 -I$(PYTHON_INCLUDE_DIR)
CMAKE_DEBUG="CMAKE_VERBOSE_MAKEFILE": "ON", "CMAKE_VERBOSE_DEBUG": "ON"
CMAKE_DEFINES='{$(PY_CMAKE), "CMAKE_CXX_STANDARD": "20", "CMAKE_POSITION_INDEPENDENT_CODE": "ON", "CMAKE_CXX_FLAGS": "$(CMAKE_CXX_FLAGS)", $(BUILD_SHARED_LIBS), $(CMAKE_DEBUG)}'
JMTEST_BUILD_DIR=/tmp/jmtest

.PHONY: env install build dock jmtest jmtest-server

env:
	pip install --upgrade pip
	pip install setuptools==75.8.0
	pip install setuptools_rust
	pip install wheel==0.45.1
	pip install Cython==3.0.11


install:
#	make build target=googletest
#	make build target=gflags
#	make build target=glog
#	make build target=boost
	make build target=fmt   # centos fmt version is old
#	make build target=fast_float
	make build target=folly
	make build target=fizz
	make build target=wangle
	make build target=mvfst
	make build target=fbthrift
	make build target=fb303


build: target=fbthrift
build:
	./build/fbcode_builder/getdeps.py \
		--allow-system-packages \
		build $(target) \
		--extra-cmake-defines $(CMAKE_DEFINES) \
		--extra-b2-args "cxxflags=-fPIC" --extra-b2-args "cflags=-fPIC" \
		--install-dir $(INSTALL_DIR) \
		--no-test --clean --no-deps  --shared-libs --verbose \
		2>&1 | tee /var/log/build_$(target).log

dock:
	docker build --no-cache -t centos .
	docker run -it centos


jmtest:
	-rm -rf $(JMTEST_BUILD_DIR)
	cp -r jmtest/thrift-py $(JMTEST_BUILD_DIR)
	cp build/fbcode_builder/CMake/* $(JMTEST_BUILD_DIR)/cmake
	cd $(JMTEST_BUILD_DIR) && cmake $(JMTEST_BUILD_DIR) -DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR) \
		-DCMAKE_PREFIX_PATH=$(INSTALL_DIR) \
		-DPYTHON_PACKAGE_INSTALL_DIR=$(INSTALL_DIR) \
		-DCMAKE_CXX_FLAGS="$(CMAKE_CXX_FLAGS)" \
		-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
		-DCMAKE_CXX_STANDARD=20 \
		-DBUILD_SHARED_LIBS=ON \
		-G Ninja
	cd $(JMTEST_BUILD_DIR) && cmake --build . --target install


jmtest-server:
	python3 jmtest/server/server.py

jmtest-client:
	seq 1 100 | parallel -j 100 $(JMTEST_BUILD_DIR)/test_client
