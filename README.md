# DTVTableView

[![CI Status](http://img.shields.io/travis/tomquist/DTVTableView.svg?style=flat)](https://travis-ci.org/tomquist/DTVTableView)
[![Version](https://img.shields.io/cocoapods/v/DTVTableView.svg?style=flat)](http://cocoadocs.org/docsets/DTVTableView)
[![License](https://img.shields.io/cocoapods/l/DTVTableView.svg?style=flat)](http://cocoadocs.org/docsets/DTVTableView)
[![Platform](https://img.shields.io/cocoapods/p/DTVTableView.svg?style=flat)](http://cocoadocs.org/docsets/DTVTableView)

Table view rewrite without the need to specify the table view cell height.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

DTVTableView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "DTVTableView"

## How does it work

DTVTableView constantly recalculates row positions and the scroll view's content size while scrolling through the list.