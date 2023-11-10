import 'dart:convert';

class TextSelectorItemConfig {
  int id;
  String text;
  String desc;
  bool canDelete;

  TextSelectorItemConfig(this.id, this.text, this.desc, this.canDelete);

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'desc': desc,
    'canDelete': canDelete
  };

  TextSelectorItemConfig.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'],
        desc = json['desc'],
        canDelete = json['canDelete'];
}
