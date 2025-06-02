Map<String, String> parsePlantResponse(String response) {
  Map<String, String> result = {};
  final RegExp regExp = RegExp(
    r'6\. Basic Care Schedule:([\s\S]*?)'
    r'7\. Weekly Watering Schedule:([\s\S]*)',
    dotAll: true
  );
  final match = regExp.firstMatch(response);
  if (match != null) {
    result = {
      'care_schedule': match.group(1)?.trim() ?? 'N/A',
      'weekly_watering': match.group(2)?.trim() ?? 'N/A',
    };
  }
  try {
    final lines = response.split('\n');
    for (String line in lines) {
      if (line.startsWith('1. Common Name:')) {
        result['common_name'] = line.split(': ')[1].trim();
      } else if (line.startsWith('2. Plant Family:')) {
        result['plant_family'] = line.split(': ')[1].trim();
      } else if (line.startsWith('3. External Description:')) {
        result['description'] = line.split(': ')[1].trim();
      } else if (line.startsWith('4. Ornamental Type:')) {
        result['ornamental_type'] = line.split(': ')[1].trim();
      } else if (line.startsWith('5. Common Diseases/Pests:')) {
        result['diseases'] = line.split(': ')[1].trim();
      }
    }
  } catch (e) {
    print('Parsing error: $e');
  }
  return result;
}