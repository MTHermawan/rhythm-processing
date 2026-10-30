int highlightSongSelection = 0;

void SongSelectionMenu() {
  DrawSongCards();
  pushMatrix();

  // Top Bar
  fill(#6ba0cc);
  rectMode(CORNER);
  rect(0, 0, width, 60);

  // Back
  textSize(36);
  noStroke();
  if (mouseX >= 20 && mouseX <= 126 && mouseY >= 12 && mouseY <= 48) {
    fill(255, 255, 0);
  } else {
    fill(255);
  }
  textAlign(LEFT, TOP);
  triangle(40, 12, 40, 48, 20, 30);
  text("Back", 54, 16);

  // Menu Name
  fill(255);
  textAlign(CENTER, TOP);
  text("Select Song", width/2, 16);
  
    // Left / Right Button + Scroller (di bawah card)
  float btnY = 530;
  float scrollX = 300, scrollW = 200, scrollY = btnY - 6, scrollH = 12;

  noStroke();

  fill(highlightSongSelection > 0 ? 255 : 100);
  triangle(260, btnY - 15, 260, btnY + 15, 240, btnY);

  fill(highlightSongSelection < songList.length - 1 ? 255 : 100);
  triangle(540, btnY - 15, 540, btnY + 15, 560, btnY);

  rectMode(CORNER);
  fill(60);
  rect(scrollX, scrollY, scrollW, scrollH, 4);       // persegi luar (track)

  float thumbW = scrollW / songList.length;           // lebar 1/songList
  fill(#6ba0cc);
  rect(scrollX + thumbW * highlightSongSelection, scrollY, thumbW, scrollH, 4);  // persegi dalam

  popMatrix();
}

void DrawSongCards() {
  float cardGap = 100;
  float otherCardDim = 0.8;
  float highlightScale = 1.2;

  float cardW = 225;
  float otherScale = otherCardDim;                 // card non-highlight juga diperkecil 0.8
  float otherW = cardW * otherScale;
  float highlightW = cardW * highlightScale;

  // Tepi kiri card pertama (i = 0), relatif terhadap tengah layar.
  // Kalau highlightSongSelection = 2, ada 2 card kiri yang dihitung.
  float x = -(highlightW / 2) - highlightSongSelection * (otherW + cardGap);

  pushMatrix();
  translate(width/2, height/2);

  for (int i = 0; i < songList.length; i++) {
    boolean isHighlight = (i == highlightSongSelection);
    float s = isHighlight ? highlightScale : otherScale;
    float w = cardW * s;

    pushMatrix();
    translate(x + w / 2, 0);   // geser ke tengah card ini
    scale(s);

    // Song Card
    fill(#6ba0cc);
    rectMode(CENTER);
    rect(0, 0, 225, 320, 15);

    // Song Card Cover
    fill(0, 255 * 0.50);
    rect(0, -44, 190, 190, 4);
    drawImageCover(songList[i].coverArt, -90, -134, 180, 180);

    // Song Card Detail
    fill(0);
    textAlign(LEFT, TOP);
    textSize(24);
    text(songList[i].title, -96, 60);
    textSize(16);
    text(((int)songList[i].bpm) + " BPM | " + songList[i].composer, -96, 88);

    // Play Button
    fill(255);
    rect(0, 128, 190, 34, 4);
    textSize(22);
    textAlign(CENTER, CENTER);
    fill(#53a7ff);
    text("PLAY", 0, 126);

    // Dim untuk card yang tidak di-highlight
    if (!isHighlight) {
      fill(0, 255 * (1 - otherCardDim));
      rect(0, 0, 225, 320, 15);
    }

    popMatrix();

    x += w + cardGap;   // lanjut ke card berikutnya
  }
  popMatrix();
}
