class JudgmentManager {

  void AddCombo()
  {
    currentCombo++;
    if (currentCombo > maxCombo) maxCombo = currentCombo;
  }
  
  void SetJudgmentInfo(String judgmentInfo) {
    lastJudgmentInfo = judgmentInfo;
    lastJudgmentInfoTime = songDuration;
  }
  
  void ShowJudgmentInfo() {
    pushMatrix();
    translate(width/2, height/2);
    textSize(72);
    textAlign(CENTER);
  
    float lastJudgmentInfoDur = 1;
    if (songDuration < lastJudgmentInfoTime + lastJudgmentInfoDur) {
      if (lastJudgmentInfo.compareToIgnoreCase("perfect") == 0) {
        fill(255, 255, 0);
      } else if (lastJudgmentInfo.compareToIgnoreCase("great") == 0) {
        fill(#F240BD);
      } else if (lastJudgmentInfo.compareToIgnoreCase("good") == 0) {
        fill(#79DE91);
      } else {
        fill(#F71D05);
      }
  
      text(lastJudgmentInfo, 0, -150);
  
      if (currentCombo > 0) {
        fill(255);
        textSize(60);
        text(currentCombo, 0, -80);
      }
    }
  
    popMatrix();
  }
}
