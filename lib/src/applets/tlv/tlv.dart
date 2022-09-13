import 'package:tuple/tuple.dart';

class Parser {
  Parser();

  List<TLV> parse(List<int> data) {
    // debugPrint("parse()");

    List<TLV> tlvs = [];

    int i = 0;
    while (i < data.length) {
      var t = _parse(data.skip(i).toList(), 0);

      tlvs.add(t.item1);
      i += t.item2;
      // debugPrint("$i/${t.item2} of ${data.length}");
    }

    return tlvs;
  }

  Tuple2<int, int> parseLength(List<int> data) {
    var l1 = data.take(1).single;

    if (l1 <= 0x7f) {
      return Tuple2(1, l1);
    }

    // debugPrint("two byte length");

    if (l1 == 0x81) {
      var l2 = data.skip(1).take(1).single;
      return Tuple2(2, l2);
    }
    // debugPrint("three byte length");
    if (l1 == 0x82) {
      var l2 = data.skip(1).take(1).single;
      var l3 = data.skip(2).take(1).single;
      return Tuple2(3, l2 * 0x100 + l3);
    }

    return const Tuple2(0, 0);
  }

  Tuple2<int, int> parseTag(List<int> data) {
    var tag = data.take(1).single;

    if (tag & 0x1f != 0x1f) {
      return Tuple2(1, tag);
    }

    // debugPrint("two byte tag");
    var tag2 = data.skip(1).take(1).single;

    if (tag2 & 0x80 != 0x80) {
      return Tuple2(2, (tag << 8) + tag2);
    }

    // debugPrint("three byte tag");
    var tag3 = data.skip(2).take(1).single;

    return Tuple2(3, (tag << 16) + (tag2 << 8) + tag3);
  }

  Tuple2<TLV, int> _parse(List<int> data, int lenParsed) {
    var tag = parseTag(data);
    var index = tag.item1;
    var length = parseLength(data.skip(index).toList());

    index += length.item1;

    if (index + length.item2 - 1 > data.length) {
      throw Exception("Buffer ends earlier");
    }

    var value = data.skip(index).take(length.item2).toList();
    if (length.item1 == 0) {
      return Tuple2(TLV(tag.item2, 0, []), index);
    }

    index += length.item2;

    var result = TLV(tag.item2, length.item2, value);
    // debugPrint("$result");

    if ((tag.item2 % 0xff) & 0x20 != 0) {
      // debugPrint("Tag ${tag.item2.toRadixString(16)} has children");
      var j = 0;

      while (j < value.length) {
        var parsed = _parse(value.skip(j).toList(), 0);

        result.children.add(parsed.item1);
        j += parsed.item2;
      }
    }

    return Tuple2(result, index);
  }
}

class TLV {
  int tag;
  int length;
  List<int> value = [];
  List<TLV> children = [];
  late TLV parent;

  TLV(this.tag, this.length, this.value);

  @override
  String toString() {
    return "${tag.toRadixString(16)}/${length.toRadixString(16)} -> $value";

    // return "${tag.toRadixString(16)}/${length.toRadixString(16)} -> $value ${children.length} (${children.map((c) => c.tag.toRadixString(16))})";
  }
}

class TLVBuilder {
  late int tag;
  List<int> value = [];

  setTag(int tag) {}

  setValue(List<int> value) {}
}
