


docker.run:  docker.network docker.alertmanager docker.exporter docker.prometheus docker.grafana 

docker.network:
	docker network inspect dev-network >/dev/null 2>&1 || \
	docker network create -d bridge dev-network


docker.prometheus:
	docker run --rm -d \
		--name prometheus \
		--network dev-network \
		-p 9090:9090 \
		-v $(shell pwd)/config/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
		-v $(shell pwd)/config/prometheus/rules.yml:/etc/prometheus/rules.yml \
    prom/prometheus

docker.alertmanager:
	docker run --rm -d \
		--name alertmanager \
		--network dev-network \
		-p 9093:9093 \
		-v $(shell pwd)/config/alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
    prom/alertmanager	

docker.exporter:
	docker run --rm -d \
		--name node-exporter \
		--network dev-network \
		-p 9100:9100 \
    prom/node-exporter	

docker.grafana:
	docker run --rm -d \
		--name grafana \
		--network dev-network \
		-p 3000:3000 \
		-v $(shell pwd)/config/grafana/datasource.yml:/etc/grafana/provisioning/datasources/default.yml \
		-v $(shell pwd)/config/grafana/dashboards.yml:/etc/grafana/provisioning/dashboards/local.yml \
		-v $(shell pwd)/config/grafana/dashboard.json:/var/lib/grafana/dashboards/dashboard.json \
		-e "GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource" \
    grafana/grafana-oss



docker.stop: docker.stop.prometheus docker.stop.grafana docker.stop.exporter docker.stop.alertmanager

docker.stop.prometheus:
	docker stop prometheus

docker.stop.grafana:
	docker stop grafana

docker.stop.exporter:
	docker stop node-exporter

docker.stop.alertmanager:
	docker stop alertmanager