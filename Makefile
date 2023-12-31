FBC = /usr/bin/fbc
FBFLAGS= -O 2 -w all -i ./inc
RM = rm

all: build

build:
	$(FBC) $(FBFLAGS) examples/AddExample.bas src/BaseXClient.bas src/md5.bas
	$(FBC) $(FBFLAGS) examples/Example.bas src/BaseXClient.bas src/md5.bas
	$(FBC) $(FBFLAGS) examples/ExampleCreate.bas src/BaseXClient.bas src/md5.bas
	$(FBC) $(FBFLAGS) examples/QueryBindExample.bas src/BaseXClient.bas src/md5.bas
	$(FBC) $(FBFLAGS) examples/QueryExample.bas src/BaseXClient.bas src/md5.bas

clean:
	$(RM) examples/AddExample examples/Example examples/ExampleCreate
	$(RM) examples/QueryBindExample examples/QueryExample

.PHONY: all build clean

