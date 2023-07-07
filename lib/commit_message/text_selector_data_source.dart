
import 'dart:ffi';

import 'package:easy_commit_client/fundamental/type_selector.dart';
import 'package:easy_commit_client/fundamental/local_storage.dart';
import 'dart:convert';
import 'text_select_config.dart';


class TextSelectorDataSource {
  TextSelectorDataSource(this.name, this._defaultConfigList);

  final String name;
  List<TextSelectorItemConfig> configList = [];
  late bool _shouldRemember;
  final List<TextSelectorItemConfig> _defaultConfigList;
  int? _choice;

  void setup() {
    _setupDefaultConfig();
    configList = _readLastConfig();
    _shouldRemember = _readLastRemember();
    _choice = _readLastChoice();
  }

  void _setupDefaultConfig() {
    bool? isEverSetup = LocalStorage.store!.getBool("${name}_is_ever_setup");
    if (isEverSetup != null && isEverSetup) {
      return;
    }

    LocalStorage.store!.setBool("${name}_is_ever_setup", true);
    _writeLastConfigList(_defaultConfigList);
  }

  void addFirst(TextSelectorItemConfig config) {
    configList.insert(0, config);
    _writeLastConfigList(configList);
  }

  void addLast(TextSelectorItemConfig config) {
    configList.add(config);
    _writeLastConfigList(configList);
  }

  void delete(int index) {
    configList.removeAt(index);
    _writeLastConfigList(configList);
  }

  void update(TextSelectorItemConfig config) {
    var index = configList.indexWhere((element) => element.id == config.id);
    if (index != null) {
      delete(index);
    }

    addFirst(config);
  }

  Future<void> _writeLastConfigList(List<TextSelectorItemConfig> configList) async {
    String rawLastConfigStr = jsonEncode(configList);
    await LocalStorage.store!.setString("last_${name}_config", rawLastConfigStr);
  }

  List<TextSelectorItemConfig> _readLastConfig() {
    String? rawLastConfigStr = LocalStorage.store!.getString("last_${name}_config");
    if (rawLastConfigStr == null) {
      return [];
    }

    Iterable l = json.decode(rawLastConfigStr);
    List<TextSelectorItemConfig> configList = List<TextSelectorItemConfig>.from(l.map((model)=> TextSelectorItemConfig.fromJson(model)));

    return configList;
  }

  void reset() {
    _writeLastConfigList(_defaultConfigList);
    configList = _readLastConfig();
  }

  bool shouldRemember() {
    return _shouldRemember;
  }

  void setShouldRemember(bool shouldRemember) {
    _shouldRemember = shouldRemember;
    LocalStorage.store!.setBool("last_${name}_should_remember", shouldRemember);
  }

  bool _readLastRemember() {
    bool? rawShouldRemember = LocalStorage.store!.getBool("last_${name}_should_remember");
    return rawShouldRemember ?? true;
  }

  int? _readLastChoice() {
    int? lastChoice = LocalStorage.store!.getInt("last_${name}_choice");
    return lastChoice;
  }

  void setLastChoice(int? choice) {
    if (choice == null) {
      LocalStorage.store!.remove('last_${name}_choice');
      return;
    }
    LocalStorage.store!.setInt("last_${name}_choice", choice);
  }

  int? getLastChoice() {
    return _choice;
  }
}