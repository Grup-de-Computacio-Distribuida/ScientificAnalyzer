# Sample to search terms
# make INI=2010 END=2019 TERMS="machine learning" search

INI ?= "2010"
END ?= "2011"
TERMS ?= "machine learning"

.PHONY: build, clean, build-data_collector, clean-data_collector, build-data-visualizer, clean-data-visualizer, search


# Build and clean docker images

build: build-data_collector build-data-visualizer
clean: clean-data_collector clean-data-visualizer

build-data_collector:
	@echo "Building data collector"
	docker build -t data_collector -f data_collector.Dockerfile .

clean-data_collector:
	@echo "Cleaning data collector"
	docker rmi data_collector

build-data-visualizer:
	@echo "Building data visualizer"
	docker build -t data_visualizer -f data_visualizer.Dockerfile .

clean-data-visualizer:
	@echo "Cleaning data visualizer"
	docker rmi data_visualizer

# Run docker containers to search and visualize data

DATA_DIR ?= /root/data
BACKUP_DIR ?= /root/data/backup
TIMESTAMP := $(shell date +%s)
TAG ?= ${TIMESTAMP}

search:
	@echo "Generating a folder with the timestamp: $(TIMESTAMP)"
	mkdir -p "$(DATA_DIR)/$(TAG)"
	@echo "Running scientific data collector"
	docker run --name "$(TAG)-serach" -d --rm -it \
                -v "$(DATA_DIR)/$(TAG)":/app/tmp_data \
                data_collector python3 scientific_analyzer.py -c $(INI) $(END) $(TERMS)

parse:
	@echo "Running scientific data parser"
	mkdir -p "$(BACKUP_DIR)/$(TAG)"
	mkdir -p "$(DATA_DIR)/$(TAG)/data"
	docker run --name "$(TAG)-parse" -d --rm -it \
				-v "$(DATA_DIR)/$(TAG)":/app/tmp_data \
				-v "$(BACKUP_DIR)":/app/backup_data \
				-v "$(DATA_DIR)/$(TAG)/data":/app/DataVisualizer/data \
				data_collector python3 scientific_analyzer.py -l


PORT := 3838
define check_port:
	@if nc -z localhost $(PORT); then \
		echo "$(PORT) is in use"; \
		PORT=$$(($(PORT) + 1)); \
		$(eval $(call check_port)); \
	fi
endef

visualize:
		@echo "Running scientific data visualizer"
		$(eval $(call check_port))
		@echo "Using port: $(PORT)"
		docker run --name "$(TAG)-visualize"  -d --rm -it \
				-v ./DataVisualizer:/srv/shiny-server/DataVisualizer \
				-v $(DATA_DIR)/$(TAG)/data:/srv/shiny-server/DataVisualizer/data \
				-p $(PORT):3838 \
				data_visualizer

# Create a cron job to run update.sh every sunday at 00:00
install-cron:
	@echo "Installing cron job"
	@echo "0 0 * * 0 cd $(PWD) && /bin/bash ./update.sh >> $(PWD)/cron.log 2>&1" | crontab -
	@echo "Cron job installed. Log will be written to $(PWD)/cron.log"

