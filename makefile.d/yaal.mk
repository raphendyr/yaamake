#   Stage 1: Variables
ifeq ($(yaamake_stage),1)
# =======================


# Try to locate yaal
YAAL ?= $(shell yaal --base-path 2>/dev/null)
NO_YAAL ?= $(if $(YAAL),,yaal_not_found)

# include yaal specific variables
ifneq ($(YAAL),)
-include $(YAAL)/yaal_variables.mk
endif



#   Stage 2: targets
else ifeq ($(yaamake_stage),2)
# ============================


ifneq ($(YAAL),)
# include yaal specific targets
-include $(YAAL)/yaal_targets.mk
endif


# Stages end
endif
