[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

# Apache JMeter
The JMeter application is open source software to load test functional behavior and measure performance.

### Tag-History
* `5.4.2-20211221`, `latest` ([Dockerfile](https://github.com/mosaic-hgw/jMeter/blob/master/Dockerfile))
  - from:     alpine:3.15.0
  - updated:  Apache jMeter v5.4.2
  - updated:  java-json 20211205
  - updated:  MySQL-connector v8.0.27
  - vulnerable updates:
    - lib/httpclient 4.5.13 <sub>(GHSA-7r82-7xv7-xcpj,CVE-2020-13956)</sub>
    - lib/jackson-databind 2.10.5.1 <sub>(GHSA-288c-cq4h-88gq,CVE-2020-25649)</sub>
    - lib/json-smart 2.4.1 <sub>(GHSA-v528-7hrm-frqp,CVE-2021-27568)</sub>
    - lib/jsoup 1.14.2 <sub>(GHSA-m72m-mhq2-9p6c,CVE-2021-37714)</sub>
    - lib/log4j-1.2-api 2.17.0
    - lib/log4j-api 2.17.0 <sub>(GHSA-p6xc-xr62-6r2g,CVE-2021-45105)</sub>
    - lib/log4j-core 2.17.0 <sub>(GHSA-p6xc-xr62-6r2g,CVE-2021-45105)</sub>
    - lib/log4j-slf4j-impl 2.17.0
    - lib/neo4j-java-driver 4.4.2 <sub>(GHSA-grg4-wf29-r9vv,GHSA-9vjp-v76f-g363)</sub>
    - lib/tika-core 1.2.6 <sub>(CVE-2021-28657)</sub>
    - lib/tika-parsers 1.2.6 <sub>(CVE-2021-28657)</sub>
    - lib/xstream 1.4.18 <sub>(GHSA-hvv8-336g-rx3m,GHSA-7chv-rrw6-w6fc,GHSA-hwpc-8xqv-jvj4,GHSA-6w62-hx7r-mw68,GHSA-2q8x-2p7f-574v,GHSA-hph2-m3g5-xxv4,GHSA-3ccq-5vw3-2p6x,GHSA-qrx8-8545-4wg2,GHSA-h7v4-7xg3-hxcc,GHSA-p8pq-r894-fm8f,GHSA-8jrj-525p-826v,GHSA-j9h8-phrw-h4fh,GHSA-g5w6-mrj7-75h2,GHSA-64xx-cq4q-mf44,GHSA-6wf9-jmg9-vxcc,GHSA-cxfm-5m4g-x7xp,GHSA-xw4p-crpj-vjx2,GHSA-56p8-3fh9-4cvq,GHSA-qpfq-ph7r-qv6f,GHSA-f6hm-88x3-mfjv,GHSA-43gc-mjxg-gvrq,GHSA-hrcp-8f3q-4w2c,GHSA-4hrm-m67v-5cxr,GHSA-59jw-jqf4-3wq3,GHSA-74cv-f58x-f9wf,GHSA-2p3x-qw9c-25hh)</sub>
* `5.4-20210121`
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
