YAAL ?= $(shell yaal --base-path 2>/dev/null)
NO_YAAL ?= $(if $(YAAL),,no_yaal_found)
YAAL_NO_INIT ?= $(NO_YAAL)

#If there is something to do include core/init
# FIXME: use automated dependency files
override SRC += $(if $(YAAL_NO_INIT),,yaal/core/init.cpp)

