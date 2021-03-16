import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js.dart' as js;
import 'fake_ui.dart' if (dart.library.html) 'real_ui.dart' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHome(),
    );
  }
}

class HtmlDisplay extends StatefulWidget {
  final String htmlText;

  const HtmlDisplay(this.htmlText);
  @override
  _HtmlDisplayState createState() => _HtmlDisplayState();
}

class _HtmlDisplayState extends State<HtmlDisplay> {
  js.JsObject connector;
  String createdViewId = 'map_element';
  html.IFrameElement element;

  @override
  void initState() {
    js.context["connect_content_to_flutter"] = (js.JsObject content) {
      print(content.toString() + "Content");
      connector = content;
    };
    element = html.IFrameElement()
      ..src = "/assets/view_editor.html"
      ..style.border = 'none';
    ui.platformViewRegistry
        .registerViewFactory(createdViewId, (int viewId) => element);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: showView()),
    );
  }

  Widget showView() {
    Future.delayed(const Duration(seconds: 2), () {
      if (widget.htmlText != null && connector != null) {
        connector.callMethod(
          'getViewValue',
        ) as String;
        element.contentWindow.postMessage({
          'id': 'question',
          'msg': widget.htmlText,
        }, "*");
      }
    });
    return SizedBox(
      height: 340,
      child: HtmlElementView(
        viewType: createdViewId,
      ),
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  String htmlText = """​<!DOCTYPE html>
<html>
<body>

<p>
This paragraph
contains a lot of lines
in the source code,
but the browser 
ignores it.
</p>

<p>
This paragraph
contains      a lot of spaces
in the source     code,
but the    browser 
ignores it.
</p>

<p>
The number of lines in a paragraph depends on the size of the browser window. If you resize the browser window, the number of lines in this paragraph will change.
</p>

</body>
</html>
""";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 2,
        itemBuilder: (BuildContext context, int index) {
          return ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HtmlDisplay(htmlText)));
            },
            child: Text('Tap'),
          );
        },
      ),
    );
  }
}
