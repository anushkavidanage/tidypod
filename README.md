# Tidy Pod - A simple task manager for your Data Vault

**A ToDo app to manage your daily tasks. Based on Solid Pod technology.**

_***Still under development_

_Authors: Anushka Vidanage_

*License: GNU GPL V3*

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)


[![GitHub License](https://img.shields.io/github/license/anushkavidanage/tidypod)](https://raw.githubusercontent.com/anushkavidanage/tidypod/main/LICENSE)
[![Flutter Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/anushkavidanage/tidypod/main/pubspec.yaml&query=$.version&label=version)](https://github.com/anushkavidanage/tidypod/main/CHANGELOG.md)
[![Last Updated](https://img.shields.io/github/last-commit/anushkavidanage/tidypod?label=last%20updated)](https://github.com/anushkavidanage/tidypod/commits/main/)
[![GitHub Issues](https://img.shields.io/github/issues/anushkavidanage/tidypod)](https://github.com/anushkavidanage/tidypod)

## Introduction

The TidyPod app is an demonstrator app for Solid personal online data 
stores (Pods) written in [Flutter](https://flutter.dev/) and 
[Dart](https://dart.dev/). Using this app you can manage your daily tasks. 
It is a cross-platform app that will run on desktop, mobile, and web. 
All your task data will be saved on your Pod hosted on a 
[Solid server](https://github.com/CommunitySolidServer/). You maintain 
full control over your data, not the app developer or anyone else.

This app is build as part of a suite of demonstrator apps developed 
by the research team at the [ANU Software Innovation Institute](https://sii.anu.edu.au) 
(SII). To accessmore apps like this using Solid Pod technology 
please go to [Solid Community AU](https://solidcommunity.au/) website.


## Getting Started

### Obtaining a Pod

To use the app you will need your own Pod hosted on a Solid server. To
try it out you can get yourself a Pod at SII's experimental server, the
[Australian Solid Community Pod
Server](https://pods.solidcommunity.au/.account/login/password/register/)
or any one of the available [Pod
Providers](https://solidproject.org/users/get-a-pod) world wide.

### Install the App Locally
_installers coming soon_

### Usage

At the start up you will first need to login to your pod by clicking 
the `Login` button. You can register for a Pod using the `Register`
button.

<div style="left">
	<img
	src="https://raw.githubusercontent.com/anushkavidanage/tidypod/refs/heads/main/images/login.PNG"
	alt="Login" width="600"/>
</div>

When you login for the first time, you will have an option to load
a list of sample tasks or you can get started by adding a new
category. 

<div style="left">
	<img
	src="https://raw.githubusercontent.com/anushkavidanage/tidypod/refs/heads/main/images/startup.PNG"
	alt="Startup" width="600"/>
</div>

You will have two layout style options to manage your tasks, Kanban
board view and Tab view. You are able to move categories around and
event move tasks between categories.

<div style="left">
	<img
	src="https://raw.githubusercontent.com/anushkavidanage/tidypod/refs/heads/main/images/kanban-board.PNG"
	alt="Kanban board view" width="600"/>
</div>

<div style="left">
	<img
	src="https://raw.githubusercontent.com/anushkavidanage/tidypod/refs/heads/main/images/tab-view.PNG"
	alt="Tab view" width="600"/>
</div>

You can add new categories and tasks using the corresponding buttons.
When adding new tasks, you will have the option to add a due date
as well. 

<div style="left">
	<img
	src="https://raw.githubusercontent.com/anushkavidanage/tidypod/refs/heads/main/images/new-category.PNG"
	alt="New category" width="600"/>
</div>

<div style="left">
	<img
	src="https://raw.githubusercontent.com/anushkavidanage/tidypod/refs/heads/main/images/new-task.PNG"
	alt="New task" width="600"/>
</div>

Your data will be automatically saved in the local storage of the
device and will be synced with the Pod every 10 seconds (will execute 
on the background). If you close and re-open your app, your last saved 
tasks will be retrieved either from your Pod or from the local storage
(depending on which has the latest updates).

<div style="left">
	<img
	src="https://raw.githubusercontent.com/anushkavidanage/tidypod/refs/heads/main/images/sync-and-due-date.PNG"
	alt="Synch" width="600"/>
</div>

If you start your app on a mobile device, by default you will be 
directed to the Tab view of the app since it is much easier to navigate
through the Tab view. However, you can still go to the Kanban board
view using the navigation menu.

<div style="left">
	<img
	src="https://raw.githubusercontent.com/anushkavidanage/tidypod/refs/heads/main/images/mobile-view.PNG"
	alt="Mobile view" width="300"/>
</div>

