# require variables
override require = $(foreach var,$(1),$(if $($(var)),,$(error $(if $(2),$(2),Required variable $(var) not defined))))
# $(call require,VAR1 VAR2)
# $(call require,SRC,SRC is required for anything to be build)

# find file from path libdir/version:libdir:.
override find_file = $(firstword $(foreach path,$(YAAMAKE)/$(1) $(YAAMAKE)/../$(1) $(1),$(wildcard $(realpath $(path)))))
