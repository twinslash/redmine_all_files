# Redmine all files plugin

Plugin for Redmine  to view all project files.

* Maintainer: Dmitry Kovalenok, [Hirurg103](https://github.com/Hirurg103)
* Contact: Report questions, bugs or feature requests on the [IssueTracker](https://github.com/twinslash/redmine_all_files/issues) or get in touch with me at [dzm.kov@gmail.com](mailto:dzm.kov@gmail.com)

## Installation

Clone plugin's source code into /plugins application directory
```console
git clone https://github.com/twinslash/redmine_all_files.git
```
Restart server.

## Features

* View all files for all projects in one place(v0.0.3).
* View all project files in one place.
* Files grouped by update date.
* The icon for the appropriate file extension.
* Possibility to jump into the container file.
* Search by filename or filename and description(v0.0.2).
* The sample files only from said containers(Documents, Issues, Project, Versions, WikiPages, News).
![](http://farm9.staticflickr.com/8519/8529759121_377dce6e8e_z.jpg)

## Changelog

* 0.0.3 Added menu item "All files" into top menu(2013-03-21).
* 0.0.2 Implemented search(2013-03-02).
* 0.0.1 Base functionality(2013-02-28).


## Uninstall

Remove /redmine_jquery_all_files directory from /plugins directory
```console
cd redmine_application_path/plugins
rm -rf redmine_all_files
```

Restart server.

## Dependencies

* This plugin uses icons from the free set of icons [Free-file-icons](https://github.com/teambox/Free-file-icons)
