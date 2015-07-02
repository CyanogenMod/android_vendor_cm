include $(MAKEFILE_FOR_VALUE)

value-from-makefile-%:
	@echo $($*)
