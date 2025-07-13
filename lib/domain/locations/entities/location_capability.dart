enum LocationCapability {
  slide('Slide'),
  swing('Swing'),
  sandbox('Sandbox'),
  unknown('Unknown');

  const LocationCapability(this.displayName);

  final String displayName;
}

enum LocationSize {
  small('Small'),
  medium('Medium'),
  large('Large'),
  unknown('Unknown');

  const LocationSize(this.displayName);

  final String displayName;
}
