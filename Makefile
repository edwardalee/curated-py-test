.PHONY: help format clean update

# Default target - show help message
help:
	@echo "Lingua Franca Curated Python - Available Make Targets:"
	@echo ""
	@echo "  make help           - Display this help message (default)"
	@echo "  make format         - Format all .lf files in the repository using lff"
	@echo "  make clean          - Remove build artifacts (build, include, bin, src-gen, fed-gen)"
	@echo "                        from all directories containing a 'src' subdirectory"
	@echo "  make update         - Update the context files from original repositories"
	@echo ""

# Format all .lf files in the repository using lff
format:
	@echo "Formatting all .lf files..."
	@find . -name "*.lf" -type f | while read file; do \
		echo "  ===============Formatting $$file"; \
		lff "$$file"; \
	done
	@echo "Formatting complete."

# Clean build artifacts from directories containing a src subdirectory
clean:
	@echo "Cleaning build artifacts..."
	@echo "  Cleaning top-level directory"
	@for dir in build include bin src-gen fed-gen; do \
		if [ -d "$$dir" ]; then \
			echo "    Removing $$dir"; \
			rm -rf "$$dir"; \
		fi \
	done
	@find . -type d -name "src" | while read srcdir; do \
		parentdir=$$(dirname "$$srcdir"); \
		if [ "$$parentdir" != "." ]; then \
			echo "  Cleaning directory: $$parentdir"; \
			for dir in build include bin src-gen fed-gen; do \
				if [ -d "$$parentdir/$$dir" ]; then \
					echo "    Removing $$parentdir/$$dir"; \
					rm -rf "$$parentdir/$$dir"; \
				fi \
			done \
		fi \
	done
	@echo "Cleaning complete."

# Update context by cloning lingua-franca and copying test/C directory
update:
	@echo "======= Updating context from lingua-franca repository..."
	@./scripts/clone_and_copy_subdir.sh https://github.com/lf-lang/lingua-franca.git test/Python context/tests
	@echo "======= Updating context from playground-lingua-franca repository..."
	@./scripts/clone_and_copy_subdir.sh https://github.com/lf-lang/playground-lingua-franca.git examples/Python context/examples
# lf-demo repo currently contains only C examples, so we don't update it
#	@echo "======= Updating context from lf-demos repository..."
#	@./scripts/clone_and_copy_subdir.sh https://github.com/lf-lang/lf-demos.git . context/demos
	@echo "======= Removing directories containing LFS files..."
	@./scripts/remove_lfs_dirs.sh
	@echo "Context update complete."
