# Copyright 2017-2018 Joseph Lorimer <joseph@lorimer.me>
#
# Permission to use, copy, modify, and distribute this software for any purpose
# with or without fee is hereby granted, provided that the above copyright
# notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

export PYTHONPATH=.
PYTHON3_VERSION=$(shell python3 -c "import sys;t='{v[0]}.{v[1]}'.format(v=list(sys.version_info[:2]));sys.stdout.write(t)")
VERSION=`cat _version.py | grep __version__ | sed "s/.*'\(.*\)'.*/\1/"`
PROJECT_SHORT=chinese
PROJECT_LONG=chinese-support-redux
PYTEST=pytest

all: test prep pack clean

# pipenv seems to be dead...
venv/bin/activate: requirements-to-freeze.txt
	rm -rf virtual_env/
	python3 -m venv virtual_env
	. virtual_env/bin/activate ;\
	pip install --upgrade pip ;\
	pip install -Ur requirements-to-freeze.txt ;\
	pip freeze | sort > requirements.txt
	touch virtual_env/bin/activate  # update so it's as new as requirements-to-freeze.txt

lib: venv/bin/activate
	rm -fr chinese/lib
	mkdir chinese/lib
	cp -R virtual_env/lib/python$(PYTHON3_VERSION)/site-packages/. chinese/lib/

test:
	"$(PYTEST)" --cov="$(PROJECT_SHORT)" tests -v

prep:
	rm -f $(PROJECT_LONG)-v*.zip
	find . -name '*.pyc' -type f -delete
	find . -name '*~' -type f -delete
	find . -name '.python-version' -type f -delete
	find . -name .mypy_cache -type d -exec rm -rf {} +
	find . -name .ropeproject -type d -exec rm -rf {} +
	find . -name __pycache__ -type d -exec rm -rf {} +
	mv "$(PROJECT_SHORT)/meta.json" .
	mv "$(PROJECT_SHORT)/config_saved.json" .
	cp LICENSE "$(PROJECT_SHORT)/LICENSE.txt"
	git checkout chinese/data/db/chinese.db

pack:
	(cd "$(PROJECT_SHORT)" && zip -r ../$(PROJECT_LONG)-v$(VERSION).zip *)
	./convert-readme.py

clean:
	rm "$(PROJECT_SHORT)/LICENSE.txt"
	mv meta.json "$(PROJECT_SHORT)/meta.json"
	mv config_saved.json "$(PROJECT_SHORT)/config_saved.json"
