.PHONY: help clean configure build run-a55 flash-m33 coverage run-docker docker-shell package uart run-a55-uart scp-a55

help:
	@echo "Targets:"
	@echo "  make configure TARGET=native|a55|m33  # deps + CMake config (default: a55)"
	@echo "  make build     TARGET=native|a55|m33  # compile and link (default: a55)"
	@echo "  make package                          # create and test Conan package"
	@echo ""
	@echo "A55 Deployment (Network - Primary Method):"
	@echo "  make run-a55                          # deploy to imx93.local (default)"
	@echo "  make run-a55 HOST=<ip>                # deploy to specific host"
	@echo "  make run-a55 USER=<user>              # as specific user (default: rashiqul)"
	@echo "  make run-a55 DEPLOY=rsync             # use rsync instead of scp"
	@echo "  make scp-a55 HOST=<ip>                # build + scp deploy"
	@echo ""
	@echo "UART Console & Manual Transfer:"
	@echo "  make uart DEVICE=/dev/ttyACM0         # open UART console"
	@echo "  make run-a55-uart DEVICE=/dev/ttyACM0 # show UART transfer options"
	@echo "  (Note: UART is for console access, use SSH/SCP for file transfer)"
	@echo ""
	@echo "Docker Build Environment:"
	@echo "  make docker-build                     # build Docker image"
	@echo "  make docker-configure TARGET=...      # configure inside container"
	@echo "  make docker-compile TARGET=...        # build inside container"
	@echo "  make docker-shell                     # interactive container shell"
	@echo "  make docker-build-all                 # build all targets in Docker"
	@echo ""
	@echo "M33 & Other:"
	@echo "  make flash-m33                        # flash M33 (edit script)"
	@echo "  make coverage                         # TODO: gcovr/pytest"
	@echo "  make clean                            # rm build and caches"

clean:
	rm -rf build/ \
		**/.pytest_cache **/__pycache__ \
		python/.venv \
		CMakeUserPresets.json \
		compile_commands.json

configure:
	bash scripts/configure.sh

build:
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

# Docker build targets
docker-build:
	@echo "Building Docker image..."
	@if command -v docker-compose >/dev/null 2>&1; then \
		docker-compose build; \
	elif command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then \
		docker compose build; \
	else \
		echo "ERROR: Docker or Docker Compose not found!"; \
		echo "Please install Docker: https://docs.docker.com/get-docker/"; \
		exit 1; \
	fi

docker-configure:
	@echo "Configuring ${TARGET:-a55} inside Docker container..."
	docker-compose run --rm imx93-dev make configure TARGET=${TARGET:-a55}

docker-compile:
	@echo "Building ${TARGET:-a55} inside Docker container..."
	docker-compose run --rm imx93-dev make build TARGET=${TARGET:-a55}

docker-shell:
	@echo "Opening interactive shell in Docker container..."
	docker-compose run --rm imx93-dev bash

docker-build-all:
	@echo "Building all targets in Docker container..."
	@echo "=== Building native ==="
	docker-compose run --rm imx93-dev bash -c "make configure TARGET=native && make build TARGET=native"
	@echo ""
	@echo "=== Building A55 ==="
	docker-compose run --rm imx93-dev bash -c "make configure TARGET=a55 && make build TARGET=a55"
	@echo ""
	@echo "=== Building M33 ==="
	docker-compose run --rm imx93-dev bash -c "make configure TARGET=m33 && make build TARGET=m33"
	@echo ""
	@echo "✅ All targets built successfully in Docker!"

# Legacy aliases
run-docker: docker-build
	@echo "Docker image built. Use 'make docker-shell' for interactive shell."

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
