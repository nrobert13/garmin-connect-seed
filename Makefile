include /home/code/build/properties.mk

sources = `find source -name '*.mc'`
resources = `find resources -name '*.xml' | tr '\n' ':' | sed 's/.$$//'`
device_resources = `find resources-$(DEVICE) -name '*.xml' | tr '\n' ':' | sed 's/.$$//'`
appName = `grep entry manifest.xml | sed 's/.*entry="\([^"]*\).*/\1/'`
PRIVATE_KEY = /home/code/devkey/developer_key.der

build:
	$(SDK_HOME)/bin/monkeyc --warn --output bin/$(appName).prg -m manifest.xml \
	-z $(resources):$(device_resources) -u $(SDK_HOME)/bin/devices.xml \
	-y $(PRIVATE_KEY) \
	-p $(SDK_HOME)/bin/projectInfo.xml -d $(DEVICE) $(sources)

run: build
	$(SDK_HOME)/bin/monkeysim &
	while ! netstat -ntlp | egrep "123[4-8]" ; do sleep 1 ; done
	$(SDK_HOME)/bin/monkeydo bin/$(appName).prg $(DEVICE)

deploy: build
	cp bin/$(appName).prg $(DEPLOY)

package:
	$(SDK_HOME)/bin/monkeyc --warn --output bin/$(appName).iq -m manifest.xml \
	-z $(resources):$(device_resources) -u $(SDK_HOME)/bin/devices.xml \
	-y $(PRIVATE_KEY)
	-p $(SDK_HOME)/bin/projectInfo.xml $(sources) -e -r
