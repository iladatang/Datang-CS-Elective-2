String shoeEmoji(String category) {
  switch (category.toLowerCase()) {
    case 'running':
      return '🏃';
    case 'lifestyle':
      return '👟';
    case 'trail':
      return '🥾';
    case 'classic':
      return '🩴';
    default:
      return '👟';
  }
}
