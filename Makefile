.PHONY: help format clean update update-context update-lfdocs

# Directories to exclude from context (e.g., those containing LFS or large files)
EXCLUDE = audio-classification

# Default target - show help message
help:
	@echo "Lingua Franca Curated Python - Available Make Targets:"
	@echo ""
	@echo "  make help           - Display this help message (default)"
	@echo "  make format         - Format all .lf files in the repository using lff"
	@echo "  make clean          - Remove build artifacts (build, include, bin, src-gen, fed-gen)"
	@echo "                        from all directories containing a 'src' subdirectory"
	@echo "  make update         - Run all update targets (context and lfdocs)"
	@echo "  make update-context - Update the context files from original repositories"
	@echo "  make update-lfdocs  - Update the lfdocs from lf-lang.github.io repository"
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

# Update context by cloning lingua-franca and copying test/Python directory
update-context:
	@echo "======= Updating context from lingua-franca repository..."
	@./scripts/clone_and_copy_subdir.sh https://github.com/lf-lang/lingua-franca.git test/Python context/tests
	@echo "======= Updating context from playground-lingua-franca repository..."
	@./scripts/clone_and_copy_subdir.sh https://github.com/lf-lang/playground-lingua-franca.git examples/Python context/examples
# lf-demo repo currently contains only C examples, so we don't update it
#	@echo "======= Updating context from lf-demos repository..."
#	@./scripts/clone_and_copy_subdir.sh https://github.com/lf-lang/lf-demos.git . context/demos
	@echo "======= Removing excluded directories..."
	@for name in $(EXCLUDE); do \
		find context -type d -name "$$name" | while read dir; do \
			echo "  Removing $$dir"; \
			rm -rf "$$dir"; \
		done \
	done
	@echo "Context update complete."

# Update lfdocs by building static C docs from lf-lang.github.io
update-lfdocs:
	@echo "======= Updating lfdocs from lf-lang.github.io repository..."
	@./scripts/build_lf_docs.sh
	@echo "lfdocs update complete."

# Update all: context and lfdocs
update: update-context update-lfdocs
	@echo "All updates complete."
