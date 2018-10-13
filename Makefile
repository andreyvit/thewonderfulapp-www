.PHONY: help
.PHONY: reconfigure
.PHONY: deploy
.PHONY: logs

# -- configuration -------------------------------------------------------------
server=h2.tarantsov.com

# ------------------------------------------------------------------------------
help:
	@echo "make initial           deploy & reconfigure"
	@echo "make reconfigure       reconfigure server using files under _deploy/"
	@echo "make deploy            build & deploy the production server"
	@echo "make logs              follow the logs of the production server"


# -- server deployment ----------------------------------------------------------

initial: reconfigure deploy

reconfigure:
	scp _deploy/wonderfulapp-www.sh "$(server):~/"
	ssh $(server) 'bash ~/wonderfulapp-www.sh --reconfigure'

deploy:
	cd site; hugo
	rsync -avz --delete site/public/ "$(server):~/wonderfulapp-www/"
	scp _deploy/wonderfulapp-www.sh '$(server):~/'
	ssh $(server) 'bash ~/wonderfulapp-www.sh --deploy'
