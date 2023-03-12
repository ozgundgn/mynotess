import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mynotes/helpers/loading/loading_screen_controller.dart';

class LoadingScreen {
  //singleton
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();
  factory LoadingScreen() => _shared;
  //
  LoadingScreenController? controller;

  void hide() {
    controller?.close();
    controller = null;
  }

  void show({
    required BuildContext context,
    required String text,
  }) {
    if (controller?.update(text) ?? false) {
      return;
    } else {
      controller = showOverlay(
        context: context,
        text: text,
      );
    }
  }

  LoadingScreenController showOverlay(
      {required BuildContext context, required String text}) {
    final _text = StreamController<String>();
    _text.add(text);

    final state = Overlay.of(context);
    final renderBox = context.findRenderObject()
        as RenderBox; //basically extract the avaliable size that our overlay can have  on the screen
    final size = renderBox.size;

    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          //have some default styling so you can put your components in there and they will be style according to the system skin
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: size.height * 0.8,
                maxWidth: size.width * 0.8,
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ), //border
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize
                        .min, //if we dont give a mainaxissize a minimum pure column your column is going to grab as much space as it can so its just going to expand as much as it can.
                    //if it is minimum it is just gonna basically try to hug its contents as much as it can
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10), // for space
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      StreamBuilder(
                        stream: _text.stream,
                        builder: ((context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data as String,
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return Container(); //bişey döndürmemiz gerekitği için boş container gönderdik. bunun yerine Text de dönebilirdik return Text(''); gibi
                          }
                        }),
                      )
                    ],
                  ),
                ), // if the contents owerflows the container's height for instance then its going to allow the user to scroll on that contiainer.
              ),
            ),
          ),
        );
      },
    );

    state?.insert(
        overlay); //this actually adds the overlay to the entire overlay state that flutter manages on the screen
    return LoadingScreenController(close: () {
      _text.close();
      overlay.remove();
      return true;
    }, update: (text) {
      _text.add(text);
      return true;
    });
  }
}
