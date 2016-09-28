FROM centos:7

# ###license-information-start###
# jMeter
# __
# Copyright (C) 2009 - 2016 MOSAIC - Institute for Community Medicine
# University Medicine of Greifswald - mosaic@uni-greifswald.de
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

ENV JMETER_VERSION					3.0
ENV JMETER_DOWNLOAD_URL				https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.zip
ENV JMETER_PATH						/opt/jmeter
ENV JMETER_SHA1						197ec833318efadac7bc6553a926d2026eb132c1
ENV JMETER_USER						jmeter
ENV ENTRY_JMETER_TESTS				/entrypoint-jmeter-testfiles
ENV ENTRY_JMETER_PROPERTIES			/entrypoint-jmeter-properties

ENV JMETER_PLUGINS_VERSION			1.4.0
ENV JMETER_PLUGINS_DOWNLOAD_URL		http://jmeter-plugins.org/downloads/file/JMeterPlugins-Standard-${JMETER_PLUGINS_VERSION}.zip
ENV JMETER_PLUGINS_PATH				${JMETER_PATH}
ENV JMETER_PLUGINS_SHA1				3af5352bfb29b38a73f8620f2af89f842e3666f2

ENV MYSQL_CONNECTOR_VERSION			5.1.39
ENV MYSQL_CONNECTOR_DOWNLOAD_URL	http://central.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar
ENV MYSQL_CONNECTOR_PATH			${JMETER_PATH}/lib
ENV MYSQL_CONNECTOR_SHA1			4617fe8dc8f1969ec450984b0b9203bc8b7c8ad5

ENV WAIT_FOR_IT_DOWNLOAD_URL		https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh
ENV WAIT_FOR_IT_SHA1				d6bdd6de4669d72f5a04c34063d65c33b8a5450c

ENV TEMP_PATH						/opt/tmp


# install needed packages and create user
RUN	yum update -y && \
	yum -y install java-${JAVA_VERSION}-openjdk-devel && \
	yum clean all && \

	mkdir -p ${JMETER_PATH} ${ENTRY_JMETER_TESTS} ${ENTRY_JMETER_PROPERTIES} ${TEMP_PATH} && \
	cd  ${JMETER_PATH} && \

	curl -L ${JMETER_DOWNLOAD_URL} -o ${TEMP_PATH}/apache-jmeter-${JMETER_VERSION}.zip && \
	sha1sum ${TEMP_PATH}/apache-jmeter-${JMETER_VERSION}.zip | grep $JMETER_SHA1 && \
	jar xf ${TEMP_PATH}/apache-jmeter-${JMETER_VERSION}.zip && \
	mv ${JMETER_PATH}/apache-jmeter-${JMETER_VERSION}/* ${JMETER_PATH}/ && \

	curl -L ${JMETER_PLUGINS_DOWNLOAD_URL} -o ${TEMP_PATH}/JMeterPlugins-Standard-${JMETER_PLUGINS_VERSION}.zip && \
	sha1sum ${TEMP_PATH}/JMeterPlugins-Standard-${JMETER_PLUGINS_VERSION}.zip | grep $JMETER_PLUGINS_SHA1 && \
	jar xf ${TEMP_PATH}/JMeterPlugins-Standard-${JMETER_PLUGINS_VERSION}.zip lib && \

	curl -L ${MYSQL_CONNECTOR_DOWNLOAD_URL} -o ${MYSQL_CONNECTOR_PATH}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar && \
	sha1sum ${MYSQL_CONNECTOR_PATH}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar | grep $MYSQL_CONNECTOR_SHA1 && \

	curl -L ${WAIT_FOR_IT_DOWNLOAD_URL} -o ${JMETER_PATH}/wait-for-it.sh && \
	sha1sum ${JMETER_PATH}/wait-for-it.sh | grep $WAIT_FOR_IT_SHA1 && \

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
	chmod u+x ${JMETER_PATH}/wait-for-it.sh ${JMETER_PATH}/run.sh ${JMETER_PATH}/bin/jmeter && \
	chmod 777 ${ENTRY_JMETER_TESTS} ${ENTRY_JMETER_PROPERTIES}

# change user and work-directory
USER ${JMETER_USER}
WORKDIR ${JMETER_PATH}

CMD ["./run.sh"]
