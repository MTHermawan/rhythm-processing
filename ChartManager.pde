class ChartManager {

  void SetupChart() {
    if (selectedSong == null || !selectedSong.isValid()) return;
    ResetChart();

    songOffset = 7;   // beat ke-0 pola loop di bawah (detik)

    File chartFile = GetDataFile("songs/" + selectedSong.id + "/chart.json");
    if (chartFile.exists())
    {
      JSONArray chartJson = loadJSONArray(chartFile);
      for (int i = 0; i < chartJson.size(); i++) {
        JSONArray note = chartJson.getJSONArray(i);
        AddChart(note.getFloat(0), note.getInt(1), note.getFloat(2));
      }
    }

    for (int i = 0; i < 470; i += 2)
    {
      int phase = ((i + 4) / 2) % 4;
      int a = (phase == 2) ? 0 : (phase == 3) ? 1 : (phase == 0) ? 2 : 3;
      int b = (a + 2) % 4;

      AddBeat(i, a, 1);       // hold 1 beat
      AddBeat(i, b, 0);
      AddBeat(i + 1, b, 0);
      println("a");
    }

    RecalculateFullCombo();

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


  void ResetChart() {
    charts = new RhythmNote[9999];
    chartSize = 0;
  }

  float soundOffset = 0.165;

  // soundOffset (tetap) + Music Offset dari Settings (ms -> detik)
  float TotalOffset() {
    return soundOffset + (musicOffsetMs / 1000.0);
  }

  // Beat -> detik (tanpa offset, offset ditambahkan di AddChart)
  float BeatToTime(float beat) {
    return songOffset + beat * (60.0 / selectedSong.bpm);
  }

  // Tulis not dalam satuan beat (bisa pecahan), hold juga dalam beat
  void AddBeat(float beat, int lineIndex, float holdBeats) {
    AddChart(BeatToTime(beat), lineIndex, holdBeats * (60.0 / selectedSong.bpm));
  }

  void AddChart(float hitTime, int lineIndex, float holdDuration) {
    charts[chartSize] = new RhythmNote(
      hitTime + TotalOffset(),
      lineIndex,
      holdDuration
      );
    chartSize++;
  }

  void RecalculateFullCombo() {
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
    }
  }
}
