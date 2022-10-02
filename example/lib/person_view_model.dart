class PersonViewModel {
  final String name;
  final bool isUser;

  PersonViewModel({required this.isUser, required this.name});

  factory PersonViewModel.fromJson(final Map<String, dynamic> json) =>
      PersonViewModel(
        isUser: json['isUser'],
        name: json['fullName'],
      );
}
