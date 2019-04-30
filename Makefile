VAGRANT_CLOUD_USERNAME ?= mrbarker
VERSION := 1.0.$(shell date +%s)
PUBLISH_OPTIONS := "--force"

.PHONY: install-boxes install-box-amd64-virtualbox install-box-amd64-vmware

all: install-boxes

install-boxes: install-box-amd64-virtualbox install-box-amd64-vmware

install-box-amd64-virtualbox: ubuntu-amd64-virtualbox.box
	vagrant box add -f --name $(VAGRANT_CLOUD_USERNAME)/ubuntu-amd64 --provider virtualbox ubuntu-amd64-virtualbox.box

install-box-amd64-vmware: ubuntu-amd64-vmware.box
	vagrant box add -f --name $(VAGRANT_CLOUD_USERNAME)/ubuntu-amd64 --provider vmware_desktop ubuntu-amd64-vmware.box

ubuntu-amd64-virtualbox.box: ubuntu-amd64.json *.sh
	PACKER_LOG=1 packer build -force -only virtualbox-iso ubuntu-amd64.json

ubuntu-amd64-vmware.box: ubuntu-amd64.json *.sh
	PACKER_LOG=1 packer build -force -only vmware-iso ubuntu-amd64.json

publish-boxes: publish-box-amd64-virtualbox.box publish-box-amd64-vmware.box

publish-box-amd64-virtualbox: ubuntu-amd64-virtualbox.box
	vagrant cloud publish $(VAGRANT_CLOUD_USERNAME)/ubuntu-amd64 $(VERSION) virtualbox ./ubuntu-amd64-virtualbox.box $(PUBLISH_OPTIONS)

publish-box-amd64-vmware: ubuntu-amd64-vmware.box
	vagrant cloud publish $(VAGRANT_CLOUD_USERNAME)/ubuntu-amd64 $(VERSION) vmware_desktop ./ubuntu-amd64-vmware.box $(PUBLISH_OPTIONS)

clean: clean-boxes clean-vagrant clean-artifacts

clean-boxes:
	-rm *.box

clean-vagrant:
	-rm -rf .vagrant

clean-artifacts:
	-rm -rf packer_cache

lint: packer-validate shfmt

packer-validate:
	find . -name '*.json' -exec packer validate {} \;

shfmt:
	find . -name '*.sh' -print | xargs shfmt -w -i 4
