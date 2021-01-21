#!/bin/bash

echo "Remove Old cert file"
burpcert="./cacert.der"
if test -f "$burpcert"; then
	rm $burpcert
fi

echo "get new cert"
curl http://127.0.0.1:8080/cert -o cacert.der
echo "convert cert"
openssl x509 -inform DER -in cacert.der -out cacert.pem

hash=$(openssl x509 -inform PEM -subject_hash_old -in cacert.pem |head -1)
echo "create copy of cert w hash"
cp cacert.pem $hash.0

echo "move cert file to android"
adb root
adb remount
adb push $hash.0 /sdcard/
#Below is for ssl pinning bypass if needed
adb push cacert.der /data/local/tmp/cert-der.crt

adb shell 'mv /sdcard/$hash.0 /system/etc/security/cacerts/'
adb shell 'chmod 644 /system/etc/security/cacerts/$hash.0'
adb shell 'chmod 644 /data/local/tmp/cert-der.crt'
adb shell 'reboot'


