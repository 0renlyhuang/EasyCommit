import 'dart:io';
import 'dart:math';

import 'package:easy_commit_client/commit_message/text_selector_data_source.dart';
import 'package:easy_commit_client/fundamental/add_item_dialog.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:easy_commit_client/fundamental/type_selector.dart';
import 'package:easy_commit_client/commit_message/text_select_config.dart';

class TextSelectorWidget extends StatefulWidget {
  const TextSelectorWidget({Key? key, required this.name, required this.defaultList, required this.addItemInstruction, required this.onTextChanged, required this.onGetAddDialogConfig }) : super(key: key);

  @override
  _TextSelectorWidgetState createState() => _TextSelectorWidgetState();

  final String name;
  final List<TextSelectorItemConfig> defaultList;
  final String addItemInstruction;
  final ValueChanged<String?> onTextChanged;
  final AddDialogConfig Function() onGetAddDialogConfig;

}

class _TextSelectorWidgetState extends State<TextSelectorWidget> {
  late final TextSelectorDataSource _dataSource;
  final _selectorKey = GlobalKey<TypeSelectorState>();

  @override
  void initState() {
    super.initState();

    _dataSource = TextSelectorDataSource(widget.name, widget.defaultList);
    _dataSource.setup();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TypeSelector(key: _selectorKey, name: widget.name, shouldRememberInitValue: getShouldRememberLastChoiceInitValue(), defaultSelectedIndex: _getLastChoice(),
        onSelected: _onSelected, onAdd: _onAddClick, onDelete: _onDelete, onReset: _onReset, onRememberChanged: _onRememberChanged, onGetList: _onGetList, addInstruction: widget.addItemInstruction);
  }

  int? _getLastChoice() {
    if (_dataSource.shouldRemember()) {
      return _dataSource.getLastChoice();
    }

    return null;
  }

  List<TextSelectorItemConfig> _onGetList() {
    return _dataSource.configList;
  }

  void _onSelected(int? index) {
    _dataSource.setLastChoice(index);

    if (index == null) {
      widget.onTextChanged(null);
      return;
    }

    var config = _dataSource.configList[index];
    widget.onTextChanged(config.text);
  }

  void _onAddClick() {
    var dialogConfig = widget.onGetAddDialogConfig();
    var addDialogWidget = AddItemDialogWidget(config: dialogConfig, onResult: (result) => {
      _onAdd(result)
    });
    addDialogWidget.show(context);
  }

  void _onAdd(String text) {
    List<int> ids = _dataSource.configList.map((e) => e.id).toList();
    ids.add(-1);


    int nextId = Random().nextInt(10000000);
    while (true) {
      if (!ids.contains(nextId)) {
        break;
      }
      nextId = Random().nextInt(10000000);
    }

    var config = TextSelectorItemConfig(nextId, text, "", true);
    _dataSource.addLast(config);

    _selectorKey.currentState?.handleAddItem(_dataSource.configList.length - 1, text);
  }

  void _onDelete(int index) {
    _dataSource.delete(index);
  }

  void _onReset() {
    _dataSource.reset();
  }

  bool getShouldRememberLastChoiceInitValue() {
    return _dataSource.shouldRemember();
  }

  void _onRememberChanged(bool shouldRemember) {
    _dataSource.setShouldRemember(shouldRemember);
  }
}