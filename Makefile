BROTLI_VERSION := 0.5.2
RPM_REVISION := 1

SOURCE_ARCHIVE := v$(BROTLI_VERSION).tar.gz
SPEC_FILE := brotli-$(BROTLI_VERSION)-$(RPM_REVISION).spec
SPEC_PATH := rpmbuild/SPECS/$(SPEC_FILE)

TARGZ_FILE := brotli.tar.gz
IMAGE_NAME := brotli-package
centos6: IMAGE_NAME := $(IMAGE_NAME)-ce6
centos7: IMAGE_NAME := $(IMAGE_NAME)-ce7

.PHONY: all clean centos6 centos7

all: centos6 centos7
centos6: centos6.build
centos7: centos7.build

rpmbuild/SOURCES/$(SOURCE_ARCHIVE):
	curl -SL https://github.com/google/brotli/archive/$(SOURCE_ARCHIVE) -o rpmbuild/SOURCES/$(SOURCE_ARCHIVE)

$(SPEC_PATH): rpmbuild/SPECS/brotli.spec.in
	sed -e s/__BROTLI_VERSION__/$(BROTLI_VERSION)/ -e s/__RPM_RELEASE__/$(RPM_REVISION)/ $< > $@

%.build: $(SPEC_PATH) rpmbuild/SOURCES/$(SOURCE_ARCHIVE)
	[ -d $@.bak ] && rm -rf $@.bak || :
	[ -d $@ ] && mv $@ $@.bak || :
	docker build -t $(IMAGE_NAME) \
		--build-arg=BROTLI_VERSION=$(BROTLI_VERSION) \
		--build-arg=SPEC_FILE=$(SPEC_FILE) \
		-f Dockerfile.$* \
		.
	docker run --name $(IMAGE_NAME)-tmp $(IMAGE_NAME)
	mkdir -p tmp
	docker wait $(IMAGE_NAME)-tmp
	docker cp $(IMAGE_NAME)-tmp:/tmp/$(TARGZ_FILE) tmp
	docker rm $(IMAGE_NAME)-tmp
	mkdir $@
	tar -xzf tmp/$(TARGZ_FILE) -C $@
	rm -rf tmp
	docker images | grep -q $(IMAGE_NAME) && docker rmi $(IMAGE_NAME) || true

clean:
	rm -rf *.build.bak *.build tmp rpmbuild/SPECS/*.spec
	docker images | grep -q $(IMAGE_NAME)-ce6 && docker rmi $(IMAGE_NAME)-ce6 || true
	docker images | grep -q $(IMAGE_NAME)-ce7 && docker rmi $(IMAGE_NAME)-ce7 || true
