class RhythmNote {
  float hitTime;
  int lane;
  float holdDuration;
  
  private int state;
  private float heldTime;

  RhythmNote(float hitTime, int lane, float holdDuration) {
    this.hitTime = hitTime;
    this.lane = lane;
    this.holdDuration = holdDuration;
    this.state = 0;
  }
  
  public void SetState(int newState) {
    // Info: 
    this.state = newState;
  }
  
  public void SetHeldTime(float heldTime) {
    if (heldTime > 0) return; 
    this.heldTime = heldTime;
  }
}
