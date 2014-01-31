# helper variables
null :=
space := $(null) $(null)


# require variables
override require = $(foreach var,$(1),$(if $($(var)),,$(error $(if $(2),$(2),Required variable $(var) not defined))))
# $(call require,VAR1 VAR2)
# $(call require,SRC,SRC is required for anything to be build)


# find file from path libdir/version:libdir:.
override find_file = $(firstword $(foreach path,$(YAAMAKE)/$(1) $(YAAMAKE)/../$(1) $(1),$(wildcard $(realpath $(path)))))


# path manipulation
#   drop all ./ in start of string
override drop_leading_cwd = $(if $(filter ./%,$(1)),$(call drop_leading_cwd,$(patsubst ./%,%,$(1))),$(1))
#   drop all ../ in start if string
override drop_leading_parent = $(if $(filter ../%,$(1)),$(call drop_leading_parent,$(patsubst ../%,%,$(1))),$(1))


# remove duplicates in list of words, while keeping the order
override remove_duplicates = $(if $(1),$(strip $(word 1,$(1)) $(call remove_duplicates,$(filter-out $(word 1,$(1)),$(1)))))
# contains duplicates
override contains_duplicates = $(if $(1),$(if $(filter $(strip $(word 1,$(1))),$(wordlist 2,$(words $(1)),$(1))),yes,$(call contains_duplicates,$(wordlist 2,$(words $(1)),$(1)))),)



# version compare
override version_compare = $(shell $(PYTHON) -c "_=lambda v:tuple(map(int,v.split('.')));print 'yes' if _('$(1)') $(2) _('$(3)') else ''")
