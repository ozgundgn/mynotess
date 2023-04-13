import 'package:flutter/cupertino.dart';
import 'generic_dialog.dart';

Future<void> showErrorDialog({
  required BuildContext context,
  required String text,
}) {
  return showGenericDialog(
      context: context,
      title: "An error occured",
      content: text,
      optionsBuilder: () => {
            'OK': null,
          });
}
