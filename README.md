dart-appcache
=============

_A dart transformer to generate an appcache manifest file_

This transformer generates an appcache manifest file with all the project resources and modifies the entry points to reference it.
The appcache manifest is only generated in release mode

# Changelog

0.1.2 Added support for caching files in lib folder

# Configuring
    
Add the transformer to your pubspec.yaml:

    transformers:
    - appcache:
        $exclude: ["**.dart"]
        entry_points: web/index.html
        cache:
          - web/index.html_bootstrap.dart.js
        
    
(Assuming you already added this package to your pubspec.yaml file.)

# Options

## Specify a list of files that should be ignored

    transformers:
    - appcache:
        $exclude: ["file1", "dir1", "**.dart"]
        entry_points: web/index.html

## Specify a list of urls that should also be cached

    transformers:
    - appcache:
        entry_points: web/index.html
        cache:
          - web/index.html_bootstrap.dart.js
          - web/packages/web_components/webcomponents.min.js
          - web/packages/web_components/dart_support.js
          - web/packages/polymer/src/js/polymer/polymer.min.js
          - https://ajax.googleapis.com/ajax/libs/webfont/1.4.7/webfont.js

## Specify the network part (default is '*')

    transformers:
    - appcache:
        entry_points: web/index.html
        network:
          - web/file1
          - web/file2

## Specify the fallback part (no default)

    transformers:
    - appcache:
        entry_points: web/index.html
        fallback:
          - / web/offine.html
