import processing.sound.*;
int numLines = 100;
Line[] lines1 = new Line[numLines];
Line[] lines2 = new Line[numLines];
SoundFile[] notes = new SoundFile[8];
Line[] art = new Line[10000];
int[] song = {0, 4, 2, 1, 0, 0, 4, 2, 1, 0, 3, 5, 7, 1, 0, 4, 2, 1};  //{int(random(7))};
int numNotes = song.length;
Queue q = new Queue(numNotes);
color[] clrs = {color(252,166,17), color(252,189,148),  color(118,120,237),
                color(248,98,4)};
PGraphics big;
int printPixWidth=20*300; //inches in width * 300 DPI (6000)
int printPixHeight=18*300; //inches in width * 300 DPI (5400)
float myscale = 8.0;
int myScreenWidth = int(printPixWidth/myscale); //750
int myScreenHeight = int(printPixHeight/myscale); //675


void setup() { 
  size(750, 675);
  big=createGraphics(printPixWidth, printPixHeight);

  
  //SoundFile c1, d, e, f, g, a, b, c0;
  notes[0] = new SoundFile(this, "C1.wav");
  notes[1] = new SoundFile(this, "D1.wav");
  notes[2] = new SoundFile(this, "E1.wav");
  notes[3] = new SoundFile(this, "F1.wav");
  notes[4] = new SoundFile(this, "G1.wav");
  notes[5] = new SoundFile(this, "A1.wav");
  notes[6] = new SoundFile(this, "B1.wav");
  notes[7] = new SoundFile(this, "C0.wav");
  
  for (int i = 0; i < numLines; i++) {
    lines1[i] = new Line();
    lines1[i].setVars(i, clrs);
    lines2[i] = new Line();
    lines2[i].setVars(i, clrs);
  }
  
  for (int i = 0; i < 10000; i++) {
    art[i] = new Line();
  }
  
  //for (int i = 0; i < numNotes; i++) {
  //  song = append(song, int(random(7)));
  //}
  
  for (int i = 0; i < song.length; i++) {
    q.enqueue(song[i]);
  }
  
  //fullScreen();
  smooth(8);
  
  big.beginDraw();  //#3 start drawing/recording to the buffer
  big.background(30); //#4 duplicate each drawing function in the big buffer
  big.endDraw(); //#5 stop drawing/recording to the buffer
} 

float t1 = 7 * PI/4; 
float t2 = t1 + 1;
float inc = 0.0005;
float extend = 15;
int note = -1;
int currentLine = 0;
int min = 80;
int max = 180;

void draw() { 
  
  big.beginDraw(); 
    
  big.scale(myscale); //Scale everything after here up to match big buffer
  
  //--DRAW STUFF HERE (remember to use your buffer name in front of all calls)
  //------
  big.translate(width/2, height/2 - 50);
  if (!q.isEmpty()) {
    play(min, max);
      for (int i = 0; i < numLines; i++) {
          currentLine = lines1[i].setLine(t1, note, currentLine, art);
          currentLine = lines2[i].setLine(t2, note, currentLine, art);
        }
    t1 += inc;
    t2 += inc;
  }
  
  
  //--------
  //--STOP DRAWING HERE
  
  big.endDraw(); //#5 stop drawing/recording to the buffer
  
   // Draw the offscreen buffer to the screen with image() - So you can see what you're drawing!!
   // do this outside your draws to the buffer or it will be some kind of crazy recursion!
  image(big, 0, 0, width, height);
}

void play(int min, int max) {
 // release note from queue and color appropriate line
 int delay = int(random(min, max));
 if (frameCount % delay == 0) {
       note = q.dequeue();
       //notes[note].play();
       println("Lines: " + currentLine, "Notes left: " + q.size(), "Delay: " + delay);
     }
}

void keyPressed() {
  if (key == ENTER) {
     big.save("3.5.tif");
  }
}


class Line {
  float x1, y1, x2, y2;
  int i;
  int note_indx;
  color clr;
  float add = random(6);
  int count = 0;
  
  void setVars(int indx, color[] clrs) {
    i = indx;
    note_indx = int(random(8));
    clr = clrs[note_indx % 4];//clrs[int(random(10)) % clrs.length];//clrs[note_indx % clrs.length];
  }
  
  int setLine(float t, int note, int currentLine, Line[] art) {
    x1 = x1(t + i * inc * extend);
    y1 = y1(t + i * inc * extend);
    x2 = x2(t + i * inc * extend);
    y2 = y2(t + i * inc * extend);
    
    if (note == note_indx) {
      if (frameCount % 7 == 0) {
        art[currentLine].setPosition(x1, x2, y1, y2, clr);
        if (currentLine < 9999) {currentLine++;}
      }
    }
    return currentLine;
  }
  
  void drawArt() {
    big.strokeWeight(0.2);
    big.stroke(clr, 170);
    big.line(x1, y1, x2, y2);
  }
  
  void setPosition(float x1, float x2, float y1, float y2, color clr) {
    art[currentLine].x1 = x1;
    art[currentLine].x2 = x2;
    art[currentLine].y1 = y1;
    art[currentLine].y2 = y2;
    art[currentLine].clr = clr;
    drawArt();
  }
  
  
  float x1(float t) {
    return sin(t) * (exp(cos(t)) - 2 * cos(4 * t) - pow(sin(t / 12), 5)) * 110;
  }

  float y1(float t) {
    return cos(t) * (exp(cos(t)) - 2 * cos(4 * t) - pow(sin(t / 12), 5)) * 110;
  }

  float x2(float t) {
    return 100 * cos(6 * t + 0.79 * PI);
  }
  
  float y2(float t) {
    return 100 * sin(8 * t);
  }
}

class Queue {
   // from https://www.techiedelight.com/queue-implementation-in-java/
    private int[] arr;      // array to store queue elements
    private int front;      // front points to the front element in the queue
    private int rear;       // rear points to the last element in the queue
    private int capacity;   // maximum capacity of the queue
    private int count;      // current size of the queue
    
    // Constructor to initialize a queue
    Queue(int size) {
        arr = new int[size];
        capacity = size;
        front = 0;
        rear = -1;
        count = 0;
    }
 
    // Utility function to dequeue the front element
    public int dequeue() {
        // check for queue underflow
        if (isEmpty()) { println("Queue is empty."); }
 
        int x = arr[front];
        front = (front + 1) % capacity;
        count--;
 
        return x;
    }
 
    // Utility function to add an item to the queue
    public void enqueue(int item) {
        // check for queue overflow
        if (isFull()) { println("Queue is full."); }
 
        rear = (rear + 1) % capacity;
        arr[rear] = item;
        count++;
    }
 
    // Utility function to return the front element of the queue
    public int peek() {
        if (isEmpty()) { println("Queue is empty."); }
        return arr[front];
    }
 
    // Utility function to return the size of the queue
    public int size() {
        return count;
    }
 
    // Utility function to check if the queue is empty or not
    public boolean isEmpty() {
        return (size() == 0);
    }
 
    // Utility function to check if the queue is full or not
    public boolean isFull() {
        return (size() == capacity);
    }
}
