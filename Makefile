.PHONY: clean build deploy

build: clean
	hugo -t lanyon

clean:
	rm -rf public

