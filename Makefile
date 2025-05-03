NAME = inception

# Colors
GREEN = \033[0;32m
NC = \033[0m

all: setup build

setup:
	@echo "$(GREEN)Creating necessary directories...$(NC)"
	@mkdir -p /home/$(USER)/data/wordpress
	@mkdir -p /home/$(USER)/data/mariadb
	@echo "$(GREEN)Updating /etc/hosts for domain resolution...$(NC)"
	@if ! grep -q "$(USER).42.fr" /etc/hosts; then \
		echo "127.0.0.1 $(USER).42.fr" | sudo tee -a /etc/hosts; \
	fi

build:
	@echo "$(GREEN)Building Docker containers...$(NC)"
	@cd srcs && docker compose up --build -d

down:
	@echo "$(GREEN)Stopping Docker containers...$(NC)"
	@cd srcs && docker compose down

clean: down
	@echo "$(GREEN)Cleaning Docker resources...$(NC)"
	@docker system prune -a -f
	@echo "$(GREEN)Removing volumes...$(NC)"
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true

fclean: clean
	@echo "$(GREEN)Complete cleanup including data...$(NC)"
	@sudo rm -rf /home/$(USER)/data/wordpress/*
	@sudo rm -rf /home/$(USER)/data/mariadb/*

re: fclean all

.PHONY: all setup build down clean fclean re