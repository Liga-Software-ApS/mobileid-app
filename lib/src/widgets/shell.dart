import 'package:flutter/widgets.dart';

Widget scaffoldFixedBody(
    {required List<Widget> children, bool shrinkWrap = true}) {
  return SafeArea(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(

              // width: double.infinity,
              // height: double.infinity,
              // color: Colors.red,
              // margin: const EdgeInsets.only(left: 20, right: 20),
              child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: shrinkWrap,
                  children: children))));
}
