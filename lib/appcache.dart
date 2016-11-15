library appcache;

import 'package:barback/barback.dart';
import 'dart:async' show Future;
import 'package:html/parser.dart';

class TransformOptions {
  List<String> entryPoints;
  List<String> cache;
  List<String> network;
  List<String> fallback;
  bool debug;
}

class AppCacheTransformer extends AggregateTransformer {
  TransformOptions options;
  AppCacheTransformer(this.options);
  AppCacheTransformer.asPlugin(BarbackSettings settings) : this(_parseSettings(settings));

  static List<String> _settings2List(value, name) {
    var list = [];
    if (value != null) {
      bool error;
      if (value is List) {
        list = value;
        error = value.any((e) => e is! String);
      } else if (value is String) {
        list = [value];
        error = false;
      } else {
        error = true;
      }
      if (error) print('Invalid value for "$name" in the appcache transformer.');
    }
    return list;
  }

  static TransformOptions _parseSettings(BarbackSettings settings) {
    var args = settings.configuration;
    TransformOptions options = new TransformOptions();
    options.entryPoints = _settings2List(args["entry_points"], "entry_points");
    options.cache = _settings2List(args["cache"], "cache");
    options.network = _settings2List(args["network"], "network");
    options.fallback = _settings2List(args["fallback"], "fallback");
    options.debug = settings.mode.name == "debug";
    return options;
  }

  Future apply(AggregateTransform transform) {
    return transform.primaryInputs.toList().then((assets) {
      if (!options.debug && transform.key == "entry-points") {
        for (var i in assets) {
          return i.readAsString().then((content) {
            var document = parse(content);
            var html = document.getElementsByTagName("html").first;
            html.attributes["manifest"] = "app.appcache";
            transform.addOutput(new Asset.fromString(i.id, document.outerHtml));
          });
        }
      } else if (!options.debug) {
        var buffer = new StringBuffer()
            ..writeln('CACHE MANIFEST')
            ..writeln('#Generated: ${new DateTime.now()}')
            ..writeln('CACHE:');
        for (var i in options.cache) {
          if (i.startsWith("web/")) buffer.writeln(i.substring(4)); else buffer.writeln(i);
        }
        for (Asset i in assets) {
          if(i.id.path.startsWith("lib/")) buffer.writeln("packages/${i.id.package}/" + i.id.path.substring(4)); else buffer.writeln(i.id.path.substring(4));
        }
        buffer.writeln('NETWORK:');
        if (options.network.isEmpty) {
          buffer.writeln('*');
        } else {
          for (var i in options.network) {
            if (i.startsWith("web/")) buffer.writeln(i.substring(4)); else buffer.writeln(i);
          }
        }
        if (options.fallback.isNotEmpty) {
          buffer.writeln('FALLBACK:');
          for (var i in options.fallback) {
            List<String> line = i.split(" ");
            String converted = "";
            String separator = "";
            for (var j in line) {
              if (j.startsWith("web/")) converted += separator + j.substring(4); else converted += separator + j;
              separator = " ";
            }
            buffer.writeln(converted);
          }
        }
        var id = new AssetId(transform.package, "web/app.appcache");
        transform.addOutput(new Asset.fromString(id, buffer.toString()));
      }
    });
  }

  String classifyPrimary(AssetId id) {
    if (options.debug) return null;
    for (var i in options.entryPoints) {
      if (id.path == i) return "entry-points";
    }
    if (id.path.endsWith("appcache")) return null;
    if (!(id.path.startsWith("web/") || id.path.startsWith("lib/"))) return null;
    return "cache";
  }
}
