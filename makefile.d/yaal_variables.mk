# Try to locate yaal
YAAL ?= $(shell yaal --base-path 2>/dev/null)
NO_YAAL ?= $(if $(YAAL),,yaal_not_found)

# include yaal specific variables
-include $(YAAL)/yaal_variables.mk