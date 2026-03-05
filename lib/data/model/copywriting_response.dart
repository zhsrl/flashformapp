class CopywritingResponse {
  final String primaryText;
  final List<String> alternatives;
  final String type; // 'title', 'description', 'button', 'success', 'whatsapp', 'redirect'

  CopywritingResponse({
    required this.primaryText,
    required this.alternatives,
    required this.type,
  });
}
