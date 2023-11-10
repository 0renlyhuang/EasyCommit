import 'dart:io';
import 'dart:math';

import 'workspace_data_source.dart';
import 'package:easy_commit_client/fundamental/simple_list.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'workspace_config.dart';
import 'git_hook_mgr.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as xPath;
import 'package:easy_commit_client/fundamental/file_system_helper.dart';


class WorkspaceListWidget extends StatefulWidget {
  WorkspaceListWidget({Key? key, required this.gitHookMgr, required this.dataSource }) : super(key: key);

  static of(BuildContext context, {bool root = false}) => root
      ? context.findRootAncestorStateOfType<WorkspaceListWidgetState>()
      : context.findAncestorStateOfType<WorkspaceListWidgetState>();

  @override
  WorkspaceListWidgetState createState() => WorkspaceListWidgetState();

  GitHookMgr gitHookMgr;
  final WorkspaceDataSource dataSource;
}

class WorkspaceListWidgetState extends State<WorkspaceListWidget> {

  final _simpleListKey = GlobalKey<SimpleListState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleList(key: _simpleListKey, onDelete: _onDelete, onFix: _onFix, onOpen: _onOpen, onGetList: _onGetList);
  }

  List<SimpleListItem> _onGetList() {
    return widget.dataSource.configList.map((e) => SimpleListItem(e.id, e.text)).toList();
  }

  void _onDelete(int index) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
      title: const Text('Delete Workspace'),
      content: const Text('Confirm to delete this workspace?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _doDelete(index),
          child: const Text('Delete'),
        ),
      ],
    ),
    );
  }

  void _doDelete(int index) {
    String path = widget.dataSource.configList[index].text;
    widget.gitHookMgr.unhookCommitMsgFile(File(path));

    _simpleListKey.currentState?.deleteItemAt(context, index);
    widget.dataSource.delete(index);

    Navigator.pop(context, 'Delete');
  }

  void _onFix(int index) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Fix Workspace'),
        content: const Text('Confirm to fix this workspace?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _doFix(index),
            child: const Text('Fix'),
          ),
        ],
      ),
    );
  }

  void _doFix(int index) {
    String path = widget.dataSource.configList[index].text;
    widget.gitHookMgr.hookCommitMsg(path);

    Navigator.pop(context, 'Fix');
  }

  void _onOpen(int index) {
    String path = widget.dataSource.configList[index].text;
    FileSystemHelper.openFolder(path);
  }

  void handleListAction(SimpleListAction action) async {
    SimpleListState? simpleListState = _simpleListKey.currentState;
    if (simpleListState == null) {
      return;
    }


    if (action is SimpleListActionAdd) {
      GitHookResult result = await widget.gitHookMgr.hookCommitMsg(action.text);
      if (result is GitHookResultSuccess) {
        int index = widget.dataSource.configList.length;
        widget.dataSource.addLast(result.path);
        simpleListState.addItemAt(index);
      }

      return;
    }

    if (action is SimpleListActionDelete) {
      simpleListState.deleteItemAt(context, action.index);
      return;
    }
  }

}