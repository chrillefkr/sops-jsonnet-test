SOPS_AGE_KEY=$$(grep AGE-SECRET-KEY key.txt)
AGE_PUBLIC_KEY=$$(sed -nE 's/^\# public key: (.*)$$/\1/p' key.txt | head -n 1)

.PHONY: all
all: cleartext.json

key.txt:
	@age-keygen -o key.txt 2>/dev/null

secrets.sops.json: key.txt secrets.json
	@sops --encrypt --age $(AGE_PUBLIC_KEY) --output secrets.sops.json secrets.json

cleartext.json: secrets.sops.json key.txt
	@SOPS_AGE_KEY=$(SOPS_AGE_KEY) sops -d secrets.sops.json | jsonnet --ext-code-file secrets=/dev/stdin main.jsonnet -o cleartext.json

.PHONY: clean
clean:
	@rm -v key.txt secrets.sops.json cleartext.json


.PHONY: stdout
stdout: secrets.sops.json key.txt
	@SOPS_AGE_KEY=$(SOPS_AGE_KEY) sops -d secrets.sops.json | jsonnet --ext-code-file secrets=/dev/stdin main.jsonnet

.PHONY: edit-secrets
edit-secrets: secrets.sops.json key.txt
	@SOPS_AGE_KEY=$(SOPS_AGE_KEY) sops secrets.sops.json

