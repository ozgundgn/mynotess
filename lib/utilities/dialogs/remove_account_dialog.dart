import 'package:flutter/cupertino.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showRemoveAccountDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "Remove Account",
    content: "Are you sure you want to remove this account?",
    optionsBuilder: () => {
      "OK": true,
      "Cancel": false,
    },
  ).then(
    (value) => value ?? false,
  );
}
