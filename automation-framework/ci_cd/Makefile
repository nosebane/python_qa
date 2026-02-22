# ══════════════════════════════════════════════════════════════════
# Indodax Automation Framework — Makefile
# ══════════════════════════════════════════════════════════════════
# Usage:
#   make <target> [VAR=value ...]
#
# Examples:
#   make test-api
#   make test-api ENV=production SUITE=public
#   make test-web BROWSER=chromium HEADLESS=false
#   make test-mobile DEVICE=R8AIGF001200RC6
#   make test-all ENV=staging
#   make docker-api
#   make clean
# ══════════════════════════════════════════════════════════════════

SHELL := /bin/bash

# ── Configurable defaults ──────────────────────────────────────────
ENV        ?= staging
BROWSER    ?= chromium
HEADLESS   ?= true
PLATFORM   ?= android
DEVICE     ?=
SUITE      ?=
TAGS       ?=

# ── Paths ──────────────────────────────────────────────────────────
SCRIPT_DIR   := ci_cd/scripts
RESULTS_DIR  := results
COMPOSE_FILE := ci_cd/docker/docker-compose.yml

# ── Colors ─────────────────────────────────────────────────────────
BOLD   := \033[1m
CYAN   := \033[36m
GREEN  := \033[32m
YELLOW := \033[33m
RESET  := \033[0m

.DEFAULT_GOAL := help

# ══════════════════════════════════════════════════════════════════
# HELP
# ══════════════════════════════════════════════════════════════════
.PHONY: help
help: ## 📋 Show this help message
	@printf "\n$(BOLD)Indodax Automation Framework$(RESET)\n\n"
	@printf "$(CYAN)Usage:$(RESET) make $(BOLD)<target>$(RESET) [VAR=value ...]\n\n"
	@printf "$(YELLOW)Test Targets:$(RESET)\n"
	@grep -E '^[a-zA-Z_-]+:.*?##.*Test' $(MAKEFILE_LIST) | \
	  awk 'BEGIN{FS=":.*##"}; {printf "  $(BOLD)%-20s$(RESET) %s\n", $$1, $$2}'
	@printf "\n$(YELLOW)Docker Targets:$(RESET)\n"
	@grep -E '^[a-zA-Z_-]+:.*?##.*Docker' $(MAKEFILE_LIST) | \
	  awk 'BEGIN{FS=":.*##"}; {printf "  $(BOLD)%-20s$(RESET) %s\n", $$1, $$2}'
	@printf "\n$(YELLOW)Utility Targets:$(RESET)\n"
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | \
	  grep -v 'Test\|Docker' | \
	  awk 'BEGIN{FS=":.*##"}; {printf "  $(BOLD)%-20s$(RESET) %s\n", $$1, $$2}'
	@printf "\n$(YELLOW)Variables:$(RESET)\n"
	@printf "  ENV=$(ENV)  BROWSER=$(BROWSER)  HEADLESS=$(HEADLESS)\n"
	@printf "  PLATFORM=$(PLATFORM)  DEVICE=$(DEVICE)\n\n"

# ══════════════════════════════════════════════════════════════════
# TEST TARGETS
# ══════════════════════════════════════════════════════════════════

.PHONY: test-api
test-api: ## Test — Run API tests (ENV, SUITE=public|private|all, TAGS)
	@printf "$(CYAN)▶ API Tests — ENV=$(ENV)$(RESET)\n"
	@bash $(SCRIPT_DIR)/run_api.sh -e $(ENV) $(if $(SUITE),-s $(SUITE)) $(if $(TAGS),-t $(TAGS))

.PHONY: test-api-public
test-api-public: ## Test — Run Public API tests only
	@printf "$(CYAN)▶ Public API Tests — ENV=$(ENV)$(RESET)\n"
	@bash $(SCRIPT_DIR)/run_api.sh -e $(ENV) -s public $(if $(TAGS),-t $(TAGS))

.PHONY: test-api-private
test-api-private: ## Test — Run Private API tests only
	@printf "$(CYAN)▶ Private API Tests — ENV=$(ENV)$(RESET)\n"
	@bash $(SCRIPT_DIR)/run_api.sh -e $(ENV) -s private $(if $(TAGS),-t $(TAGS))

.PHONY: test-web
test-web: ## Test — Run Web tests (ENV, BROWSER, HEADLESS, TAGS)
	@printf "$(CYAN)▶ Web Tests — ENV=$(ENV) BROWSER=$(BROWSER) HEADLESS=$(HEADLESS)$(RESET)\n"
	@bash $(SCRIPT_DIR)/run_web.sh -e $(ENV) -b $(BROWSER) -H $(HEADLESS) $(if $(TAGS),-t $(TAGS))

.PHONY: test-web-all-browsers
test-web-all-browsers: ## Test — Run Web tests on all browsers (chromium, firefox, webkit)
	@printf "$(CYAN)▶ Web Tests — All Browsers — ENV=$(ENV)$(RESET)\n"
	@bash $(SCRIPT_DIR)/run_web.sh -e $(ENV) -b all -H $(HEADLESS)

.PHONY: test-mobile
test-mobile: ## Test — Run Mobile tests (ENV, PLATFORM, DEVICE, SUITE)
	@printf "$(CYAN)▶ Mobile Tests — ENV=$(ENV) PLATFORM=$(PLATFORM) DEVICE=$(DEVICE)$(RESET)\n"
	@bash $(SCRIPT_DIR)/run_mobile.sh -e $(ENV) -p $(PLATFORM) \
	  $(if $(DEVICE),-d $(DEVICE)) \
	  $(if $(SUITE),-s $(SUITE)) \
	  $(if $(TAGS),-t $(TAGS))

.PHONY: test-all
test-all: test-api test-web ## Test — Run API + Web tests (Mobile tidak include karena butuh device)
	@printf "$(GREEN)✅ All VM-based tests done$(RESET)\n"

.PHONY: test-full
test-full: test-api test-web test-mobile ## Test — Run ALL tests (API + Web + Mobile)
	@printf "$(GREEN)✅ Full suite done$(RESET)\n"

.PHONY: merge-reports
merge-reports: ## Test — Merge semua XML output menjadi satu report
	@printf "$(CYAN)▶ Merging reports...$(RESET)\n"
	@mkdir -p $(RESULTS_DIR)/merged
	@rebot \
	  --outputdir $(RESULTS_DIR)/merged \
	  --output output.xml \
	  --log log.html \
	  --report report.html \
	  --name "Indodax Full Suite — $(ENV)" \
	  $$(find $(RESULTS_DIR) -name "output*.xml" ! -path "*/merged/*" | tr '\n' ' ')
	@printf "$(GREEN)✅ Merged: $(RESULTS_DIR)/merged/report.html$(RESET)\n"

# ══════════════════════════════════════════════════════════════════
# DOCKER TARGETS
# ══════════════════════════════════════════════════════════════════

.PHONY: docker-build
docker-build: ## Docker — Build test runner image
	@printf "$(CYAN)▶ Building Docker image...$(RESET)\n"
	docker compose -f $(COMPOSE_FILE) build

.PHONY: docker-api
docker-api: ## Docker — Run API tests inside Docker container
	@printf "$(CYAN)▶ API Tests (Docker) — ENV=$(ENV)$(RESET)\n"
	docker compose -f $(COMPOSE_FILE) run --rm api-all

.PHONY: docker-api-public
docker-api-public: ## Docker — Run Public API tests inside Docker
	docker compose -f $(COMPOSE_FILE) run --rm api-public

.PHONY: docker-api-private
docker-api-private: ## Docker — Run Private API tests inside Docker
	docker compose -f $(COMPOSE_FILE) run --rm api-private

.PHONY: docker-web
docker-web: ## Docker — Run Web tests inside Docker container
	@printf "$(CYAN)▶ Web Tests (Docker) — BROWSER=$(BROWSER)$(RESET)\n"
	BROWSER=$(BROWSER) HEADLESS=$(HEADLESS) \
	  docker compose -f $(COMPOSE_FILE) run --rm web-tests

.PHONY: docker-down
docker-down: ## Docker — Stop and remove all containers
	docker compose -f $(COMPOSE_FILE) down

# ══════════════════════════════════════════════════════════════════
# SETUP & UTILITY
# ══════════════════════════════════════════════════════════════════

.PHONY: install
install: ## Utility — Install Python dependencies
	pip install -r requirements.txt

.PHONY: install-browsers
install-browsers: ## Utility — Install all Playwright browsers
	rfbrowser init chromium
	rfbrowser init firefox
	rfbrowser init webkit

.PHONY: setup-device-farm
setup-device-farm: ## Utility — Setup Mac as mobile device farm (Appium + drivers)
	@bash $(SCRIPT_DIR)/setup_device_farm.sh

.PHONY: setup-device-farm-ios
setup-device-farm-ios: ## Utility — Setup device farm with iOS (XCUITest) support
	@bash $(SCRIPT_DIR)/setup_device_farm.sh --ios

.PHONY: check-devices
check-devices: ## Utility — Show connected Android devices
	@printf "$(CYAN)Connected Android devices:$(RESET)\n"
	@adb devices

.PHONY: check-appium
check-appium: ## Utility — Check Appium server status
	@curl -s http://127.0.0.1:4723/status | python3 -m json.tool || \
	  printf "$(YELLOW)⚠️  Appium not running$(RESET)\n"

.PHONY: open-report
open-report: ## Utility — Open latest merged report in browser
	@open $(RESULTS_DIR)/merged/report.html 2>/dev/null || \
	  xdg-open $(RESULTS_DIR)/merged/report.html 2>/dev/null || \
	  printf "Cannot auto-open. File: $(RESULTS_DIR)/merged/report.html\n"

.PHONY: clean
clean: ## Utility — Remove all test results
	@printf "$(YELLOW)▶ Cleaning results...$(RESET)\n"
	@rm -rf $(RESULTS_DIR)/api $(RESULTS_DIR)/web $(RESULTS_DIR)/mobile $(RESULTS_DIR)/merged
	@printf "$(GREEN)✅ Cleaned$(RESET)\n"

.PHONY: clean-all
clean-all: clean ## Utility — Remove results + Docker images
	@printf "$(YELLOW)▶ Removing Docker image...$(RESET)\n"
	@docker rmi indodax-rf-runner:latest 2>/dev/null || true
	@printf "$(GREEN)✅ Done$(RESET)\n"
