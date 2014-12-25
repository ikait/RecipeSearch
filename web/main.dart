import 'package:route_hierarchical/client.dart';
import 'dart:html';

/**
 *
 */
void main() {
  router();

  querySelector('#test-form-submit').onClick.listen((e) {
    var query = querySelector('#test-form-textarea').value;
    receiveData();
  });

  var query = """
    PREFIX rcp: <http://www.tom.sfc.keio.ac.jp/recipeLod/class/>
    PREFIX rcpProp: <http://www.tom.sfc.keio.ac.jp/recipeLod/property/>

    SELECT * {
        ?s a rcp:Food ;
        rdfs:label ?label .
    }
  """;

  receiveData(uriWithQuery(query), (HttpRequest response) {  // onComplete
    window.console.dir(response);
  }, onError: (HttpRequest response) {  // onError
    window.console.dir(response);
  }, onTimeout: () {  // onTimeout

  });
}

/**
 * queryを引数にとり、Uriオブジェクトを返す
 * sparql endpoint に request する準備済
 *
 * @param query Endpointに投げるquery
 * @returns Uri queryを含めて組み立てられたUriオブジェクト
 */
Uri uriWithQuery(String query) {
  return new Uri.http("lod.jxj.jp", "/sparql", {
      "default-graph-uri": "",
      "query": query,
      "should-sponge": "",
      "format": "text/html",
      "timeout": "0",
      "debug": "on"
  });
}

/**
 * データを受信して指定した処理を行う
 *
 * @param onComplete 成功時に行う処理。引数にはHttpRequestが渡される
 * @param onError エラー時に行う処理。引数にはHttpRequestが渡される
 * @param onTimeout タイムアウト時に行う処理
 */
void receiveData(Uri uri, Function onComplete, {Function onError, Function onTimeout}) {
  window.console.dir(uri);
  HttpRequest.request(uri.toString(), onProgress: (ProgressEvent e) {

  }).then((HttpRequest response) {

    // processes if success
    onComplete(response);

  }).catchError((HttpRequest response) {

    // processes if error
    if (onError) {
      onError(response);
    }

  }).timeout(new Duration(minutes: 1), onTimeout: () {

    // processes if timeout
    if (onTimeout) {
      onTimeout();
    }

  });
}


/**
 * Router
 */
void router() {
  var router = new Router();
  router.root
    ..addRoute(name: 'home', path: '/', enter: showHome, defaultRoute: true)  // set home default
    ..addRoute(name: 'about', path: '/about', enter: showAbout)
    ..addRoute(name: 'search', path: '/search', enter: showSearch)
    ..addRoute(name: 'test', path: '/test', enter: showTest);
  router.listen();
}

void showHome(RouteEvent e) => showPage("#home");

void showAbout(RouteEvent e) => showPage("#about");

void showSearch(RouteEvent e) => showPage("#search");

void showTest(RouteEvent e) =>  showPage("#test");

void showPage(String selector) {
  var pages = [
      '#home',
      '#about',
      '#search',
      '#test'
  ];
  for (var i = 0, length = pages.length; i < length; i += 1) {
    var s = querySelector(pages[i]).style.display = 'none';
    if (s) {
      s.style.display = 'none';
    }
  }
  querySelector(selector).style.display = '';
}

