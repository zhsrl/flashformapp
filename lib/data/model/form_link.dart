class FooterLink {
  final String label;
  final String url;

  FooterLink({required this.label, required this.url});

  FooterLink copyWith({String? label, String? url}) {
    return FooterLink(
      label: label ?? this.label,
      url: url ?? this.url,
    );
  }
}