import 'package:dcli/dcli.dart';

// 定义了一个菜单类，用于在命令行界面中显示选择菜单
class Menu {
  final List<String> choices; // 存储菜单选项的列表。
  final String title; //菜单标题，默认为空字符串。

  Menu(this.choices, {this.title = ''});
  // 显示菜单并获取用户的选择。
  Answer choose() {
    // final dialog = CLI_Dialog(listQuestions: [
    //   [
    //     {'question': title, 'options': choices},
    //     'result'
    //   ]
    // ]);

    // final answer = dialog.ask();
    // final result = answer['result'] as String;
    print("");
    // 获取用户选择的结果，并通过 choices.indexOf(result) 获取该选项在 choices 列表中的索引。
    final result = menu(title, options: choices, defaultOption: choices[0]);
    final index = choices.indexOf(result);

    return Answer(result: result, index: index);
  }
}

class Answer {
  final String result;
  final int index;

  const Answer({required this.result, required this.index});
}
