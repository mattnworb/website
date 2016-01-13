.PHONY: clean deploy

clean:
	rm -rf public

deploy: clean
	hugo -t lanyon
	gcloud config configurations activate personal
	gsutil -m cp -r public/* gs://www.mattnworb.com
	gsutil -m acl ch -r -u AllUsers:R gs://www.mattnworb.com

