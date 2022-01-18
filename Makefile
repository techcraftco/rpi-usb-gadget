all: $(shell find cue -type f -name '*.cue')
	cd cue && cue gen