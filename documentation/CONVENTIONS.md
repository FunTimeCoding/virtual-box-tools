# Conventions

This document covers conventions.


## Skeleton

### Directories

Directories for projects based on the skeleton for this language.

* bin - Entry point scripts.
* lib - Project code used by more than one entry point script.
* documentation - Documentation files.
* documentation/dictionary - Dictionary files.
* script - Development scripts to build, check, manage job configuration and vagrant.
* build - Files, executables and reports generated during build.
* tmp - Temporary files.


### Files

Unified files and scripts for all projects. All mentioned scripts have the argument `--ci-mode` to also write reports to `build` rather than just print them.

* README.md - The readme explaining how to install required dependencies and brief usage examples.
* CONTRIBUTING.md - Notes to help others contribute.
* CHANGELOG.md - Change log of this project.
* CONVENTIONS.md - Explains the project structure and things that can be kept similar in other projects.
* LICENSE.md - A license for the project so that code can be reused by others.
* build.sh - Builds the project including metrics, checks and tests.
* test.sh - Run tests, provide access to individual test suites.
* check.sh - Code style and lint checks.
* measure.sh - Collect metrics.


## Glossary

### Camel Case Convention

Upper case words.
Use long forms of abbreviations and acronyms.
Do not separate words.

```
Upper Case Separated => UpperCaseSeparated
lower case separated => LowerCaseSeparated
Generic Lib => GenericLibrary
XML Library => ExtensibleMarkupLanguageLibrary
```


### Dash Convention

Lower case everything, words separated by dashes.

```
Dash Convention => dash convention => dash-convention
```


### Initials Convention

Lower case everything, take the first letter of each word.

```
Initials Convention => initials convention => ic
```


### Underscore Convention

Lower case everything, separate words with an underscore.

```
Underscore Convention => underscore convention => underscore_convention
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
GitLabTools
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
