#   Stage: Variables
ifeq ($(yaamake_stage),v)
# =======================


# Try to locate yaal
YAAL ?= $(shell yaal --base-path 2>/dev/null)
NO_YAAL ?= $(if $(YAAL),,yaal_not_found)

# include yaal specific variables
ifneq ($(YAAL),)
-include $(YAAL)/yaal_variables.mk
endif



#   Stage: targets
else ifeq ($(yaamake_stage),t)
# ============================


ifneq ($(YAAL),)
# include yaal specific targets
OBJDIR := $(BUILDDIR)
-include $(YAAL)/yaal_targets.mk
OBJDIR :=
endif


# Stages end
endif
