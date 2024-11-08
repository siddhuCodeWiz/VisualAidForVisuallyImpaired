void main() {
  String response = "In the video, a man is seen playing baseball on a dirt field. As the frames change, it appears that another person joins him, and they play together. At one point, one of the men is simply walking across the field. The final scene shows two boys engaged in the game of baseball on the same dirt field.";

  List<String> l;
  l = response.split(RegExp(r'[.!?]\s*'));

  // Print the sentences to verify
  for (int i = 0; i < l.length; i++) {
    print('Sentence $i: "${l[i].trim()}"');
  }
}
