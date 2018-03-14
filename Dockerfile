FROM centos:7

# ###license-information-start###
# The MOSAIC-Project - WildFly with MySQL-Connector
# __
# Copyright (C) 2009 - 2017 Institute for Community Medicine
# University Medicine of Greifswald – mosaic-project@uni-greifswald.de
# __
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# ###license-information-end###

MAINTAINER Ronny Schuldt <ronny.schuldt@uni-greifswald.de>


ENV JAVA_VERSION					1.8.0

ENV JMETER_VERSION					4.0
ENV JMETER_DOWNLOAD_URL				https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.zip
ENV JMETER_PATH						/opt/jmeter
ENV JMETER_SHA512					acb4489bc875513ccc467782b3872e4adc048cd0fc8f375337dca8da82d48a83374ebfa749a8d3ae65163e32b5d11dfa44e557ca9b103b43d365dc6a6fc0ff56
ENV JMETER_USER						jmeter
ENV ENTRY_JMETER_TESTS				/entrypoint-jmeter-testfiles
ENV ENTRY_JMETER_PROPERTIES			/entrypoint-jmeter-properties

ENV JMETER_PLUGINS_VERSION			1.4.0
ENV JMETER_PLUGINS_DOWNLOAD_URL		http://jmeter-plugins.org/downloads/file/JMeterPlugins-Standard-${JMETER_PLUGINS_VERSION}.zip
ENV JMETER_PLUGINS_PATH				${JMETER_PATH}
ENV JMETER_PLUGINS_SHA256			3f740bb9b9a7120ed72548071cd46a5f92929e1ab196acc1b2548549090a2148

ENV MYSQL_CONNECTOR_VERSION			5.1.46
ENV MYSQL_CONNECTOR_DOWNLOAD_URL	http://central.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar
ENV MYSQL_CONNECTOR_PATH			${JMETER_PATH}/lib
ENV MYSQL_CONNECTOR_SHA256			3122089761e6403f02e8a81ed4a2d65a2e1029734651ba00f2ea92d920ff7b1e

ENV WAIT_FOR_IT_DOWNLOAD_URL		https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh
ENV WAIT_FOR_IT_SHA256				0f75de5c9d9c37a933bb9744ffd710750d5773892930cfe40509fa505788835c

ENV TEMP_PATH						/opt/tmp


# install needed packages and create user
RUN	yum update -y && \
	yum -y install java-${JAVA_VERSION}-openjdk-devel && \
	yum clean all && \

	mkdir -p ${JMETER_PATH} ${ENTRY_JMETER_TESTS} ${ENTRY_JMETER_PROPERTIES} ${TEMP_PATH} && \
	cd  ${JMETER_PATH} && \

	curl -L ${JMETER_DOWNLOAD_URL} -o ${TEMP_PATH}/apache-jmeter-${JMETER_VERSION}.zip && \
	(sha512sum ${TEMP_PATH}/apache-jmeter-${JMETER_VERSION}.zip | grep ${JMETER_SHA512} || (>&2 echo "sha512sum failed $(sha512sum ${TEMP_PATH}/apache-jmeter-${JMETER_VERSION}.zip)" && exit 1)) && \
	jar xf ${TEMP_PATH}/apache-jmeter-${JMETER_VERSION}.zip && \
	mv ${JMETER_PATH}/apache-jmeter-${JMETER_VERSION}/* ${JMETER_PATH}/ && \

	curl -L ${JMETER_PLUGINS_DOWNLOAD_URL} -o ${TEMP_PATH}/JMeterPlugins-Standard-${JMETER_PLUGINS_VERSION}.zip && \
	(sha256sum ${TEMP_PATH}/JMeterPlugins-Standard-${JMETER_PLUGINS_VERSION}.zip | grep ${JMETER_PLUGINS_SHA256} || (>&2 echo "sha256sum failed $(sha256sum ${TEMP_PATH}/JMeterPlugins-Standard-${JMETER_PLUGINS_VERSION}.zip)" && exit 1)) && \
	jar xf ${TEMP_PATH}/JMeterPlugins-Standard-${JMETER_PLUGINS_VERSION}.zip lib && \

	curl -Lso ${MYSQL_CONNECTOR_PATH}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar ${MYSQL_CONNECTOR_DOWNLOAD_URL} && \
	(sha256sum ${MYSQL_CONNECTOR_PATH}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar | grep ${MYSQL_CONNECTOR_SHA256} || (>&2 echo "sha256sum failed $(sha256sum ${MYSQL_CONNECTOR_PATH}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar)" && exit 1)) && \

	curl -Lso ${JMETER_PATH}/wait-for-it.sh ${WAIT_FOR_IT_DOWNLOAD_URL} && \
	(sha256sum ${JMETER_PATH}/wait-for-it.sh | grep ${WAIT_FOR_IT_SHA256} || (>&2 echo "sha256sum failed $(sha256sum ${JMETER_PATH}/wait-for-it.sh)" && exit 1)) && \

	{ \
        echo '#!/bin/bash'; \
        echo; \
        echo 'TEST_FILES=$(ls -d '${ENTRY_JMETER_TESTS}'/*.jmx 2> /dev/null | sort)'; \
        echo 'PROPERTIES=$(ls -d '${ENTRY_JMETER_PROPERTIES}'/*.* 2> /dev/null | sort)'; \
        echo '[ -z "${TEST_FILES}" ] || TEST_FILES="-t ${TEST_FILES}"'; \
        echo '[ -z "${PROPERTIES}" ] || PROPERTIES="-q ${PROPERTIES}"'; \
        echo; \
        echo 'bin/jmeter -n ${TEST_FILES} ${PROPERTIES} | tee stdout.log'; \
        echo; \
        echo 'while read LINE ; do'; \
        echo '    if echo ${LINE} | grep -qP "summary =[^E]+Err: +[1-9]+ \(" ; then'; \
        echo '        exit 1'; \
        echo '    fi'; \
        echo 'done < stdout.log'; \
	} > ${JMETER_PATH}/run.sh && \

	rm -rf ${TEMP_PATH} ${JMETER_PATH}/apache-jmeter-${JMETER_VERSION} && \
	groupadd -r ${JMETER_USER} && \
	useradd -r -g ${JMETER_USER} -d ${JMETER_PATH} -s /dev/false -c "User for Apache-jMeter" ${JMETER_USER} && \
	chown -R ${JMETER_USER}:${JMETER_USER} ${JMETER_PATH} ${ENTRY_JMETER_TESTS} ${ENTRY_JMETER_PROPERTIES} && \
	chmod u+x -R ${JMETER_PATH} && \
	chmod 777 ${ENTRY_JMETER_TESTS} ${ENTRY_JMETER_PROPERTIES}

# change user and work-directory
USER ${JMETER_USER}
WORKDIR ${JMETER_PATH}

CMD ["./run.sh"]
