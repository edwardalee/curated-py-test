# Curated-Py Template

The purpose of this repository is to serve as a template for new Lingua Franca (LF)
projects that use the Python target. The goal is to provide a large number of examples
and documentation specific to the Python target so as to guide AI assistants that are
using RAG (Retrieval Augmented Generation).

To use this, at the [curated-py homepage](https://github.com/lf-lang/curated-py),
select "Use this template" to create a new repository.

This repository contains the following:

* A `context` directory with many examples of Lingua Franca (LF) programs for the Python target.

* A `scripts` directory with utilities used to update the context.

* A `Makefile` for formatting LF files, cleaning build artifacts, and updating the context.

* A `src` directory with an [example LF program](src/README.md) to help users get started.

# Updating the Template Information

## Direct Update

Run the following to update context information from the original sources:

```
make update
```

Then commit the changes.

## Update from the Template Repo

If you have created your own repository from this template, and you later wish to update
the context information to the latest template data, you can do this with the following steps:

Add the template as a "remote" and merge its history into your own:

1. Add the template as a remote:
   ```
   git remote add template https://github.com/lf-lang/curated-py.git
   ```

2. Fetch the latest changes:
   ```
   git fetch template
   ```

3. Merge the changes:
   Since the histories are unrelated, you must use the following flag:
   ```
   git merge template/main --allow-unrelated-histories
   ```

4. Resolve conflicts:
   If any template files have been modified in your new repo, you will need to manually resolve merge conflicts before committing. 
