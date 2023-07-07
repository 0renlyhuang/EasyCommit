import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';

enum PrefixItemType {
  kNormal,
  kAdd,
}

class SimpleListAction {

}

class SimpleListActionAdd extends SimpleListAction {
  String text;

  SimpleListActionAdd(this.text);
}

class SimpleListActionDelete extends SimpleListAction {
  int index;

  SimpleListActionDelete(this.index);
}



class SimpleListItem {
  int id;
  String text;

  SimpleListItem(this.id, this.text);

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text
  };

  SimpleListItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'];
}

class SimpleList extends StatefulWidget {
  const SimpleList({Key? key, required this.onDelete, required this.onFix, required this.onOpen, required this.onGetList }) : super(key: key);

  static of(BuildContext context, {bool root = false}) => root
      ? context.findRootAncestorStateOfType<SimpleListState>()
      : context.findAncestorStateOfType<SimpleListState>();

  final ValueChanged<int> onDelete;
  final ValueChanged<int> onFix;
  final ValueChanged<int> onOpen;
  final List<SimpleListItem> Function() onGetList;

  @override
  SimpleListState createState() => SimpleListState();
}

class SimpleListState extends State<SimpleList> {
  int? selectedVal;

  final globalKey = GlobalKey<AnimatedListState>();

  TextEditingController newConfigController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
  }

  List<SimpleListItem> getList() {
    return widget.onGetList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child:
        AnimatedList(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          key: globalKey,
          initialItemCount: getList().length,
          itemBuilder: (
              BuildContext context,
              int index,
              Animation<double> animation,
              ) {
            //添加列表项时会执行渐显动画
            return FadeTransition(
              opacity: animation,
              child: buildItem(context, index),
            );
          },
        )
        )
      ],
    );
  }

  // 构建列表项
  Widget buildItem(context, index) {
    SimpleListItem config = getList()[index];

    return ListTile(
  tileColor: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
  contentPadding: const EdgeInsets.all(0),
  // visualDensity: const VisualDensity(vertical: -4), // to compact
  key: ValueKey(config.id),
  title:
  Row(
    children: [
      Expanded(child: RichText(
        text:  TextSpan(
          text: config.text,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      )
      ),
      IconButton(
        icon: const Icon(Icons.folder_open),
        tooltip: 'Open',
        onPressed: () {
          setState(() {
            widget.onOpen(index);
          });
        },
      ),
      IconButton(
        icon: const Icon(Icons.build_circle_outlined),
        tooltip: 'Fix',
        onPressed: () {
          setState(() {
            widget.onFix(index);
          });
        },
      ),



      IconButton(
        icon: const Icon(Icons.delete_forever_outlined),
        tooltip: 'Delete',
        onPressed: () {
          setState(() {
            widget.onDelete(index);
          });
        },
      ),
    ],
  ),

);
  }

  void deleteItemAt(context, index) {
    var item = buildItem(context, index);

    setState(() {
      globalKey.currentState!.removeItem(
        index,
            (context, animation) {
          // 删除过程执行的是反向动画，animation.value 会从1变为0

          // 删除动画是一个合成动画：渐隐 + 收缩列表项
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              //让透明度变化的更快一些
              curve: const Interval(0.5, 1.0),
            ),
            // 不断缩小列表项的高度
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: 0.0,
              child: item,
            ),
          );
        },
        duration: const Duration(milliseconds: 200), // 动画时间为 200 ms
      );
    });
  }

  void addItemAt(index) {
    // 告诉列表项有新添加的列表项
    globalKey.currentState!.insertItem(index);
  }
}