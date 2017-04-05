# Conventions

This document covers important conventions.


## Skeleton

### Directories

Unified directories for all projects. Create them only if necessary.

* bin - Entry point scripts.
* src,lib - Project code used by more than one entry point script.
* test - Tests for project code and entry point scripts.
* doc - Documentation files.
* web - Web entry points and assets.
* build - Files, executables and reports generated during build.


### Files

Unified files and scripts for all projects. All mentioned scripts have the argument `--ci-mode` to also write reports to `build` rather than just print them.

* README.md - The readme explaining how to install required dependencies and brief usage examples.
* CONTRIBUTING.md - Notes to help others contribute.
* CHANGELOG.md - Change log of this project.
* CONVENTIONS.md - Explains the project structure and things that can be kept similar in other projects.
* LICENSE.md - A license for the project so that code can be reused by others.
* build.sh - Builds the project including metrics, checks and tests.
* run-tests.sh - Run tests, provide access to individual test suites.
* run-style-check.sh - Code style and lint checks.
* run-metrics.sh - Collect metrics.


## Glossary

### Camel Case Convention

Upper case every word, no separation of words.
Keep abbreviations capitalized.
Streamline names with irregular capital letters to have only one at the beginning.

```
Camel Case Convention, camel case convention => CamelCaseConvention
XML Library => XMLLibrary
GitLab => Gitlab
```


### Dash Convention

Lower case everything, words separated by dashes.

```
Dash Convention, dash convention => dash-convention
```


### Initials Convention

Lower case everything, take the first letter of each word and connect them.

```
Initials Convention, initials convention => ic
```


### Underscore Convention

Lowercase everything, separate words with an underscore.

```
Initials Convention, initials convention => initials_convention
```


## Script names

Script names should be in the dash or initials convention.
Dashes are preferred over underscores since they don't require pressing shift to type.

Example:

```
example-script.sh
es
```


## Project name

A unified project name is a major benefit in managing a large number of tools and libraries.
The project name should be in camel case convention.

```
ExampleProject
JenkinsJobManager
GitlabTools
JenkinsTools
```


## General advice

Advice that should fit in where no specific rule applies.

* Keep it simple, stupid.
* Keep it consistent.
* Conventions are intended to be intuitive and machine-readable to allow for easy automated checking, testing and metrics.
* If no convention exists and you deem one necessary, design and discuss an approach and document it.


## Readme

This section explains how to write unified readme files.

* Headlines start with capital letters, every word after that becomes lower case unless it's a name or an abbreviation.
* One blank line after every headline.
* Two blank lines after every section except the last. A section is every part of a document starting with a headline, but not the main headline.
* If a section has no body, put only one blank line afterwards instead of two.
