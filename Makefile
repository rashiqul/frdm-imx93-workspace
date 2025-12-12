.PHONY: help clean configure build run-a55 flash-m33 coverage run-docker docker-shell package uart run-a55-uart scp-a55

# Check if running inside Docker
INSIDE_DOCKER := $(shell [ -f /.dockerenv ] && echo 1 || echo 0)

help:
	@echo "========================================================================"
	@echo "FRDM-i.MX93 Build System"
	@echo "========================================================================"
	@echo ""
	@echo "Primary Workflow (Docker - Recommended):"
	@echo "  make run-docker                       # Launch Docker shell (type 'exit' to quit)"
	@echo "  make configure TARGET=native|a55|m33  # Configure build (auto-uses Docker)"
	@echo "  make build     TARGET=native|a55|m33  # Build target (auto-uses Docker)"
	@echo ""
	@echo "Inside Docker shell (after 'make run-docker'):"
	@echo "  make configure TARGET=a55             # Configure directly"
	@echo "  make build TARGET=a55                 # Build directly"
	@echo "  exit                                  # Leave Docker environment"
	@echo ""
	@echo "A55 Deployment:"
	@echo "  make run-a55                          # Deploy to imx93.local (default)"
	@echo "  make run-a55 HOST=<ip>                # Deploy to specific host"
	@echo "  make run-a55 USER=<user>              # As specific user"
	@echo "  make scp-a55 HOST=<ip>                # Build + SCP deploy"
	@echo ""
	@echo "Other Commands:"
	@echo "  make clean                            # Clean build artifacts"
	@echo "  make flash-m33                        # Flash M33 firmware"
	@echo "  make uart DEVICE=/dev/ttyACM0         # Open UART console"
	@echo ""
	@echo "Advanced (Local builds without Docker):"
	@echo "  make local-configure TARGET=...       # Configure locally"
	@echo "  make local-build TARGET=...           # Build locally"
	@echo ""
	@echo "Note: All commands automatically use Docker if available."
	@echo "      Install Docker: sudo apt install docker.io"
	@echo "========================================================================"

clean:
	rm -rf build/ \
		**/.pytest_cache **/__pycache__ \
		python/.venv \
		CMakeUserPresets.json \
		compile_commands.json

# Check if Docker is available
DOCKER_CMD := $(shell command -v docker 2>/dev/null)
DOCKER_COMPOSE_CMD := $(shell command -v docker-compose 2>/dev/null || (docker compose version >/dev/null 2>&1 && echo "docker compose"))

# Main configure target - auto-detects Docker
configure:
ifeq ($(INSIDE_DOCKER),1)
	@echo "🐳 Running configure inside Docker..."
	@bash scripts/configure.sh
else ifneq ($(DOCKER_CMD),)
	@echo "🐳 Running configure in Docker container..."
	@$(MAKE) _docker-run CMD="make local-configure TARGET=$(TARGET)"
else
	@echo "⚠️  Docker not found, running locally..."
	@bash scripts/configure.sh
endif

# Main build target - auto-detects Docker
build:
ifeq ($(INSIDE_DOCKER),1)
	@echo "🐳 Building inside Docker..."
	@$(MAKE) local-build TARGET=$(TARGET)
else ifneq ($(DOCKER_CMD),)
	@echo "🐳 Building in Docker container..."
	@$(MAKE) _docker-run CMD="make local-build TARGET=$(TARGET)"
else
	@echo "⚠️  Docker not found, running locally..."
	@$(MAKE) local-build TARGET=$(TARGET)
endif

# Local configure (actual implementation)
local-configure:
	bash scripts/configure.sh

# Local build (actual implementation)
local-build:
	@TARGET=$${TARGET:-a55}; \
	if [ ! -d "build/$${TARGET}" ]; then \
		echo "Error: build/$${TARGET} not found. Run 'make configure TARGET=$${TARGET}' first."; \
		exit 1; \
	fi; \
	POETRY_VENV="python/.venv"; \
	if [ -d "$${POETRY_VENV}" ]; then \
		export PATH="$${POETRY_VENV}/bin:$${PATH}"; \
	fi; \
	cmake --build "build/$${TARGET}" --parallel && \
	echo "Built $${TARGET} (artifacts in build/$${TARGET})"

run-a55:
	@if [ -z "$${HOST}" ]; then \
		echo "Using default HOST=imx93.local (override with HOST=<ip/host>)"; \
	fi
	DEPLOY=$${DEPLOY:-scp} HOST=$${HOST:-imx93.local} USER=$${USER:-root} bash scripts/run_a55.sh

flash-m33:
	bash scripts/flash_m33.sh

# ============================================================================
# Docker Environment
# ============================================================================

# Start Docker and launch interactive shell
run-docker:
	@echo "🐳 Launching Docker build environment..."
	@echo "   (Building image if needed - first time will take a few minutes)"
	@echo ""
	@if [ -z "$(DOCKER_CMD)" ]; then \
		echo "❌ Docker not found! Install with: sudo apt install docker.io"; \
		exit 1; \
	fi
	@if [ -n "$(DOCKER_COMPOSE_CMD)" ]; then \
		if echo "$(DOCKER_COMPOSE_CMD)" | grep -q "docker compose"; then \
			UID=$(shell id -u) GID=$(shell id -g) docker compose run --rm imx93-dev bash; \
		else \
			UID=$(shell id -u) GID=$(shell id -g) docker-compose run --rm imx93-dev bash; \
		fi; \
	else \
		echo "❌ Docker Compose not found!"; \
		echo "Install: sudo apt install docker-compose-plugin"; \
		exit 1; \
	fi
	@echo ""
	@echo "✅ Exited Docker environment"

# Alias for consistency
shell: run-docker

# Internal: Run command in Docker
_docker-run:
	@if [ -n "$(DOCKER_COMPOSE_CMD)" ]; then \
		if echo "$(DOCKER_COMPOSE_CMD)" | grep -q "docker compose"; then \
			docker compose run --rm imx93-dev bash -c "$(CMD)"; \
		else \
			docker-compose run --rm imx93-dev bash -c "$(CMD)"; \
		fi; \
	else \
		echo "❌ Docker Compose not found!"; \
		exit 1; \
	fi

# Stop Docker container
stop-docker:
	@echo "🛑 Stopping Docker container..."
	@if [ -n "$(DOCKER_COMPOSE_CMD)" ]; then \
		if echo "$(DOCKER_COMPOSE_CMD)" | grep -q "docker compose"; then \
			docker compose down; \
		else \
			docker-compose down; \
		fi; \
	fi

package:
	@echo "Creating Conan package..."
	@if [ -d "python/.venv" ]; then \
		. python/.venv/bin/activate && conan create . --build=missing; \
	else \
		echo "ERROR: Poetry venv not found. Run 'make configure' first."; \
		exit 1; \
	fi
	@echo "Package created and tested successfully!"

coverage:
	@echo "TODO: implement gcovr + pytest coverage; see README."

uart:
	bash scripts/serial_connect.sh "${DEVICE}" "${BAUD}"

run-a55-uart:
	@echo "Building A55 target..."
	@$(MAKE) configure TARGET=a55
	@$(MAKE) build TARGET=a55
	@echo ""
	bash scripts/a55_uart_transfer.sh "${DEVICE}" "${BAUD}"

scp-a55:
	@echo "Building A55 target..."
	@$(MAKE) configure TARGET=a55
	@$(MAKE) build TARGET=a55
	@echo ""
	bash scripts/a55_scp_transfer.sh "${HOST}"
