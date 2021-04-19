import processing.serial.*; // biblioteka do komunikacji przez interfejs szeregowy
import java.awt.event.KeyEvent; // biblioteka do odczytu danych z portu szeregowego
import java.io.IOException;

/////////////////////////////ZMIENNE/////////////////////////////////////////////////////////////////////////////////////                                                                      //ilość ramek na sekundę funkcji draw()
Serial Port;                                                                         // obiekt do komunikacji szeregowej
int[] rgb = {8,31,107};                                                              //kolor tła interfejsu {RGB}
int[] ppp = {65, 255, 7};                                                            //kolor linii interfejsu {RGB}
int[] kkk = {255, 255, 255};
int iAngle = 0;                                                                      //kąt w stopniach
int iDistance = 0;                                                                   //odległść w mm
int[] ppe = {255, 0, 0}; 
float range = 300;
/////////////////////////////PĘTLA JEDNOKROTNA////////////////////////////////////////////////////////////////////////////////////////////////////
void setup()
{
  size(600, 300,P3D);
  
  surface.setResizable(true);

  Port = new Serial(this,"COM3", 9600);
  Port.bufferUntil('@'); 
}

/////////////////////////////PĘTLA WIELOKROTNA////////////////////////////////////////////////////////////////////////////////////////////////////
void draw()
{ 
 
 ReadData(Port);
 float d = Radar(6 ,7 , 2, 2, kkk, kkk, rgb, rgb, 50);
 fill(65, 255, 7);
 DrawArc(width/2, height, 2 * d, 2 * d, 360 - iAngle - 2 , 360 -iAngle  +2, ppp, 2);
 //DrawLine(width/2, height,iAngle, d, ppp , 4 );
 
 Object(d,range);
}

/////////////////////////////FUNKCJE WŁASNE///////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////ODCZYT DANYCH SZEREGOWO/////////////
void ReadData(Serial Port)                                                // przyjmuje argumenty klasy Serial
{
  String data;                                                            // zmienna do której pobieram dane
  try                                                                     // zabezpieczenie przed możliwymi wyjątkami powodującymi błędy (para try catch)
  {
    data = Port.readStringUntil('@');                                     // zczytuję dane aż do znaku kończącego paczkę (@, tak jak w skrypcie arduino)
    if (data == null) return;                                             // jeżeli dane błędnie odebrane (null), to powrót na początek try
    int index = data.indexOf(",");                                        // indeks przecinka bo on oddzielał kąt od odległości w skrypcie arduino
    String strAngle = data.substring(0, index);                           // wydobycie danych kąta (string)
    String strDistance = data.substring(index+1,data.length()-1);         // wydobycie danych odległości (string)
    iAngle = String2Int(strAngle);                                        // string -> int
    iDistance = String2Int(strDistance);
    //println(strAngle);
    //print(strDistance);
    //println("mm");
  }
  catch (RuntimeException e) {}
}

//////////KONWERSJA DANYCH DO LICZB CAŁKOWITYCH//////////
int String2Int(String string)                                      // działa poprawnie tylko dla danych liczbowych w formacie string
{
  int integer = 0;
  for( int i = 0; i < string.length(); i++)
  {
    if((string.charAt(i)) >= '0' && (string.charAt(i) <= '9'))     // odczyt kolejnych znaków z stringa
    {
      integer *= 10;
      integer += int(string.charAt(i) - '0');                      // wykorzystanie faktu że w tablicy ASCII liczby są obok siebie w kolejności rosnącej
    }
  }
  return integer;
}

//////////UTWORZENIE INTERFEJSU RADARU//////////
float Radar( float arc_count, float line_count, int arcLineWidth, int lineLineWidth, int[] arcColor, int[] lineColor, int[] background, int[] inContur, int k  )    // (l. łuków, l, linii, grubośc łuków, grubość linii, kolor łuków, kolor linii, kolor tła, 
                                                                                                                                                                  // kolor wewnątrz kontutu, kontrast)                     
{
  background(background[0],background[1],background[2]);
  fill(inContur[0] + k,inContur[1] + k,inContur[2] + k);
  float radius = min(width, 2*height);                                   //promień największego łuku                          
  float dr = floor(radius / (arc_count) - 0.001 * radius);                // przyrost promienia w pixelach
  float promien = dr * arc_count;
  for (int i = 1; i <= arc_count; i++)
  {
    DrawArc(width/2, height, promien, promien, 180, 360, arcColor, arcLineWidth);
    promien -= dr;
  }
  float dO = round(180 / line_count);    //przyrost kąta
  float kat = dO;
  float module = arc_count/2 * dr *1.001;
  for (int j = 1; j <= line_count; j++)
  {
    DrawLine(width/2, height, kat, module, lineColor, lineLineWidth );
    kat += dO;
  }
  return dr * arc_count / 2;
}


//////////RYSOWANIE LINII//////////
void DrawLine (float x0, float y0, float angle, float module, int[] kolor, int LineWidth )  // [punkt początkowy x0,y0 w ukladzie wsp. pierwotnym (x w prawo y w dół i początek w prawym górnym rogu)] i [kąt dla układu x- w prawo y do góry] oraz moduł, kolor rgb, grubość
{
  float x1,y1;
  float rAngle;
  strokeWeight(LineWidth);
  stroke(kolor[0],kolor[1],kolor[2]);
  pushMatrix();
  translate(x0,y0);
  if ((0 <= angle) && (angle < 90))
    {
      rAngle = radians(angle);
      x1 = module * cos(rAngle);
      y1 = -module * sin(rAngle);
      line(0, 0, x1, y1);
    }
   else if ((90 <= angle) && (angle < 180))
    {
      rAngle = radians(angle - 90);;
      y1 = -module * cos(rAngle);
      x1 = -module * sin(rAngle);
      line(0, 0, x1, y1);
    }
    else if ((180 <= angle) && (angle < 270))
    {
      rAngle = radians(angle - 180);;
      y1 = module * cos(rAngle);
      x1 = -module * sin(rAngle);
      line(0, 0, x1, y1);
    }
    else if ((270 <= angle) && (angle < 360))
    {
      rAngle = radians(angle - 270);;
      y1 = module * cos(rAngle);
      x1 = module * sin(rAngle);
      line(0, 0, x1, y1);
    }
   popMatrix();
}

//////////RYSOWANIE ŁUKU//////////
void DrawArc(float x0, float y0, float radiusX, float radiusY, float StartAngle, float StopAngle, int[] kolor, int LineWidth ) // wsp. początku łuku, promień x i y, kąt początkowy i końcowy (w układzie domyślnym), kolor rgb grubość lnii
{
  strokeWeight(LineWidth);
  stroke(kolor[0],kolor[1],kolor[2]);
  float rStart = radians(StartAngle);
  float rStop = radians(StopAngle);
  arc(x0, y0, radiusX, radiusY, rStart, rStop);
  
}

//////////WYKRYWANIE OBIEKTU//////////
void Object(float module, float range) 
{
   float pixsDistance;
   if (iDistance < range)
   {pixsDistance = iDistance * module / range;}
   else {pixsDistance = module;}
   fill(255, 0 , 0);
   DrawArc(width/2, height, 2 * module, 2 * module, 360 - iAngle - 2 , 360 -iAngle  + 2, ppe, 2);
    fill(65, 255, 7);
   DrawArc(width/2, height, 2 * pixsDistance, 2 * pixsDistance, 360 - iAngle - 2 , 360 -iAngle  +2, ppp, 2);
  
}
