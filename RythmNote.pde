class RhythmNote {
  int lane;
  float hitTime;
  float holdDuration;
  int state;
  float heldTime;

  RhythmNote(int lane, float hitTime, float holdDuration) {
    this.lane = lane;
    this.hitTime = hitTime;
    this.holdDuration = holdDuration;
    this.state = 0;
    this.heldTime = 0;
  }

}
