# DynamicTableView

[![CI Status](http://img.shields.io/travis/tomquist/DynamicTableView.svg?style=flat)](https://travis-ci.org/tomquist/DynamicTableView)
[![Version](https://img.shields.io/cocoapods/v/DynamicTableView.svg?style=flat)](http://cocoadocs.org/docsets/DynamicTableView)
[![License](https://img.shields.io/cocoapods/l/DynamicTableView.svg?style=flat)](http://cocoadocs.org/docsets/DynamicTableView)
[![Platform](https://img.shields.io/cocoapods/p/DynamicTableView.svg?style=flat)](http://cocoadocs.org/docsets/DynamicTableView)

Table view rewrite without the need to specify the table view cell height.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

DynamicTableView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "DTVTableView"

## How does it work

DTVTableView constantly recalculates row positions and the scroll view's content size while scrolling through the list.