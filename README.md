dart-appcache
=============

_A dart transformer to generate an appcache manifest file_

This transformer generates an appcache manifest file with all the project resources and modifies the entry points to reference it.
The appcache manifest is only generated in release mode

# Configuring
    
Add the transformer to your pubspec.yaml as the last build step:

    transformers:
    - polymer
    - $dart2js
    - appcache
        entry_points: web/index.html
    
(Assuming you already added this package to your pubspec.yaml file.)

# Options

## Specify a list of files that should be ignored

    transformers:
    - appcache:
        entry_points: web/index.html
        exclude:
          - web/file1
          - web/dir1

## Specify a list of urls that should also be cached

    transformers:
    - appcache:
        entry_points: web/index.html
        cache:
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
