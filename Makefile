#TODO

#-------------------------------------------------------------------------------

GIT_ROOT=.
GIT_EMAIL=mh4869203@gmail.com
GIT_NAME=cskd8

GO_ROOT=./go
BINARY_NAME= isulibrary

SERVICE_NAME= isulibrary-go

NGINX_LOG=/tmp/access.log

KATARIBE_CFG=/etc/kataribe.toml

DB_HOST=localhost
DB_PORT=3306
DB_USER=isucon
DB_PASS=isucon
DB_NAME= isulibrary

SLOW_LOG=/tmp/slow-query.log

SLACKCAT_CNL=isucon

PPROF_TIME=60

LOGS_DIR=/etc/logs

#-------------------------------------------------------------------------------

PPROF=go tool pprof

KATARIBE=kataribe -f $(KATARIBE_CFG)

MYSQL=sudo mysql -h$(DB_HOST) -P$(DB_PORT) -u$(DB_USER) -p$(DB_PASS) $(DB_NAME)

SLACKCAT=slackcat --channel $(SLACKCAT_CNL)

WHEN:=$(shell date +%H:%M:%S)

#-------------------------------------------------------------------------------

#TODO

#-------------------------------------------------------------------------------

.PHONY: prebench-dev
prebench-dev: pull build restart slow-on #TODO

.PHONY: prebench-prod
prebench-prod: pull build restart slow-off #TODO

.PHONY: pull
pull:
	cd $(GIT_ROOT) && \
		git pull

.PHONY: build
build:
	cd $(GO_ROOT) && \
	go build -o $(BINARY_NAME) .

.PHONY: slow-on
slow-on:
	$(MYSQL) -e "set global slow_query_log_file = '$(SLOW_LOG)'; set global long_query_time = 0; set global slow_query_log = ON;"

.PHONY: slow-off
slow-off:
	$(MYSQL) -e "set global slow_query_log = OFF;"

.PHONY: restart
restart: restart-nginx restart-mysql restart-app

.PHONY: restart-app
restart-app:
	sudo systemctl restart $(SERVICE_NAME) #TODO

.PHONY: restart-nginx
restart-nginx:
	@if [ -f $(NGINX_LOG) ]; then \
		sudo mkdir -p $(LOGS_DIR)/$(WHEN) ; \
		sudo mv -f $(NGINX_LOG) $(LOGS_DIR)/$(WHEN)/ ; \
	fi
	sudo systemctl restart nginx

.PHONY: restart-mysql
restart-mysql:
	@if [ -f $(SLOW_LOG) ]; then \
		sudo mkdir -p $(LOGS_DIR)/$(WHEN) ; \
		sudo mv -f $(SLOW_LOG) $(LOGS_DIR)/$(WHEN)/ ; \
	fi
	sudo systemctl restart mysql

#-------------------------------------------------------------------------------

.PHONY: analyze
analyze: kataribe slow

.PHONY: pprof
pprof:
	$(PPROF) -png -output pprof.png http://localhost:6060/debug/pprof/profile?seconds=$(PPROF_TIME) #TODO
	$(SLACKCAT) -n pprof.png pprof.png

.PHONY: kataribe
kataribe:
	sudo cat $(NGINX_LOG) | $(KATARIBE) | $(SLACKCAT) --tee

.PHONY: slow
slow:
	sudo cat $(SLOW_LOG) | pt-query-digest | $(SLACKCAT) --tee

#-------------------------------------------------------------------------------

.PHONY: install-tools
install-tools: install-git install-unzip install-kataribe install-myprofiler install-pt install-dstat install-graphviz install-slackcat

.PHONY: install-git
install-git:
	sudo apt install -y git # TODO
	git config --global user.email "$(GIT_EMAIL)"
	git config --global user.name "$(GIT_NAME)"

.PHONY: install-unzip
install-unzip:
	sudo apt install -y unzip # TODO

.PHONY: install-kataribe
install-kataribe:
	wget https://github.com/matsuu/kataribe/releases/download/v0.4.2/kataribe-v0.4.2_linux_amd64.zip -O kataribe.zip
	mkdir -p tmp_kataribe
	unzip -o kataribe.zip -d tmp_kataribe
	rm -f kataribe.zip
	sudo cp tmp_kataribe/kataribe /usr/local/bin/
	rm -rf tmp_kataribe
	sudo chmod +x /usr/local/bin/kataribe
	kataribe -generate
	sudo cp kataribe.toml $(KATARIBE_CFG)
	rm -f kataribe.toml

.PHONY: install-myprofiler
install-myprofiler:
	wget https://github.com/KLab/myprofiler/releases/latest/download/myprofiler.linux_amd64.tar.gz -O myprofiler.tar.gz
	tar xf myprofiler.tar.gz
	rm -f myprofiler.tar.gz
	sudo cp myprofiler /usr/local/bin/
	rm -f myprofiler
	sudo chmod +x /usr/local/bin/myprofiler

.PHONY: install-pt
install-pt:
	sudo apt install -y percona-toolkit # TODO

.PHONY: install-dstat
install-dstat:
	sudo apt install -y dstat # TODO

.PHONY: install-graphviz
install-graphviz:
	sudo apt install -y graphviz # TODO

.PHONY: install-slackcat
install-slackcat:
	wget https://github.com/bcicen/slackcat/releases/download/1.7.3/slackcat-1.7.3-linux-amd64 -O slackcat
	sudo cp slackcat /usr/local/bin/
	rm -f slackcat
	sudo chmod +x /usr/local/bin/slackcat
	slackcat --configure
