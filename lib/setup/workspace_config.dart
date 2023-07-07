

class WorkspaceConfig {
  int id;
  String text;

  WorkspaceConfig(this.id, this.text);

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text
  };

  WorkspaceConfig.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'];
}