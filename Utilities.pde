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
