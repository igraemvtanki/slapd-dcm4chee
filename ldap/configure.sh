#!/bin/sh

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/dicom.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/dcm4che.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/dcm4chee-archive.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/dcm4chee-archive-ui.ldif

cd /etc/ldap/data
if [ "$SKIP_INIT_CONFIG" != "true" ]; then
	for f in default-config.ldif add-vendor-data.ldif init-ui-config.ldif default-ui-permissions.ldif default-users.ldif $EXT_INIT_CONFIG; do
		sed -e "s%dc=dcm4che,dc=org%${LDAP_BASE_DN}%" \
			-e "s%dicomDeviceName=dcm4chee-arc%dicomDeviceName=${ARCHIVE_DEVICE_NAME}%" \
			-e "s%dicomDeviceName: dcm4chee-arc%dicomDeviceName: ${ARCHIVE_DEVICE_NAME}%" \
			-e "s%dicomAETitle=DCM4CHEE%dicomAETitle=${AE_TITLE}%" \
			-e "s%dicomAETitle: DCM4CHEE%dicomAETitle: ${AE_TITLE}%" \
			-e "s%dcmRetrieveAET: DCM4CHEE%dcmRetrieveAET: ${AE_TITLE}%" \
			-e "s%dcmStorageVerificationAETitle: DCM4CHEE%dcmStorageVerificationAETitle: ${AE_TITLE}%" \
			-e "s%dcmXDSiImagingDocumentSourceAETitle: DCM4CHEE%dcmXDSiImagingDocumentSourceAETitle: ${AE_TITLE}%" \
			-e "s%dcmRejectExpiredStudiesAETitle: DCM4CHEE%dcmRejectExpiredStudiesAETitle: ${AE_TITLE}%" \
			-e "s%dcmRejectionNoteStorageAET: DCM4CHEE%dcmRejectionNoteStorageAET: ${AE_TITLE}%" \
			-e "s%archive-host%${ARCHIVE_HOST}%" \
			-e "s%dicomDeviceName=scheduledstation%dicomDeviceName=${SCHEDULED_STATION_DEVICE_NAME}%" \
			-e "s%dicomDeviceName: scheduledstation%dicomDeviceName: ${SCHEDULED_STATION_DEVICE_NAME}%" \
			-e "s%dicomAETitle=SCHEDULEDSTATION%dicomAETitle=${SCHEDULED_STATION_AE_TITLE}%" \
			-e "s%dicomAETitle: SCHEDULEDSTATION%dicomAETitle: ${SCHEDULED_STATION_AE_TITLE}%" \
			-e "s%dicomDeviceName=keycloak%dicomDeviceName=${KEYCLOAK_DEVICE_NAME}%" \
			-e "s%dicomDeviceName: keycloak%dicomDeviceName: ${KEYCLOAK_DEVICE_NAME}%" \
			-e "s%keycloak-host%${KEYCLOAK_HOST}%" \
			-e "s%11112%${DICOM_PORT}%" \
			-e "s%2575%${HL7_PORT}%" \
			-e "s%dicomDeviceName=logstash%dicomDeviceName=${SYSLOG_DEVICE_NAME}%" \
			-e "s%dicomDeviceName: logstash%dicomDeviceName: ${SYSLOG_DEVICE_NAME}%" \
			-e "s%syslog-host%${SYSLOG_HOST}%" \
			-e "s%514%${SYSLOG_PORT}%" \
			-e "s%SYSLOG_UDP%SYSLOG_${SYSLOG_PROTOCOL}%" \
			-e "s%\${jboss.server.data.url}/fs1%file://${STORAGE_DIR}%" \
			$f | ldapadd -Y EXTERNAL -H ldapi:///
	done
fi

if [ -n "$IMPORT_LDIF" ]; then
	for f in $IMPORT_LDIF; do
		ldapadd -Y EXTERNAL -H ldapi:/// -f $f
	done
fi
