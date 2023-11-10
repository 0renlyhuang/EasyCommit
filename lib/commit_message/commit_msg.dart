import 'dart:async';
import 'dart:io';

import 'package:easy_commit_client/commit_message/text_select_config.dart';
import 'package:easy_commit_client/fundamental/add_item_dialog.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import '../fundamental/type_selector.dart';
import 'package:easy_commit_client/commit_message//text_selector.dart';

class CommitMsgPage extends StatefulWidget {
  String? file;

  CommitMsgPage({Key? key, required this.file }) : super(key: key);




  @override
  _CommitMsgPageState createState() => _CommitMsgPageState();
}

class _CommitMsgPageState extends State<CommitMsgPage> {
  final TextEditingController _subjectController = TextEditingController(text: '');
  final TextEditingController _bodyController = TextEditingController(text: '');
  final TextEditingController _commitMsgController = TextEditingController(text: '');

  String? _type;
  String? _scope;
  String _subject= "";
  String _body= "";
  String? _footer;

  bool _isFileProvided = false;

  @override
  void initState() {
    super.initState();
    _isFileProvided = (widget.file != null);

    _subjectController.addListener(() {
      _subject = _subjectController.text;
      _updateMsgText();
    });

    _bodyController.addListener(() {
      _body = _bodyController.text;
      _updateMsgText();
    });

    if (_isFileProvided) {
      readMsgFromCommitMsgFile();
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      Column(
        children: [
          Expanded(child:
            MultiSplitView(
              axis: Axis.vertical,
              initialAreas: [Area(weight: 0.2), Area(weight: 0.4), Area(weight: 0.15), Area(weight: 0.25)],
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.top,
                    readOnly: true,
                    expands: true,
                    maxLines: null,
                    controller: _commitMsgController,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.fromLTRB(8, 8.0, 8, 8.0),
                      isDense: true, // and add this line
                    ),
                  ),
                ),


                Container(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: MultiSplitView(
                      initialAreas: [Area(weight: 0.3), Area(weight: 0.2)],
                      children: [

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: const BorderRadius.all(Radius.circular(6)),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: TextSelectorWidget(name: 'Type', defaultList: _getDefaultTypeList(), addItemInstruction: 'Enter type', onTextChanged: _onTypeChanged, onGetAddDialogConfig: _onGetAddTypeDialogConfig),
                        ),

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: const BorderRadius.all(Radius.circular(6)),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: TextSelectorWidget(name: 'Scope', defaultList: const [], addItemInstruction: 'Enter scope', onTextChanged: _onScopeChanged, onGetAddDialogConfig: _onGetAddScopeDialogConfig),
                        ),

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: const BorderRadius.all(Radius.circular(6)),
                          ),
                          padding: const EdgeInsets.all(4),
                          child:
                          Column(
                            children: [
                              const Text("Subject"),
                              Expanded(
                                  child: TextField(
                                    controller: _subjectController,
                                    maxLines: null,
                                    style: const TextStyle(fontSize: 14, color: Colors.black),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter subject',
                                      contentPadding: EdgeInsets.fromLTRB(8, 8.0, 8, 8.0),
                                      isDense: true, // and add this line
                                    ),
                                  ),


                              )
                            ],
                          ),

                        ),
                      ]
                  ),
                ),

                Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                      ),
                      padding: const EdgeInsets.all(4),
                      child:
                      Column(
                        children: [
                          const Text("Body"),
                          Expanded(
                              child: TextField(
                                controller: _bodyController,
                                maxLines: null,
                                style: const TextStyle(fontSize: 14, color: Colors.black),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter body if needed',
                                  contentPadding: EdgeInsets.fromLTRB(8, 8.0, 8, 8.0),
                                  isDense: true, // and add this line
                                ),
                              ),
                          )
                        ],
                      ),
                    ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TextSelectorWidget(name: 'Footer', defaultList: const [], addItemInstruction: 'Enter footer', onTextChanged: _onFooterChanged, onGetAddDialogConfig: _onGetAddFooterDialogConfig),
                  ),
                ),

              ],
            )
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child:
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onCancelClick,
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isFileProvided ? onSubmitClick : null,
                  child: const Text("Submit"),
                ),
              ],
            ),
          )

        ],
      );

  }

  void _onTypeChanged(String? commitType) {
    _type = commitType;
    _updateMsgText();
  }

  void _onScopeChanged(String? commitScope) {
    _scope = commitScope;
    _updateMsgText();
  }

  void _onFooterChanged(String? commitFooter) {
    _footer = commitFooter;
    _updateMsgText();
  }


  void onSubmitClick() async {
    if (widget.file == null) return;

    // Write the file
    await File(widget.file!).writeAsString(_buildMsg());

    exit(0);
  }

  void onCancelClick() {
    exit(1);
  }


  void readMsgFromCommitMsgFile() async {
    String text = await File(widget.file!).readAsString();
    if (text.isNotEmpty && text.endsWith('\n')) {
      text = text.substring(0, text.length - 1);
    }
    _subjectController.text = text;
  }

  String _buildMsg() {
    var msgArray = [];
    String header = '';

    bool shouldAddColon = false;
    String? commitType = _type;
    if (commitType != null) {
      header = commitType;
      shouldAddColon = true;
    }

    String? scope = _scope;
    if (scope != null) {
      header += '($scope)';
      shouldAddColon = true;
    }

    if (shouldAddColon) {
      header += ': ';
    }

    header += _subject;


    msgArray.add(header);

    if (_body.isNotEmpty) {
      msgArray.add(_body);
    }

    if (_footer != null) {
      msgArray.add(_footer);
    }

    String msg = msgArray.join('\n\n');
    return msg;
  }

  void _updateMsgText() {
    _commitMsgController.text = _buildMsg();
  }


  List<TextSelectorItemConfig> _getDefaultTypeList() {
    return [
      TextSelectorItemConfig(1, "feat", "introduces a new feature to the codebase", false),
      TextSelectorItemConfig(2, "fix", "patches a bug in your codebase", false),
      TextSelectorItemConfig(3, "build", "changes that affect the build system or external dependencies", false),
      TextSelectorItemConfig(4, "docs", "documentation only changes", false),
      TextSelectorItemConfig(5, "refactor", "a code change that neither fixes a bug nor adds a feature", false),
      TextSelectorItemConfig(6, "perf", "a code change that improves performance", false),
      TextSelectorItemConfig(7, "style", "changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)", false),
      TextSelectorItemConfig(8, "test", "adding missing tests or correcting existing tests", false),
      TextSelectorItemConfig(9, "ci", "changes to the CI configuration files and scripts", false),
      TextSelectorItemConfig(10, "revert", "reverts a previous commit", false),
      TextSelectorItemConfig(11, "chore", "changes to the build process or auxiliary tools and libraries such as documentation generation", false),
    ];
  }

  AddDialogConfig _onGetAddTypeDialogConfig() {
    return AddDialogConfig(title: 'Add New Type', contentInstruction: 'commit type', addable: false);
  }

  AddDialogConfig _onGetAddScopeDialogConfig() {
    return AddDialogConfig(title: 'Add New Scope', contentInstruction: 'commit scope', addable: false);

  }

  AddDialogConfig _onGetAddFooterDialogConfig() {
    return AddDialogConfig(
        title: 'Add New Footer',
        contentInstruction: 'detail',
        addable: true,
        resultLabel: 'Footer',
        tagList:[
          'BREAKING CHANGE',
          'Closes',
          'Implements',
          'Reviewed-by',
          'Refs'
        ]
    );
  }
}