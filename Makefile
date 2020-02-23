.PHONY: clean build deploy

build: clean
	hugo -t lanyon

clean:
	rm -rf public

deploy: build
	gcloud config configurations activate personal
	gsutil -m rsync -r -d -c public gs://www.mattnworb.com
	gsutil -m acl ch -r -u AllUsers:R gs://www.mattnworb.com

