void keyPressed() {
  if (HandleRebindKey()) return;

  if (menuState.compareToIgnoreCase("level") == 0) {
    // Judgment Handler / Hit
    int lineIndex = LaneFromKey(key);

    if (lineIndex >= 0) {
      if (gameInput[lineIndex]) return;
      gameInput[lineIndex] = true;
      println("Pressed " + key + " at " + songDuration);

      // Checking note to judge
      for (int i=0; i < chartSize; i++) {
        if (charts[i].lane != lineIndex || charts[i].state != 0) continue;

        // 0.8 < 1 < 1.2
        // 1 < 0.5 +
        if (charts[i].hitTime >= songDuration - maxGoodTime && charts[i].hitTime <= songDuration + maxGoodTime) {
          if (charts[i].hitTime >= songDuration - maxPerfectTime && charts[i].hitTime <= songDuration + maxPerfectTime)
          {
            // Perfect
            //println("Perfect");
            currentJudgment[0]++;
            judgmentManager.SetJudgmentInfo("Perfect");
          } else if (charts[i].hitTime >= songDuration - maxGreatTime && charts[i].hitTime <= songDuration + maxGreatTime)
          {
            // Great
            //println("Great");
            currentJudgment[1]++;
            judgmentManager.SetJudgmentInfo("Great");
          } else
          {
            // Good
            //println("Good");
            currentJudgment[2]++;
            judgmentManager.SetJudgmentInfo("Good");
          }
          judgmentManager.AddCombo();

          if (charts[i].state == 0)
          {
            if (charts[i].holdDuration > 0) charts[i].state = 2;
            else charts[i].state = 1;
          }
          break;
        }
      }
    }
  }
}

void keyReleased() {
  if (menuState.compareToIgnoreCase("level") == 0) {
    // Judgment Handler
    int lineIndex = LaneFromKey(key);

    if (lineIndex >= 0) {
      if (!gameInput[lineIndex]) return;
      gameInput[lineIndex] = false;

      for (int i = 0; i < chartSize; i++) {
        if (charts[i].lane != lineIndex || charts[i].state != 2) continue;
        // Held Duration
        charts[i].heldTime = songDuration - charts[i].hitTime;
        float holdJudgment = charts[i].heldTime / charts[i].holdDuration;
        print(holdJudgment);
        if (holdJudgment >= 0.35) {
          if (holdJudgment >= 0.90) {
            // Perfect Hold
            currentJudgment[0]++;
            charts[i].state = 1;
            judgmentManager.SetJudgmentInfo("Perfect");
          } else if (holdJudgment >= 0.65) {
            // Great Hold
            currentJudgment[1]++;
            charts[i].state = 3;
            judgmentManager.SetJudgmentInfo("Great");
          } else {
            // Good Hold
            currentJudgment[2]++;
            charts[i].state = 3;
            judgmentManager.SetJudgmentInfo("Good");
          }
          judgmentManager.AddCombo();
        } else {
          // Miss Hold
          currentJudgment[3]++;
          currentCombo = 0;
          charts[i].state = 3;
          judgmentManager.SetJudgmentInfo("Miss");
        }
        break;
      }
    }
  }
}
