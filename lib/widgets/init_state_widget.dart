import 'dart:async';

import 'package:flutter/material.dart';


class InitStateWidget extends StatefulWidget {
  final FutureOr Function() initState;
  final Widget child;
  final bool keepAlive;
  const InitStateWidget({super.key, required this.initState, required this.child,this.keepAlive=true});

  @override
  State<InitStateWidget> createState() => _InitStateWidgetState();
}

class _InitStateWidgetState extends State<InitStateWidget>  with AutomaticKeepAliveClientMixin{
  bool _first=true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      if(_first){
        _first=false;
        try {
          if(mounted){
            await widget.initState();
          }
        } on Exception {
          //
        }
      }
    });
    return widget.child;
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
