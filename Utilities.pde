String IntToString(int value, int targetLength)
{
  String result = Integer.toString(value);
  while (result.length() < targetLength)
  {
    result = "0" + result;
  }
  return result;
}

String FloatToString(float value, int decimalLength) {
  String result = "";
  String floatedString = Float.toString(value);
  boolean foundDecimal = false;

  for (int i=0; i < floatedString.length(); i++)
  {
    if (decimalLength <= 0) break;
    if (floatedString.charAt(i) == '.' && !foundDecimal)
    {
      foundDecimal = true;
      if (decimalLength == 0) break;
      else
      {
        result += floatedString.charAt(i);
        continue;
      }
    }
    result += floatedString.charAt(i);
    if (foundDecimal) decimalLength--;
  }
  return result;
}

void MouseCoordinate()
{
  fill(0);
  rectMode(CORNER);
  rect(mouseX + 8, mouseY + 6, 100, 24);
  textSize(16);
  textAlign(LEFT, TOP);
  fill(255);
  text("x : " + mouseX + ", y : " + mouseY, mouseX + 10, mouseY + 10);
}

void ChartGuide() {
  for (int i = 0; i < guideTimeSize; i++) {
    if (guideTimes[i][1] > 0 || songDuration < guideTimes[i][0] - 0.23) continue;
    println(guideTimes[i][0]);
    if (!guideSound.isPlaying()) {
      guideSound.play();
    }
    guideSound.loop();
    guideTimes[i][1] = 1;
  }
}

public File GetDataFile(String subDir) {
    return new File(dataPath(subDir));
}

public String[] GetDataDirList(String subDir) {
  return GetDataFile(subDir).list();
}

void drawImageFit(PImage img, float x, float y, float w, float h) {
  float s = min(w / img.width, h / img.height);
  float dw = img.width * s;
  float dh = img.height * s;
  image(img, x + (w - dw) / 2, y + (h - dh) / 2, dw, dh);
}

void drawImageCover(PImage img, float x, float y, float w, float h) {
  float boxRatio = w / h;
  float imgRatio = (float) img.width / img.height;

  float sw = img.width, sh = img.height;
  float sx = 0, sy = 0;

  if (imgRatio > boxRatio) {
    sw = img.height * boxRatio;
    sx = (img.width - sw) / 2;
  } else {
    sh = img.width / boxRatio;
    sy = (img.height - sh) / 2;
  }

  image(img, x, y, w, h, (int) sx, (int) sy, (int) (sx + sw), (int) (sy + sh));
}
