#include <Arduino.h>

const int ledPins[] = {
    32,
    33,
    25,
    26,
    27,
    14,
};

void OnThenOff(int stepdelay, int repeat);
void AllOnOff(int stepdelay, int repeat);
void Pair(int stepdelay, int repeat);
void SingleOnOff(int stepdelay, int repeat);
void SetLight(int index);

bool lightOn = false;
bool trailer = false;
int lightIndex = -1;
int loopIndex = 0;

void setup()
{
  Serial.begin(9600);
  Serial.setTimeout(10);
  for (int i = 0; i < sizeof(ledPins) / sizeof(int); i++)
  {
    pinMode(ledPins[i], OUTPUT);
  }
}

void loop()
{
  if (Serial.available())
  {
    String incoming = Serial.readString();
    incoming.trim();
    if (incoming.startsWith("SET"))
    {
      trailer = false;
      Serial.print("Recieved Light SET command");
      lightIndex = incoming.substring(3).toInt();
      SetLight(lightIndex);
    }
    if (incoming.startsWith("TRAILER"))
    {
      if (incoming.endsWith("START"))
      {
        trailer = true;
        digitalWrite(ledPins[lightIndex], LOW);
      }
      if (incoming.endsWith("END"))
      {
        trailer = false;
        SetLight(lightIndex);
      }
    }
    if (incoming.startsWith("OFF"))
    {
      trailer = false;
      lightIndex = -1;
    }

    // prints the received data
    Serial.print("I received: ");
    Serial.println(incoming);
  }
  if (trailer == true)
  {
    int nextLightIndex = (loopIndex + 1) % (sizeof(ledPins) / (sizeof(int)));
    digitalWrite(ledPins[nextLightIndex], HIGH);
    digitalWrite(ledPins[loopIndex], LOW);
    loopIndex = nextLightIndex;
    delay(1400);
  }
  if (lightIndex == -1 && !trailer)
  {
    loopIndex = (loopIndex + 1) % 4;
    switch (loopIndex)
    {
    case 0:
      OnThenOff(200, 2);
      break;
    case 1:
      Pair(400, 2);
      break;
    case 2:
      SingleOnOff(200, 2);
      break;
    default:
      AllOnOff(400, 2);
    }
  }
}

void SetLight(int index)
{
  for (int i = 0; i < sizeof(ledPins) / sizeof(int); i++)
  {
    if (i == lightIndex)
    {
      digitalWrite(ledPins[i], HIGH);
    }
    else
    {
      digitalWrite(ledPins[i], LOW);
    }
  }
}

void OnThenOff(int stepdelay, int repeat)
{
  for (int c = 0; c < repeat; c++)
  {
    for (int i = 0; i < sizeof(ledPins) / sizeof(int); i++)
    {
      digitalWrite(ledPins[i], HIGH);
      delay(stepdelay); // warte 500 Millisekunden
    }
    for (int i = 0; i < sizeof(ledPins) / sizeof(int); i++)
    {
      digitalWrite(ledPins[i], LOW);
      delay(stepdelay); // warte 500 Millisekunden
    }
  }
}

void AllOnOff(int stepdelay, int repeat)
{
  for (int c = 0; c < repeat; c++)
  {
    for (int i = 0; i < sizeof(ledPins) / sizeof(int); i++)
    {
      digitalWrite(ledPins[i], HIGH);
    }
    delay(stepdelay);
    for (int i = 0; i < sizeof(ledPins) / sizeof(int); i++)
    {
      digitalWrite(ledPins[i], LOW);
    }
    delay(stepdelay);
  }
}

void SingleOnOff(int stepdelay, int repeat)
{
  for (int c = 0; c < repeat; c++)
  {
    for (int i = 0; i < sizeof(ledPins) / sizeof(int); i++)
    {
      digitalWrite(ledPins[i], HIGH);
      delay(stepdelay);
      digitalWrite(ledPins[i], LOW);
      delay(stepdelay);
    }
  }
}

void Pair(int stepdelay, int repeat)
{
  for (int c = 0; c < repeat; c++)
  {
    for (int i = 0; i < sizeof(ledPins) / sizeof(int); i += 2)
    {
      digitalWrite(ledPins[i], HIGH);
      if (i + 1 < sizeof(ledPins) / sizeof(int))
      {
        digitalWrite(ledPins[i + 1], HIGH);
      }
      delay(stepdelay);
      digitalWrite(ledPins[i], LOW);
      if (i + 1 < sizeof(ledPins) / sizeof(int))
      {
        digitalWrite(ledPins[i + 1], LOW);
      }
      delay(stepdelay);
    }
  }
}