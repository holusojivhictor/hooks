enum StoryType {
  top('topstories'),
  best('beststories'),
  latest('newstories'),
  ask('askstories'),
  show('showstories');

  const StoryType(this.path);

  final String path;
}
