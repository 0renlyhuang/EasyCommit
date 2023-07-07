
import 'dart:async';

import 'workspace_config.dart';
import 'package:easy_commit_client/fundamental/local_storage.dart';
import 'dart:convert';
import 'dart:math';


class WorkspaceDataSource {
  List<WorkspaceConfig> configList = [];
  StreamController<int> sizeSource = StreamController();
  late Stream<bool> emptySource;

  WorkspaceDataSource() {
    emptySource = sizeSource.stream.map((event) => event == 0).distinct();
  }

  void setup() {
    configList = _readLastConfig();
    sizeSource.sink.add(configList.length);
  }

  void addFirst(WorkspaceConfig config) {
    configList.insert(0, config);
    _writeLastConfigList(configList);

    sizeSource.sink.add(configList.length);
  }

  void addLast(String text) {
    List<int> ids = configList.map((e) => e.id).toList();


    int nextId = Random().nextInt(10000000);
    while (true) {
      if (!ids.contains(nextId)) {
        break;
      }
      nextId = Random().nextInt(10000000);
    }

    var config = WorkspaceConfig(nextId, text);
    addConfigLast(config);
  }

  void addConfigLast(WorkspaceConfig config) {
    configList.add(config);
    _writeLastConfigList(configList);

    sizeSource.sink.add(configList.length);
  }

  void delete(int index) {
    configList.removeAt(index);
    _writeLastConfigList(configList);

    sizeSource.sink.add(configList.length);
  }

  void update(WorkspaceConfig config) {
    var index = configList.indexWhere((element) => element.id == config.id);
    if (index != null) {
      delete(index);
    }

    addFirst(config);
  }

  Future<void> _writeLastConfigList(List<WorkspaceConfig> configList) async {
    String rawLastConfigStr = jsonEncode(configList);
    await LocalStorage.store!.setString("last_workspace_config", rawLastConfigStr);
  }

  List<WorkspaceConfig> _readLastConfig() {
    // return [
    //   WorkspaceConfig(1, "/Users/bytedance/Documents/Code/TikTok/dual_device/IESBroadcastExtensionKit"),
    //   WorkspaceConfig(2, "/Users/bytedance/Documents/Code/TikTok/dual_device/IESBroadcastExtensionKit"),
    //   WorkspaceConfig(3, "/Users/bytedance/Documents/Code/TikTok/dual_device/IESBroadcastExtensionKit"),
    //   WorkspaceConfig(4, "/Users/bytedance/Documents/Code/TikTok/dual_device/IESBroadcastExtensionKit"),
    // ];

    String? rawLastConfigStr = LocalStorage.store!.getString("last_workspace_config");
    if (rawLastConfigStr == null) {
      return [];
    }

    Iterable l = json.decode(rawLastConfigStr);
    List<WorkspaceConfig> configList = List<WorkspaceConfig>.from(l.map((model)=> WorkspaceConfig.fromJson(model)));

    return configList;
  }
}