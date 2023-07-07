import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddDialogConfig {
  AddDialogConfig({
    required this.title, required this.contentInstruction, required this.addable, this.resultLabel, this.tagList
  });

  final String title;
  final String contentInstruction;

  final bool addable;
  final String? resultLabel;

  final List<String>? tagList;
}

class AddItemDialogWidget extends StatefulWidget {
  const AddItemDialogWidget(
      {Key? key, required this.config, required this.onResult})
      : super(key: key);

  @override
  _AddItemDialogWidgetState createState() => _AddItemDialogWidgetState();

  final AddDialogConfig config;
  final ValueChanged<String> onResult;

  void show(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return this;
        });
  }
}

class _ItemContent {
  String? tag;
  TextEditingController textEditingController = TextEditingController();
  TextEditingController tagTextEditingController = TextEditingController();

  _ItemContent();
}

class _AddItemDialogWidgetState extends State<AddItemDialogWidget> {
  String? selectedTag;
  late final String contentInstruction;
  late final bool shouldResultFieldVisible;
  late final bool shouldAddVisible;
  late final bool shouldDeleteVisible;
  late final bool shouldTagVisible;
  late final String _resultLabel;

  final List<_ItemContent> _itemContentList = [];
  final TextEditingController _resultTextController = TextEditingController();

  @override
  void initState() {
    contentInstruction = widget.config.contentInstruction;
    shouldResultFieldVisible = widget.config.addable;
    shouldAddVisible = widget.config.addable;
    shouldDeleteVisible = widget.config.addable;
    shouldTagVisible = (widget.config.tagList != null);
    _resultLabel = widget.config.resultLabel ?? 'Result';

    _onItemAddClick(-1);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _resultTextController.dispose();
    for (var element in _itemContentList) {
      element.textEditingController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)), //this right here
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(widget.config.title),
                const Padding(padding: EdgeInsets.only(top: 12)),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: _itemContentList.length,
                    itemBuilder: (context, index) => _buildItemWidget(index),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 12)),
                shouldResultFieldVisible
                    ? Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        child: TextField(
                          textAlignVertical: TextAlignVertical.top,
                          readOnly: true,
                          expands: true,
                          maxLines: null,
                          controller: _resultTextController,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: const OutlineInputBorder(),
                            labelText: _resultLabel,
                            contentPadding:
                              const EdgeInsets.fromLTRB(8, 16.0, 8, 8.0),
                            isDense: true, // and add this line
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                const Padding(padding: EdgeInsets.only(top: 12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => _onCancelClick(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _onConfirmClick(context),
                      child: const Text("Add"),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemWidget(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          shouldTagVisible ? buildTagDropDown(index) : const SizedBox.shrink(),
          const Padding(padding: EdgeInsets.only(left: 8)),
          Expanded(
            child: TextField(
              controller: _itemContentList[index].textEditingController,
              maxLines: null,
              // obscureText: true,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: const OutlineInputBorder(),
                labelText: contentInstruction,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          shouldAddVisible
              ? IconButton(
                  padding: const EdgeInsets.all(0.0),
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _onItemAddClick(index),
                )
              : const SizedBox.shrink(),
          shouldDeleteVisible && _itemContentList.length > 1
              ? IconButton(
                  padding: const EdgeInsets.all(0.0),
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _onItemDeleteClick(index),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget buildTagDropDown(int index) {
    var tagList = widget.config.tagList;
    if (tagList == null) {
      return const SizedBox.shrink();
    }

    final List<DropdownMenuEntry<String>> colorEntries =
        <DropdownMenuEntry<String>>[];
    for (final String tag in tagList) {
      colorEntries.add(DropdownMenuEntry<String>(
          value: tag,
          label: tag,
          style: ButtonStyle(textStyle: MaterialStateTextStyle.resolveWith((states) => const TextStyle(fontSize: 12) )),
      ));
    }

    return DropdownMenu<String>(
      controller: _itemContentList[index].tagTextEditingController,
      // controller: colorController,
      label: const Text('Tag'),
      width: 110,
      textStyle: const TextStyle(fontSize: 12),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints.tight(const Size(110, 40)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dropdownMenuEntries: colorEntries,
    );
  }

  void _onItemAddClick(int index) {
    var nweItem = _ItemContent();
    nweItem.textEditingController.addListener(() {
      _updateFinalResult();
    });
    nweItem.tagTextEditingController.addListener(() {
      String text = nweItem.tagTextEditingController.text;
      _updateFinalResult();
    });

    setState(() {
      _itemContentList.insert(index + 1, nweItem);
      _updateFinalResult();
    });
  }

  void _onItemDeleteClick(int index) {
    _itemContentList[index].textEditingController.dispose();
    _itemContentList[index].tagTextEditingController.dispose();

    setState(() {
      _itemContentList.removeAt(index);
      _updateFinalResult();
    });
  }

  String _getResult() {
    String result = _itemContentList
        .map((e) => (e.tagTextEditingController.text.isNotEmpty ?'${e.tagTextEditingController.text}: ' : '') + e.textEditingController.text)
        .join('\n');
    return result;
  }

  void _updateFinalResult() {
    _resultTextController.text = _getResult();
  }

  void _onCancelClick(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _onConfirmClick(BuildContext context) {
    Navigator.of(context).pop();

    String result = _getResult();
    widget.onResult(result);
  }
}
