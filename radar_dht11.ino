#include <Servo.h>
#include "DHT.h"

///////PINY DO CZUJNIKA ULTRADŹWIĘKOWEGO i DHT 11//////////////////////////////////////////////////////////////////////
#define trigger 12
#define echo 11
#define DHT_PIN 2

///////ROZMIAR TABLICY DO CZASU OPÓŹNIEŃ//////////////////////////////////////////////////////////////////////
# define SIZE 2 

///////STRUKTURA DO OBSŁUGI DHT 11/////////////////////
struct Dht11
{
  int humidity = 0;
  int temperature = 0;
};

///////DEKLARACJE ZMIENNYCH///////////////////////////////////////////////////////////////////////////////
DHT dhtSensor;              // obiekt typu DHT
Servo myservo;              // obiekt klasy Servo
const int StartAngle = 90;  // pozycja początkowa w stopniach
const int Dangle = 1;       // prędkość (skok kątowy) w stopniach
const int minAngle = 50;    // pozycja graniczna 1 w stopniach
const int maxAngle = 130;   // pozycja graniczna 2 w stopniach
int angle;                  // aktualny kąt podawany do serwo
int dir = 0;                // kierunek ruchu
unsigned long ActualTime;   // aktualny czas systemowy
unsigned long PastTime[SIZE] = {0, 0};// czasy danych wydarzeń w programie
unsigned long dT[SIZE] = {0, 0};     // różnica mędzy czasem aktualnym a czasem  danego wydarzenia (1- serwo, 2- dht11 )
unsigned int SerwoWait = 50;// minimalny czas oczekiwania na zmianę położenia serwo w ms;
Dht11 wyniki;

///////PĘTLA STARTOWA////////////////////////////////////////////////////////////////////////////////////////
void setup() 
{
  dhtSensor.setup(DHT_PIN);
  myservo.attach(8);        // przypisanie pinu do sterowania silnikiem (PWM)
  pinMode(trigger, OUTPUT); // przestawienie pinu trigger w tryb wyjścia (pozwala na pomiar odległości gdy ma stan wysoki )
  pinMode(echo, INPUT);     // przestawienie pinu echo w tryb wejścia (odbiera falę, długość impulsu  ~ do odległości)
  myservo.write(minAngle);  // przemieszczenie serwo do pozycji początkowej
  Serial.begin(9600);       // włączenie transmisji szeregowej danych z baud rate = 9600
}

///////PĘTLA WIELOKROTNA///////////////////////////////////////////////////////////////////////
void loop() 
{
  
           ///////RÓŻNICA CZASU SYSTEMOWEGO ///////
           ActualTime= millis();
           for (int i = 0; i < SIZE; i++)
           {
            dT[i] = ActualTime - PastTime[i];
           }
          if (dT[1] >= dhtSensor.getMinimumSamplingPeriod())
          {
           wyniki = getDHTresults();
           PastTime[1] = ActualTime;
          }
//          if (dT[0] >= SerwoWait)
//          {
//                ///////OBSŁUŻENIE RUCHU Z POZYCJI min -> max ///////
//              if (dir == 0)
//              {   
//                  angle += Dangle;
//                  myservo.write(angle);  
//                  int distance = distance_in_mm();
////                  Serial.print(angle);
////                  Serial.print("\n");
//                  //SerialOut(angle, distance, wyniki);
//                  PastTime[0] = ActualTime;
//                  if (angle >= maxAngle) {dir = 1;}
//               }
//          
//            ///////OBSŁUŻENIE RUCHU Z POZYCJI max -> min ///////
//              else if ( dir == 1)
//              {
//                  angle -= Dangle;
//                  myservo.write(angle);  
//                  int distance = distance_in_mm();
////                  Serial.print(angle);
////                  Serial.print("\n");
//                  //SerialOut(angle, distance, wyniki);
//                  PastTime[0] = ActualTime;
//                  if (angle <= minAngle) {dir = 0;}   
//              }
//          }
           
 }
   



///////DEFINICJE FUNKCJI//////////////////////////////////////////////////////////////////////////////////////////////

///////OBSŁUGA CZUJNIKA I KONWERSJA DO MM/////////////////
unsigned int distance_in_mm()
{
    long echotime;                // długość impulsu z czujnika ~ odległości
    long distance;                // odległość 
   digitalWrite(trigger, LOW);    // ustawienie wyjścia trigger na stan niski
   delayMicroseconds(2);          // odczekanie 2 us
   digitalWrite(trigger, HIGH);   // ustawienie wyjścia trigger w  stan wysoki
   delayMicroseconds(10);         // odczekanie 10 us (minimum, bo pilseIn tego wymaga aby impuls miał długość w przedziale [10s; 3min])
   digitalWrite(trigger, LOW);

   echotime = pulseIn(echo, HIGH);// pomiar czasu trwania stanu wysokiego na echo
   distance = echotime / 58*10 ;  // konwersja do mmmm
   return  int(distance);         // rzutowanie na int (potrzebne w processsing IDE)
}

///////PRZESYŁ DANYCH PORTEM SZEREGOWYM/////////////////////
void SerialOut (const int angle, const  int distance, Dht11 results)
{
  String strAngle = String(angle);                      // konwersja do string (bo łatwiej potem odebrać dane)
  String strDistance = String(distance);
  String strHumidity = String(results.humidity);
  String strTemperature = String(results.temperature);
  Serial.println(strAngle + ", " + strDistance + " @" + strHumidity + " %" + strTemperature + " $" );   // przesył danych  w formacie "kąt,odległość@wilgotność%temperatura$"
}

///////OBSŁUGA CZUJNIKA DHT 11/////////////////////
Dht11 getDHTresults()
{
   Dht11 results;
   results.humidity = dhtSensor.getHumidity();
   results.temperature = dhtSensor.getTemperature();
   if (dhtSensor.getStatusString() == "OK") 
      {
          Serial.print(results.humidity);
          Serial.print("%RH | ");
          Serial.print(results.temperature);
          Serial.println("*C");
          return results;
        }
    else 
    {
      results.humidity = 0;
      results.temperature = 0;
      return results;
    }
   
}
