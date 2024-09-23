CURDIR:=$(shell pwd)
# Deferenced latest tag from Docker image registry
# https://hub.docker.com/r/marpteam/marp-cli/tags
MARP_CLI_VERSION:=sha256:cd0e8581130091773ddac486d075fa619be4d135cb8c58b7e34fbe6b59b82f97
MARP_CLI_INSTALL_CMD:=docker pull marpteam/marp-cli@$(MARP_CLI_VERSION)
MARP_CLI_UNINSTALL_CMD:=docker rmi marpteam/marp-cli@$(MARP_CLI_VERSION)
MARP_CLI_EXEC_ARGS:=--rm --init -v $(CURDIR):/home/marp/app -e LANG=en_US.UTF-8 -p 8080:8080 -p 37717:37717 $(MARP_CLI_EXEC_ARGS) marpteam/marp-cli@$(MARP_CLI_VERSION)
MARP_CLI_EXEC_CMD:=docker run
MARP_CLI_EXEC_CMD_FULL:=$(MARP_CLI_EXEC_CMD) $(MARP_CLI_EXEC_ARGS)

.PHONY: help
help:
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: init
init: ## Install and configure dependencies
	$(MARP_CLI_INSTALL_CMD)

pres.pdf: ## Publish PDF version of presentation
	$(MARP_CLI_EXEC_CMD_FULL) pres.md --pdf

pres.pptx: ## Publish PowerPoint version of presentation
	$(MARP_CLI_EXEC_CMD_FULL) pres.md --pptx

.PHONY: debug
debug: ## Debug interactively running in container for install problems
	$(MARP_CLI_EXEC_CMD) -it --entrypoint /bin/sh $(MARP_CLI_EXEC_ARGS)

.PHONY: clean
clean: ## Clean only artifacts, not software or container images
	rm -f pres.pdf
	rm -f pres.pptx

.PHONY: uninstall
uninstall: ## Remove software or container
	$(MARP_CLI_UINSTALL_CMD)


.PHONY: watch
watch: ## Run presentation in watch mode
	$(MARP_CLI_EXEC_CMD_FULL) -w pres.md


.PHONY: serve
serve: ## Serve the presentation with a local web server
	$(MARP_CLI_EXEC_CMD_FULL) -s .

all: init pres.pdf pres.pptx ## Install dependencies and published exported formats
