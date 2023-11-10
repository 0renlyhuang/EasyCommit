import 'dart:io';

import 'package:easy_commit_client/fundamental/simple_list.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'workspace_list.dart';
import 'git_hook_mgr.dart';
import 'workspace_data_source.dart';

class SetupPage extends StatefulWidget {

  SetupPage({Key? key }) : super(key: key);


  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  GitHookMgr gitHookMgr = GitHookMgr();
  final _workspaceListKey = GlobalKey<WorkspaceListWidgetState>();
  final WorkspaceDataSource _dataSource = WorkspaceDataSource();

  @override
  void initState() {
    super.initState();

    _dataSource.setup();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    super.dispose();
  }

  Widget buildList() {
    return Expanded(child:
    Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      padding: const EdgeInsets.all(4),
      child: WorkspaceListWidget(key: _workspaceListKey, gitHookMgr: gitHookMgr, dataSource: _dataSource),
    ),
    );
  }

  Widget buildEmptyGuide() {
    return Expanded(child:
    Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      padding: const EdgeInsets.all(4),
      child: Center(
          child: Text(_getSelectTooltips())
      ),
    ),
    );
  }
  
  Widget buildContent() {
    return StreamBuilder(stream: _dataSource.emptySource, initialData: true, builder: (context, AsyncSnapshot<bool> isEmptyList) {
      return isEmptyList.data! ? buildEmptyGuide() : buildList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      Column(
        children: [
          buildContent(),
          Container(
            margin: const EdgeInsets.all(10.0),
            child:
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onQuitClick,
                  child: const Text("Quit"),
                ),
                const SizedBox(width: 8),
                Tooltip(
                    message: _getSelectFileTooltips(),
                    child: ElevatedButton(
                      onPressed:  onSelectClick,
                      child: const Text("Select File"),
                    )
                ),
                const SizedBox(width: 8),
                Tooltip(
                    message: _getSelectFolderTooltips(),
                    child: ElevatedButton(
                      onPressed:  onSelectFolderClick,
                      child: const Text("Select Folder"),
                    )
                )
              ],
            ),
          )

        ],
      );

  }

  void onSelectClick() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) {
      return;
    }

    var filePath = result.files.single.path;
    if (filePath == null) {
      return;
    }

    if (_dataSource.configList.isEmpty) {
      _onAdd(filePath);
    } else {
      SimpleListActionAdd addAction = SimpleListActionAdd(filePath);
      _workspaceListKey.currentState?.handleListAction(addAction);
    }
  }

  void onSelectFolderClick() async {
    String? folderPath = await FilePicker.platform.getDirectoryPath();

    if (folderPath == null) {
      return;
    }

    if (_dataSource.configList.isEmpty) {
      _onAdd(folderPath);
    } else {
      SimpleListActionAdd addAction = SimpleListActionAdd(folderPath);
      _workspaceListKey.currentState?.handleListAction(addAction);
    }
  }

  void _onAdd(String path) async {
    GitHookResult result = await gitHookMgr.hookCommitMsg(path);
    if (result is GitHookResultSuccess) {
      _dataSource.addLast(result.path);
      return;
    }

    if (result is GitHookResultFailed) {
      String? toast;
      switch (result.errorCode) {
        case GitHookResultCode.emptyFilePath: {
          toast = 'Path is empty.';
          break;
        }
        case GitHookResultCode.fileNotExist: {
          toast = 'File not exist.';
          break;
        }
        case GitHookResultCode.wrongFile: {
          toast = 'Select a wrong file.';
          break;
        }
        case GitHookResultCode.notFileOrDir: {
          toast = 'Selected item is not file or directory.';
          break;
        }
        case GitHookResultCode.createFileFailed: {
          toast = 'Create file failed.';
          break;
        }
        default: {
          break;
        }
      }

      if (toast == null) {
        return;
      }
      _showToast(toast);
    }
  }

  void _showToast(String toast) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(toast),
    ));
  }

  void onQuitClick() {
    exit(-1);
  }

  String _getSelectTooltips() {
    if (Platform.isMacOS) {
      return 'Select commit-msg, commit-msg.sample or git hooks folder to setup.\nPress Cmd + Shift + . to show hidden files.';
    }

    return 'Select commit-msg, commit-msg.sample or git hooks folder to setup.';
  }

  String _getSelectFileTooltips() {
    if (Platform.isMacOS) {
      return 'Select commit-msg or commit-msg.sample to setup.\nPress Cmd + Shift + . to show hidden files.';
    }

    return 'Select commit-msg or commit-msg.sample to setup.';
  }

  String _getSelectFolderTooltips() {
    if (Platform.isMacOS) {
      return 'Select git hooks folder to setup.\nPress Cmd + Shift + . to show hidden files.';
    }

    return 'Select git hooks folder to setup.';
  }
}