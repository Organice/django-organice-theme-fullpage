# Makefile for django Organice themes
#

# variables
SHELL = /bin/bash
REPO_FULLPAGE = https://raw.githubusercontent.com/alvarotrigo/fullPage.js/master
REPO_RIBBON = https://raw.githubusercontent.com/simonwhitaker/github-fork-ribbon-css/gh-pages

.PHONY: help assets bootstrap bumpver clean release setuptools

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  assets        to build all static assets (combined/minified CSS, JavaScript, etc.)"
	@echo "  bootstrap     to update Sass, Compass, UglifyJS, and bootstrap-sass on your (Ubuntu) system"
	@echo "  bumpver       to bump the version number, commit and tag for releasing"
	@echo "  clean         to remove build files and folders"
	@echo "  install       to install this project including its dependencies"
	@echo "  uninstall     to uninstall this package using pip"
	@echo "  release       to package a new release, and upload it to pypi.org"
	@echo "  setuptools    to install setuptools or repair a broken pip installation"
	@echo "  update        to pull all vendor assets from external resources"

assets: #bootstrap
	@echo "Building assets..."
	cd */static && compass clean && compass compile
	cd */static/js && \
	BOOTSTRAP_JS_DIR=$(shell find $(shell gem environment gemdir)/gems/ \
		-name bootstrap-sass-*)/vendor/assets/javascripts/bootstrap/ && \
	uglifyjs -o scripts.js \
		../../../../django-organice-theme/organice_theme/static/js/scripts.js \
		{jquery.easings.min,jquery.slimscroll.min,jquery.fullPage,fullpage_start}.js
#
# NOTE: to add Bootstrap modules: add \ at end of previous line and
# $$BOOTSTRAP_JS_DIR/{bootstrap_module_1,bootstrap_module_2,...}.js

bootstrap:
	@echo "Updating your system-wide bootstrap-sass installation... (may require your password)"
	gem list &> /dev/null || sudo apt-get install -y ruby
	yes | sudo gem uninstall sass compass bootstrap-sass
	sudo gem install compass bootstrap-sass --no-rdoc --no-ri
	@gem list
	@echo
	@echo "Updating uglify-js v2 for Bootstrap JavaScript minification... (may require your password)"
	npm list &> /dev/null || sudo apt-get install -y npm
	sudo npm uninstall -g uglify-js
	sudo npm install -g uglify-js

bumpver:
	@echo "Not implemented yet. Install pypi package instead: \`pip install bumpversion'"

clean:
	rm -rf build/ dist/ *.egg-info/ */static/.sass-cache

install: setuptools
	python setup.py install

uninstall:
	@PKG_NAME=$${PWD##*/} && pip freeze | sed 's/==.*$$//' | grep $$PKG_NAME &> /dev/null \
		&& pip uninstall -y $$PKG_NAME \
		|| echo "Package $$PKG_NAME not installed."

release: setuptools clean
	python setup.py sdist upload

setuptools:
	python -c 'import setuptools' || \
	curl -s -S https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py | python
	rm -f setuptools-*.zip

update:
	@echo "Pulling fullPage.js assets from GitHub ... (NOTE: jQuery is part of base theme)"
	cd */static/css && wget -nc -q $(REPO_FULLPAGE)/jquery.fullPage.css
	cd */static/js && wget -nc -q $(REPO_FULLPAGE)/jquery.fullPage.js \
		&& wget -nc -q $(REPO_FULLPAGE)/vendors/jquery.easings.min.js \
		&& wget -nc -q $(REPO_FULLPAGE)/vendors/jquery.slimscroll.min.js
	@echo "Pulling 'Fork me' ribbon assets from GitHub ..."
	cd */static/css \
		&& wget -nc -q $(REPO_RIBBON)/gh-fork-ribbon.css \
		&& wget -nc -q $(REPO_RIBBON)/gh-fork-ribbon.ie.css
