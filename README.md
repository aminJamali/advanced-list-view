<!-- 
 FlutterListView with additional features.
    try again widget
    ![](https://media.giphy.com/media/nonr3lyQbUB4CsOWsp/giphy.gif)
    empty widget    
    ![](https://media.giphy.com/media/P3ucf7uXe2hNonG5NB/giphy.gif)
    refresh indicator
    ![](https://media.giphy.com/media/rloEO09h7dtQgieHxX/giphy.gif)
    load more items loading
    ![](https://media.giphy.com/media/LMsUaAa0B7pyClcPKF/giphy.gif)

-->


## Features

- flutter list view
- pagination option (infinity scroll)
- view model detection using generic types
- refresh option
- error handling while getting data
- show empty widget when list is empty
- show loading widget while getting data
- easy usage
- makes your code clean and readable

## Getting started

Import:
```dart
    import 'package:advanced_list_view/advanced_list_view.dart';
```

## Usage

Define your listview (PersonViewModel is your model which will return to you on itemBuilder
    and you can use current item value):


```dart
AdvancedListView<PersonViewModel>(
    items: listItems,
    canRefresh: true,
    showLoadingWidget: showLoadingWidget,
    showErrorWidget: showErrorWidget,
    shrinkWrap: true,
    showEmptyWidget: showEmptyWidget,
    onRefresh: _onRefresh,
    onLoadMoreData: _onLoadMoreData,
    hasMoreData: _hasMoreData,
    itemBuilder:
    (final BuildContext context, final int index, final item) =>
    ListTile(
    title: Text(item.name),
    ),
),   
      
```
your onLoadMoreData function that will be called when user scrolls to end of list
and offset value will be increment: 

```Dart
    Future<void> _onLoadMoreData() async {
  setState(() {
    showErrorWidget = false;
    showEmptyWidget = false;
    showLoadingWidget = true;
  });
  final response = await Dio()
      .get('https://retoolapi.dev/cXYQ5x/data?_page=$offset&_limit=$limit');

  if (offset == 1) {
    listItems.clear();
  }

  List<PersonViewModel> receivedItems = [];

  receivedItems = (response.data as List)
      .map(
        (final e) => PersonViewModel.fromJson(e as Map<String, dynamic>),
  )
      .toList();

  listItems.addAll(receivedItems);

  setState(() {
    showLoadingWidget = false;
  });
  if (receivedItems.length < limit) {
    _hasMoreData = false;
  }
  offset++;
}    

```     

Define your refresh function that will be called when user pulls list down
or when tapes on retry widget:

```Dart
Future<void> _onRefresh() async {
      listItems.clear();
      offset = 1;
      setState(() {
        showLoadingWidget = true;
        showErrorWidget = false;
        showEmptyWidget = false;
      });
      _onLoadMoreData();
}
```

## Additional information

for more info checkout github repository: https://github.com/aminJamali/advanced-list-view.git
