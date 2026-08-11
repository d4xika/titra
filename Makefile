REGISTRY := registry.d4xika.com

FRONTEND_IMAGE := registry.d4xika.com/titra-frontend:latest
BACKEND_IMAGE := registry.d4xika.com/titra-backend:latest

.PHONY: deploy

deploy:
	docker buildx build --platform linux/amd64 -t $(FRONTEND_IMAGE) --push ./frontend
	docker buildx build --platform linux/amd64 -t $(BACKEND_IMAGE) --push ./backend

