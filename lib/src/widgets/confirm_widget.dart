import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:mobileid/src/widgets/pin_widget.dart';

// ignore: must_be_immutable
class ConfirmWidget extends StatefulWidget {
  IconData? iconData;

  String? confirmLabel;

  String? cancelLabel;
  String title;
  String description;

  void Function(String)? onCompleted;
  void Function()? onCanceled;

  bool showPin;
  int pinLength;

  bool isError;
  bool isComplex;
  TextEditingController? controller;
  ConfirmWidget({
    Key? key,
    this.showPin = true,
    this.pinLength = 4,
    this.isError = false,
    this.isComplex = false,
    this.iconData,
    this.onCompleted,
    this.onCanceled,
    required this.title,
    required this.description,
  }) : super(key: key);
  @override
  ConfirmWidgetState createState() => ConfirmWidgetState();
}

class ConfirmWidgetProps {
  final bool showPin;

  final int pinLength;
  final bool isError;
  final pinController = TextEditingController();
  ConfirmWidgetProps({
    required this.showPin,
    required this.pinLength,
    required this.isError,
  });
}

class ConfirmWidgetState extends State<ConfirmWidget> {
  bool showPin = false;

  bool isError = false;

  final formKey = GlobalKey<FormState>();

  final pinController = TextEditingController();

  // _ConfirmWidgetState();

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;

    return Column(children: <Widget>[
      Icon(widget.iconData ?? Icons.gpp_good_outlined, size: 64.0),
      const SizedBox(height: 32),
      Text(
        widget.title,
        style: Theme.of(context).textTheme.headline1,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      Text(
        widget.description,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 64),
      PinWidget(controller: pinController),
      const SizedBox(height: 64),
      ElevatedButton(
          onPressed: _onCompleted,
          child: Text(widget.confirmLabel ?? t.genericConfirm)),
      const SizedBox(height: 16),
      TextButton(
          onPressed: _onCanceled,
          child: Text(widget.cancelLabel ?? t.genericCancel)),
    ]);
  }

  Future<void> onPin(String? pin) async {
    if (pin == null) return;

    try {
      await _onPin(pin);
      return;
    } catch (e) {
      logDebug("Credentials error");
    }
  }

  void _onCanceled() {
    if (widget.onCanceled != null) {
      widget.onCanceled!();
    }
  }

  void _onCompleted() {
    if (widget.onCompleted != null) {
      widget.onCompleted!(pinController.text);
    }
  }

  Future<void> _onPin(String pin) async {
    debugPrint("onPin");
  }
}
