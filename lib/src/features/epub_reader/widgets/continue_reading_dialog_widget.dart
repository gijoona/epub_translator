import 'package:epub_translator/generated/l10n.dart';
import 'package:flutter/material.dart';

class ContinueReadingDialog extends StatelessWidget {
  const ContinueReadingDialog({
    super.key,
    required PageController pageController,
    required this.jsonData,
  }) : _pageController = pageController;

  final PageController _pageController;
  final dynamic jsonData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
      height: 162,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              S.of(context).dialogTitle('continueReading'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: FilledButton(
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all(const Size(20, 70)),
                      shape: WidgetStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Text(
                        S.of(context).dialogActionBtns('first'),
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.bodyLarge!.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all(const Size(30, 70)),
                      shape: WidgetStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      _pageController.jumpToPage(jsonData['last_view_index']);
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Text(
                        S.of(context).dialogActionBtns('continue'),
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.bodyLarge!.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
