install-check: 
	mops add memory-region
ifeq (, $(shell which $(HOME)/bin/vessel))	
	rm installvessel.sh -f
	echo '#install vessel'>installvessel.sh
	echo cd $(HOME)/bin>>installvessel.sh
	echo wget https://github.com/dfinity/vessel/releases/download/v0.7.0/vessel-linux64 >> installvessel.sh
	echo mv vessel-linux64 vessel >>installvessel.sh
	echo chmod +x vessel>>installvessel.sh
	chmod +x installvessel.sh
	./installvessel.sh
	rm installvessel.sh -f
endif		