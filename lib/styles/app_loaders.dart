import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppLoaders {
  static appLoader() {
    return Center(
      child: Platform.isIOS
          ? const CupertinoActivityIndicator()
          : const CircularProgressIndicator(),
    );
  }

  static showProgressDialog({required BuildContext context, String? msg}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const CupertinoActivityIndicator(),
                const SizedBox(width: 10.0),
                Text(
                  msg!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                )
              ],
            ),
          );
        } else {
          return AlertDialog(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const CupertinoActivityIndicator(),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                    child: Text(
                  msg!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ))
              ],
            ),
          );
        }
      },
    );
  }


}
