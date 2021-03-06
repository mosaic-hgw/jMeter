[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

# Apache JMeter
The JMeter application is open source software to load test functional behavior and measure performance.

### Tag-History
* `5.4-20210121`, `latest` ([Dockerfile](https://github.com/mosaic-hgw/jMeter/blob/master/Dockerfile))
  - from:     alpine:3.13
  - updated:  Apache jMeter v5.4.1
  - updated:  java-json v20201115
  - updated:  MySQL-connector v8.0.23
* `5.3-20201127`
  - from:     alpine:3.12
  - updated:  Apache jMeter v5.3
  - updated:  MySQL-connector v8.0.22
  - updated:  wait-for-it.sh from Feb 01, 2020
  - added:    java-json v20200518
* `4.0-20180314`
  - updated:  Apache jMeter v4.0
  - updated:  MySQL-connector v5.1.46
* `3.1-20161129`
  - updated:  Apache jMeter v3.1
  - updated:  MySQL-Connector v5.1.40
* `3.0-20160928`
  - from:     centos:7
  - added:    Apache jMeter v3.0
  - added:    jMeter-Plugins Standard v1.4.0
  - added:    MySQL-Connector v5.1.39
  - added:    wait-for-it.sh
  - created:  script `run.sh` to start jmeter-application and analyze log contains errors
  - created:  user `jmeter` to execute jmeter-application

### Run this Image
* only jmeter-tests (*.jmx)
  ```sh
  docker run \
    -v /path/to/your/tests:/entrypoint-jmeter-testfiles \
    mosaicgreifswald/jmeter
  ```

* with jmeter-tests and properties
  ```sh
  docker run \
    -v /path/to/your/tests:/entrypoint-jmeter-testfiles \
    -v /path/to/your/properties:/entrypoint-jmeter-properties \
    mosaicgreifswald/jmeter
  ```

* with wait for a specified port
  ```sh
  docker run \
    -v /path/to/your/tests:/entrypoint-jmeter-testfiles \
    mosaicgreifswald/jmeter \
    ./wait-for-it.sh service-ip:port && ./run.sh
  ```

* with custom parameters
  ```sh
  docker run \
    -v /path/to/your/tests:/entrypoint-jmeter-testfiles \
    mosaicgreifswald/jmeter \
    bin/jmeter -n -t /entrypoint-jmeter-testfiles/my-test.jmx
  ```
