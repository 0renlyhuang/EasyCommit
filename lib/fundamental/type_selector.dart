import 'package:flutter/material.dart';
import 'dart:math';
import 'package:easy_commit_client/commit_message/text_select_config.dart';
import 'add_item_dialog.dart';
import 'dart:async';

class TypeSelector extends StatefulWidget {
  const TypeSelector({Key? key, required this.name, required this.shouldRememberInitValue, required this.defaultSelectedIndex,
    required this.onSelected, required this.onAdd, required this.onDelete, required this.onReset, required this.onRememberChanged, required this.onGetList, this.addInstruction }) : super(key: key);

  final String name;
  final bool shouldRememberInitValue;
  final int? defaultSelectedIndex;

  final ValueChanged<int?> onSelected;
  final Function() onAdd;
  final ValueChanged<int> onDelete;
  final Function() onReset;
  final ValueChanged<bool> onRememberChanged;
  final List<TextSelectorItemConfig> Function() onGetList;
  final String? addInstruction;




  @override
  TypeSelectorState createState() => TypeSelectorState();
}

class TypeSelectorState extends State<TypeSelector> {
  int counter = 0;

  int? selectedIndex;
  int? hoverId;
  bool shouldRememberLastChoice = true;

  GlobalKey<AnimatedListState> globalKey = GlobalKey<AnimatedListState>();

  TextEditingController newConfigController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    shouldRememberLastChoice = widget.shouldRememberInitValue;

    int? defaultSelectedIndex = widget.defaultSelectedIndex;
    if (defaultSelectedIndex != null && defaultSelectedIndex > 0 && defaultSelectedIndex < widget.onGetList().length) {
      selectedIndex = defaultSelectedIndex;

      Timer.run((){
        notifySelected(selectedIndex);
      });


    }
    else {
      selectedIndex = null;
      Timer.run((){
        notifySelected(null);
      });
    }
  }

  List<TextSelectorItemConfig> getList() {
    return widget.onGetList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Transform.scale(
                scale: 0.7,
                child: Tooltip(
                  message: 'Remember last choice',
                  child:Checkbox(
                    value: shouldRememberLastChoice,
                    onChanged: (bool? value) {
                      _onRememberChanged(value);
                    },
                  ),
                )

              ),
            ),
            const SizedBox(
              width: 18,
              height: 18,
            ),

            Expanded(
                child: Center(child: Text(widget.name)),
            ),

            SizedBox(
              width: 18,
              height: 18,
              child: IconButton(
                padding: const EdgeInsets.all(0.0),
                icon: const Icon(Icons.refresh , size: 18),
                tooltip: 'Reset',
                onPressed: () => onReset(),
              ),
            ),
            SizedBox(
              width: 18,
              height: 18,
              child: IconButton(
                padding: const EdgeInsets.all(0.0),
                icon: const Icon(Icons.add , size: 18),
                tooltip: 'Add',
                onPressed: () => _onAddClicked(),
              ),
            ),
          ],
        ),

        Expanded(child:
          Material(child:
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
          ),
        )
      ],
    );
  }

  // 构建列表项
  Widget buildItem(context, index) {
    TextSelectorItemConfig config = getList()[index];

    return Dismissible(
      key: ValueKey(config.id),
      onDismissed: (direction) {
        onDelete(context, index);
      },
      background: Container(color: Colors.red),
      child: MouseRegion(
            onHover: (event) => _onMouseHoverItem(config.id),
            onExit: (event) => _onMouseHoverExitItem(),
            child:
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedIndex == index) {
                      selectedIndex = null;
                      notifySelected(null);
                    }
                    else {
                      selectedIndex = index;
                      notifySelected(index);
                    }

                  });

                },
                child:
                ListTile(
                  tileColor: _getBackgroundColor(config.id, index),
                  contentPadding: const EdgeInsets.all(0),
                  visualDensity: const VisualDensity(vertical: -4), // to compact
                  key: ValueKey(config.id),
                  title:
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: RichText(
                                text: TextSpan(
                                    children: [
                                      TextSpan(text: config.text, style: const TextStyle(fontSize: 14, color: Colors.black)),
                                      const TextSpan(text: " "),
                                      TextSpan(text: config.desc, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                    ]
                                )
                            ),
                          )


                      )

                    ],
                  ),

                )
            ),
          )



    );
  }



  void onDelete(context, index) {
    if (selectedIndex == index) {
      selectedIndex = null;
      notifySelected(null);
    }

    var item = buildItem(context, index);
    widget.onDelete(index);
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


  }

  void handleAddItem(int index, String text) {
    // 告诉列表项有新添加的列表项
    globalKey.currentState!.insertItem(index);
  }

  void notifySelected(int? index) {
    widget.onSelected(index);
  }

  void onReset() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Reset'),
        content: const Text('Reset to default content?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _handleReset(),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _handleReset() {
    widget.onReset();
    setState(() => globalKey = GlobalKey());
    Navigator.pop(context, 'Reset');
  }

  void _onMouseHoverItem(int id) {
    setState(() {
      hoverId = id;
    });
  }

  void _onMouseHoverExitItem() {
    setState(() {
      hoverId = null;
    });
  }

  Color _getBackgroundColor(int id, int index) {
    if (selectedIndex == index) {
      return Colors.grey.shade300;
    }
    if (hoverId == id) {
      return Colors.grey.shade200;
    }

    return index % 2 == 0 ? Colors.grey.shade50 : Colors.white;
  }

  void _onRememberChanged(bool? shouldRemember) {
    bool aShouldRemember = shouldRemember ?? true;
    setState(() {
      shouldRememberLastChoice = aShouldRemember!;
    });

    widget.onRememberChanged(aShouldRemember);
  }

  void _onAddClicked() {
    widget.onAdd();
  }
}