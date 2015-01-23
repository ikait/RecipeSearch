import 'package:route_hierarchical/client.dart';
import 'dart:html';
import 'dart:convert';  // jsonパース用

/**
 *
 */
void main() {
  router();

  /* 
   * これまで、C とか Java で、上の行から順次実行していくプログラムを書いてきたと思います。
   * 今回は(インターフェイスの開発では)、必ずしも上から順に実行されなくて、「あるイベント」
   * の処理内容を書いていくことが多くなると思います。
   * これを「イベント駆動型プログラミング」といいます。
   * 
   * JavaScript とか Dart でも、よく「イベント駆動」でコードを書きます。なぜかというと、
   * ページが開いた瞬間、JSやDartが読み込まれた瞬間から何か処理をはじめることもありますけど、
   * ボタンがクリックされた時、とか、フォームに文字が入力された時、のような「あるイベント」が
   * 起きた時に何か処理が行われるということも多いからです。
   * 
   * 以下に、querySelector("#test-form-submit").onClick.listen() がありますが、
   * これが意味する所は、Dart が読み込まれたときに「#test-form-submit がクリックされる
   * のを監視してください、クリックされたら引数で渡した関数の処理を実行して下さい」という
   * 処理を実行(予約?)しているということです。
   * 
   * onClickの他にもイベントはたくさんあります。
   * https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart:html.Element#id_onClick
   * 
   * listen() が具体的にどんな引数をとるのかは以下を参照して下さい。
   * https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart:html.ElementStream#id_listen
   *  
   */
  querySelector('#test-form-submit').onClick.listen((e) {
 
    // クエリーを入力する textarea を捕捉
    TextAreaElement textarea = querySelector('#test-form-textarea');
    
    // 結果を表示する element を捕捉
    Element resultElement = querySelector("#test-results"); 
    
    // textarea の値を取得
    String query = textarea.value;
    
    // jsonで受け取るように設定
    String format = "application/sparql-results+json";
    
    window.console.log("Start receiving!!");
    resultElement.innerHtml = "Loading...";
 
    /* uriWithQuery()は、queryからuriを組み立てる関数。下の方で宣言しています。
     * (HttpRequest response) {} は、引数にHttpRequestクラスの変数をとる無名関数です。。
     * 以下では、成功時、エラー時、タイムアウト時の3つの無名関数を渡してます。
     * 
     * それぞれ、他のところで
     *  
     * void onSuccess(HttpRequest response) { 
     *   // 成功時の処理
     * }
     * 
     * というように別に宣言してもいいけれど、
     * ここ以外で使わないので無名関数として直接宣言してみます。
     * 
     * ちなみに、responseがどんなプロパティを持っているかはレファレンスに書いてあります↓
     * https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart:html.HttpRequest#id_responseText
     */
    receiveData(uriWithQuery(query, format: format), (HttpRequest response) {        
      // 通信成功して何か受け取った時 (結果は空かもしれない)
      
      if (!response.responseText.isEmpty) {  // responseTextがあれば
        String jsonString = response.responseText; 
        Map data = JSON.decode(jsonString);  // jsonをデコードして、Dartで扱えるように
        
        // とりあえず、value を全部表示してみる
        querySelector("#test-results").text = "";  // 一旦空白にして
        for (Map binding in data["results"]["bindings"]) {
          String label = binding["label"]["value"];          
          resultElement.innerHtml += label + "<br>";          
        }
      }
    }, onError: () {
      
    }, onTimeout: () {
      
    });
  });
}

/**
 * queryなどを引数にとり、Uriオブジェクトを返す
 * sparql endpoint に request する準備済
 *
 * @param query Endpointに投げるquery
 * @returns Uri queryを含めて組み立てられたUriオブジェクト
 */
Uri uriWithQuery(String query, {String format: "text/html", String uri: "lod.jxj.jp"}) {
  return new Uri.http(uri, "/sparql", {
      "default-graph-uri": "",
      "query": query,
      "should-sponge": "",
      "format": format,
      "timeout": "0",
      "debug": "on"
  });
}

/**
 * データを受信して指定した処理を行うラッパーメソッド。
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

  }).catchError(() {

    // processes if error
    onError();
    window.console.error("error");

  }).timeout(new Duration(minutes: 1), onTimeout: () {

    // processes if timeout
    if (onTimeout != null) {
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
    var s = querySelector(pages[i]);
    if (s != null) {
      s.style.display = 'none';
    }
  }
  querySelector(selector).style.display = '';
}

