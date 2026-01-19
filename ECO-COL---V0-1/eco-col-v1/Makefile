.PHONY: all build test clean help

all: build

help:
	@echo "ECO-COL V1 - Comandos disponibles:"
	@echo "  make build    - Compilar proyecto"
	@echo "  make test     - Ejecutar tests"
	@echo "  make clean    - Limpiar archivos"
	@echo "  make help     - Esta ayuda"

build:
	@echo "Compilando proyecto..."
	@cargo build --release --workspace

test:
	@echo "Ejecutando tests..."
	@cargo test --workspace

clean:
	@echo "Limpiando..."
	@cargo clean
	@rm -rf data/*.db data/*.db-shm data/*.db-wal

dev-acquisition:
	@echo "Iniciando nodo de adquisición..."
	@cd apps/acquisition-node && npm run dev

dev-reading:
	@echo "Iniciando nodo de lectura..."
	@cd apps/reading-node && npm run dev
