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

echo "run following command in adb shell"
echo 
"mv /sdcard/$hash.0 /system/etc/security/cacerts/

chmod 644 /system/etc/security/cacerts/$hash.0

reboot"


