ORG_SOURCES := $(wildcard _org/*.org)
POSTS_FROM_ORG := $(patsubst _org/%.org,_posts/%.markdown,$(ORG_SOURCES))

.PHONY: org clean-org

org: $(POSTS_FROM_ORG)

_posts/%.markdown: _org/%.org bin/org-export.el
	bin/org-export.sh $< $@

clean-org:
	rm -f $(POSTS_FROM_ORG)
