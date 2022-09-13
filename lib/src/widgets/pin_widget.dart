import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loggy/loggy.dart';
import 'package:mobileid/style/colors/colors.dart';
import 'package:pinput/pinput.dart';

const defaultPinBoxContraints = BoxConstraints(maxWidth: 240);
const inputBackgroundColor = Colors.white;
final defaultPinTheme = PinTheme(
  width: 56,
  height: 56,
  textStyle: inputTextStyle,
  decoration: BoxDecoration(
    color: inputBackgroundColor,
    border: inputBorder,
    borderRadius: inputBorderRadius,
  ),
);

final inputBorder = Border.all(color: const Color.fromRGBO(234, 239, 243, 1));
final inputBorderRadius = BorderRadius.circular(16);
final inputFocusBorder = Border.all(color: Colors.black);

final inputOutlineBorder = OutlineInputBorder(borderRadius: inputBorderRadius);

final inputTextStyle = TextStyle(
    fontSize: 24, color: LigaColors.Primary, fontWeight: FontWeight.w600);

// ignore: must_be_immutable
class PinWidget extends StatefulWidget {
  bool showPin;

  int pinLength;

  bool isError;
  bool isComplex;
  TextEditingController controller;
  PinWidget(
      {Key? key,
      this.showPin = true,
      this.pinLength = 4,
      this.isError = false,
      this.isComplex = false,
      required this.controller})
      : super(key: key);
  @override
  PinWidgetState createState() => PinWidgetState();
}

class PinWidgetProps {
  final bool showPin;

  final int pinLength;
  final bool isError;
  final pinController = TextEditingController();
  PinWidgetProps({
    required this.showPin,
    required this.pinLength,
    required this.isError,
  });
}

class PinWidgetState extends State<PinWidget> {
  bool showPin = false;

  // String DefaultPin = "1234";

  bool isError = false;

  final formKey = GlobalKey<FormState>();
  // _PinWidgetState();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            if (!widget.isComplex)
              Pinput(
                obscureText: true,
                onCompleted: (pin) async => await onPin(pin),
                length: widget.pinLength,
                controller: widget.controller,
                forceErrorState: isError,
                validator: (pin) {
                  debugPrint("validator");

                  return null;
                },
                pinputAutovalidateMode: PinputAutovalidateMode.disabled,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration
                      ?.copyWith(border: inputFocusBorder),
                ),
                // onChanged: (v) => viewModel.changed(v),
              )
            else
              Container(
                constraints: defaultPinBoxContraints,
                child: TextField(
                  autocorrect: false,
                  controller: widget.controller,
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatters: [
                    FilteringTextInputFormatter.singleLineFormatter
                  ],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputBackgroundColor,
                    border: inputOutlineBorder,
                    // labelText: 'Enter Pin',
                  ),
                  obscureText: widget.showPin,
                ),
              )
          ],
        ));
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

  Future<void> _onPin(String pin) async {
    debugPrint("onPin pinwidget");
  }
}
