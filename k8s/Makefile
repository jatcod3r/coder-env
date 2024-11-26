build:
	terraform -chdir=./src init

validate:
	terraform -chdir=./src validate

plan:
	terraform -chdir=./src plan

deploy:
	terraform -chdir=./src apply -auto-approve

apply-coderd:
	kubectl kustomize --enable-helm src/manifests/coder/coderd | kubectl apply -f -

delete-coderd:
	kubectl kustomize --enable-helm src/manifests/coder/coderd | kubectl delete -f -

apply-ws-proxy:
	kubectl kustomize --enable-helm src/manifests/coder/ws-proxy | kubectl apply -f -

delete-ws-proxy:
	kubectl kustomize --enable-helm src/manifests/coder/ws-proxy | kubectl delete -f -

apply-provisionerd:
	kubectl kustomize --enable-helm src/manifests/coder/provisionerd | kubectl apply -f -

delete-provisionerd:
	kubectl kustomize --enable-helm src/manifests/coder/provisionerd | kubectl delete -f -