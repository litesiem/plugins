FLOG_OUT:="log/flog-$$(date '+%Y%m%d%H%M%S').log"

test:
	echo "$(FLOG_OUT)"

flog:
	flog -f json -o $(FLOG_OUT) -t log -d 1s -l

probe:
	flog -f json -o $(FLOG_OUT) -t log -n 1

clean:
	rm -f log/flog-*.log
