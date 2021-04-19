#include "DHT.h"
#define DHT_PIN 2
DHT dhtSensor; 
unsigned long ActualTime = 0;
unsigned long PastTime = 0;
unsigned long Difference = 0;
void setup()
{
  Serial.begin(9600);
  dhtSensor.setup(DHT_PIN);
}
 
void loop()
{
  ActualTime = millis();
  Difference = ActualTime - PastTime;
  if (Difference >= dhtSensor.getMinimumSamplingPeriod())
    {
      unsigned int humidity = dhtSensor.getHumidity();
      int temperature = dhtSensor.getTemperature();
      if (dhtSensor.getStatusString() == "OK") 
      {
        Serial.print(humidity);
        Serial.print("%RH | ");
        Serial.print(temperature);
        Serial.println("*C");
      }
      PastTime = ActualTime;
      delay(50);
      Serial.println("*C");
  } 
  
}
