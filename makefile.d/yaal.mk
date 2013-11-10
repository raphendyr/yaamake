# If there is something to do include core/init
override SRC += $(if $(YAAL_NO_INIT),,yaal/core/init.cpp)

