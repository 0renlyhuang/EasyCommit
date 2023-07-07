import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class GitHookResult {

}

class GitHookResultSuccess extends GitHookResult {
  String path;

  GitHookResultSuccess(this.path);
}

class GitHookResultFailed extends GitHookResult {
  GitHookResultCode errorCode;

  GitHookResultFailed(this.errorCode);
}

enum GitHookResultCode {
  success,
  emptyFilePath,
  fileNotExist,
  wrongFile,
  notFileOrDir,
  createFileFailed,
}

class GitHookMgr {
  static String startTag = '#Easy Commit Script Start.';
  static String endTag = '#Easy Commit Script End.';

  Future<GitHookResult> _hookCommitMsgAtFile(File commitMsgFile) async {
    bool isExisted = await commitMsgFile.exists();
    if (!isExisted) {
      return GitHookResultFailed(GitHookResultCode.fileNotExist);
    }
    
    String fileName = commitMsgFile.uri.pathSegments.last;
    if (fileName == 'commit-msg.sample') {
      Directory dir = commitMsgFile.parent;
      return _hookCommitMsgAtDir(dir);
    }

    if (fileName == 'commit-msg') {
      return _hookCommitMsgFile(commitMsgFile);
    }

    return GitHookResultFailed(GitHookResultCode.wrongFile);
  }

  Future<GitHookResult> _hookCommitMsgFile(File commitMsgFile) async {
    bool isExisted = await commitMsgFile.exists();
    if (!isExisted) {
      return GitHookResultFailed(GitHookResultCode.fileNotExist);
    }

    await unhookCommitMsgFile(commitMsgFile);

    var lines = await commitMsgFile.readAsLines();
    List<String> newLines = lines;



    String appPath = Platform.resolvedExecutable;


    String cmd = '''
easy_commit_git_workspace=\$(git rev-parse --show-toplevel)
git_editing_file="\$easy_commit_git_workspace/\$1"
'$appPath' commit_message \$git_editing_file
status=\$?
if [ \$status -ne 0 ]; then
    echo "Easy Commit: Message not committed. Code:" \$status
    exit \$status
fi
''';

    List<String> scripts = [startTag, cmd, endTag];
    newLines.addAll(scripts);

    await commitMsgFile.writeAsString(newLines.join('\n'));

    return GitHookResultSuccess(commitMsgFile.path);
  }

  Future<GitHookResult> unhookCommitMsgFile(File commitMsgFile) async {
    bool isExisted = await commitMsgFile.exists();
    if (!isExisted) {
      return GitHookResultFailed(GitHookResultCode.fileNotExist);
    }

    var lines = await commitMsgFile.readAsLines();
    List<String> newLines = [];
    bool shouldDeleteLines = false;
    for (final line in lines) {
      if (line.contains(startTag)) {
        shouldDeleteLines = true;
        continue;
      }
      if (line.contains(endTag)) {
        shouldDeleteLines = false;
        continue;
      }
      if (shouldDeleteLines) {
        continue;
      }

      newLines.add(line);
    }

    await commitMsgFile.writeAsString(newLines.join('\n'));
    return GitHookResultSuccess(commitMsgFile.path);
  }

  Future<GitHookResult> _hookCommitMsgAtDir(Directory gitHookDir) async {
    bool isExisted = await gitHookDir.exists();
    if (!isExisted) {
      return GitHookResultFailed(GitHookResultCode.fileNotExist);
    }

    final List<FileSystemEntity> entities = await gitHookDir.list(recursive: false, followLinks: false).toList();
    final Iterable<File> files = entities.whereType<File>();
    File? hookFile = files.cast<File?>().firstWhere((element) => element?.uri.pathSegments.last == 'commit-msg', orElse: () => null);
    if (hookFile == null) {
      String hookFilePathToCreate = path.join(gitHookDir.path, 'commit-msg');
      hookFile = File(hookFilePathToCreate);

      try {
        hookFile = await hookFile.create();
        Process.run('chmod', ['+x', hookFilePathToCreate]);
      } on FileSystemException catch (e) {
        assert(false);
        return GitHookResultFailed(GitHookResultCode.createFileFailed);
      }
    }

    return _hookCommitMsgFile(hookFile);
  }

  Future<GitHookResult> hookCommitMsg(String path) async {
    if (path == null) {
      return GitHookResultFailed(GitHookResultCode.emptyFilePath);
    }

    bool isDir = await FileSystemEntity.isDirectory(path);
    if (isDir) {
      Directory dir = Directory(path);
       return _hookCommitMsgAtDir(dir);
    }

    bool isFile = await FileSystemEntity.isFile(path);
    if (isFile) {
      File file = File(path);
      return _hookCommitMsgAtFile(file);
    }

    assert(false);
    return GitHookResultFailed(GitHookResultCode.notFileOrDir);
  }
}