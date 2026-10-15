class ChartManager {

  ChartManager() {
  }

  void SetupChart(String songName) {
    ResetChart();
    if (songName.compareToIgnoreCase("bad_apple") == 0) {
      songBpm = 138;
      float beatTime = 60/songBpm;
  
      // 1
      AddChart(0, 1.35, 0.9); // 2A
      AddChart(3, 1.35, 0);// 2B
      AddChart(2, 1.8, 0); // 1
  
      // 2
      AddChart(1, 2.25, 0); // 1
      AddChart(2, 2.65, 0); // 2A
      AddChart(3, 2.65, 0); // 2B
      AddChart(0, 2.76, 0); // 2A
      AddChart(1, 2.76, 0); // 2B
      AddChart(2, 2.87, 0); // 2A
      AddChart(3, 2.87, 0); // 2B
      AddChart(0, 2.98, 0); // 2A
      AddChart(1, 2.98, 0); // 2B
  
      // 3
      AddChart(2, 3.09, 0); // 2A
      AddChart(3, 3.09, 0.21); // 2B
  
      //float time = 4;
      //int line = 4;
      //for (int i=0; i < 500; i++)
      //{
      //  time += 0.025;
      //  if (i % 4 == 0) time += 0.1;
  
      //  line = (line + 4 - 1) % 4;
      //  AddChart(line, time, 0);
      //}
  
      AddChart(0, 3.55, 0.2);
      AddChart(1, 3.55, 0);
      AddChart(2, 3.96, 0);
      AddChart(3, 3.96, 0.24);
  
      // 4
      AddChart(3, 4.4, 0.2);
      AddChart(2, 4.6, 0.2);
      AddChart(1, 4.8, 0.2);
  
      // 5
      AddChart(0, 5, 0.25);
      AddChart(2, 5.25, 0);
      AddChart(3, 5.35, 0.35);
      AddChart(2, 5.7, 0);
      AddChart(1, 5.8, 0);
      AddChart(0, 5.8, 0.2);
  
      // 6
      AddChart(2, 6.15, 0);
      AddChart(3, 6.15, 0);
      AddChart(0, 6.25, 0);
      AddChart(1, 6.25, 0);
      AddChart(2, 6.35, 0);
      AddChart(3, 6.35, 0);
      AddChart(0, 6.45, 0);
      AddChart(1, 6.45, 0);
      AddChart(2, 6.55, 0);
      AddChart(3, 6.55, 0);
  
  
      for (int i=0; i < 470; i++)
      {
        if (i % 2 == 0) {
          if (((i + 4) / 2) % 4 == 2) {
            AddChart(0, 7 + (beatTime * i), beatTime);
            AddChart(2, 7 + (beatTime * i), 0);
            AddChart(2, 7 + (beatTime * (i+1)), 0);
          } else if (((i + 4) / 2) % 4 == 3) {
            AddChart(1, 7 + (beatTime * i), beatTime);
            AddChart(3, 7 + (beatTime * i), 0);
            AddChart(3, 7 + (beatTime * (i+1)), 0);
          } else if (((i + 4) / 2) % 4 == 0) {
            AddChart(2, 7 + (beatTime * i), beatTime);
            AddChart(0, 7 + (beatTime * i), 0);
            AddChart(0, 7 + (beatTime * (i+1)), 0);
          } else {
            AddChart(3, 7 + (beatTime * i), beatTime);
            AddChart(1, 7 + (beatTime * i), 0);
            AddChart(1, 7 + (beatTime * (i+1)), 0);
          }
        }
      }
    }
  
    fullCombo = 0;
    for (int i=0; i < chartSize; i++) {
      if (charts[i].holdDuration > 0) fullCombo += 2;
      else fullCombo += 1;
  
      // Hit Guide
      boolean guideSoundExist = false;
      for (int j = 0; j < guideTimeSize; j++) {
        if (charts[i].hitTime == guideTimes[j][0])
        {
          guideSoundExist = true;
        }
      }
      if (!guideSoundExist)
      {
        guideTimes[guideTimeSize][0] = charts[i].hitTime;
        guideTimes[guideTimeSize][1] = 0;
        guideTimeSize++;
      }
  
      // Release Guide
      //if (charts[i][2] > 0) {
      //  guideSoundExist = false;
      //  for (int j = 0; j < guideTimeSize; j++) {
      //    if (charts[i][1] + charts[i][2] == guideTimes[j][0])
      //    {
      //      guideSoundExist = true;
      //    }
      //  }
      //  if (!guideSoundExist)
      //  {
      //    guideTimes[guideTimeSize][0] = charts[i][1] + charts[i][2];
      //    guideTimes[guideTimeSize][1] = 0;
      //    guideTimeSize++;
      //  }
      //}
    }
  }
  
  void ResetChart() {
  charts = new RhythmNote[9999];
  chartSize = 0;
  }
  
  float soundOffset = 0.165;
  void AddChart(int lineIndex, float judgmentTime, float holdDuration) {
    charts[chartSize] = new RhythmNote(
      lineIndex,
      judgmentTime + soundOffset,
      holdDuration
    );
    chartSize++;
  }
}
