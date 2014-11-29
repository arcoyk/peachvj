import ddf.minim.analysis.*;
import ddf.minim.*;

Minim       minim;
AudioPlayer audio;
FFT         fft;

boolean stop_flag = false;

class View {
  View() {
  }
  PVector anch = new PVector(0, height / 2);
  float zoom = 0.1;
  void mouseWheel(MouseEvent e) {
    anch.x -= e.getCount();
  }
}

class Visualizer {
  Visualizer() {
    textSize(20);
  }
  
  View view = new View();
  PVector right_edge = new PVector(0, 0);
  PVector offset = new PVector(20, 50);
  ArrayList<MusicData> md_list = new ArrayList<MusicData>();
  
  void show_md_names() {
    for(int i = 0; i < md_list.size(); i++) {
      MusicData md = md_list.get(i);
      fill(md.c);
      text(md.name, offset.x, 50 + offset.y * i);
    }
  }
    
  void show_md_data() {
    stroke(255, 255, 255, 100);
    line(0, height / 2, width, height / 2);
    for(MusicData md : md_list) {
      PVector prev = new PVector(0, height / 2);
      PVector curr = new PVector(0, height / 2);
      stroke(md.c);
      for(int i = max(0, (int)(-view.anch.x / view.zoom));
          i < width / view.zoom && i < md.data.size();
          i++) {
        curr.x = view.anch.x + i * view.zoom;
        curr.y = view.anch.y - md.data.get(i);
        line(prev.x, prev.y, curr.x, curr.y);
        prev.x = curr.x;
        prev.y = curr.y;
      }
      right_edge.x = view.anch.x + md.data.size() * view.zoom;
    }
  }
  
  void show() {
    show_md_names();
    show_md_data();
  }
}

class MusicData {
  MusicData() {
    c = color((int)random(100, 255),
              (int)random(100, 255),
              (int)random(100, 255),
              100);
  }
  color c = color(255);
  String name = "difference";
  ArrayList<Float> data = new ArrayList<Float>();
  void push(float val){
    data.add(val);
  }
}

Visualizer vis;
MusicData high_md, middle_md, low_md;

void setup() {
  size(800, 500);
  minim = new Minim(this);
  audio = minim.loadFile("All_the_spieces_on_the_earth.mp3", 1024);
  audio.loop();
  fft = new FFT(audio.bufferSize(), audio.sampleRate());
  stroke(255);
  
  //test
  vis = new Visualizer();
  high_md = new MusicData();
  middle_md = new MusicData();
  low_md = new MusicData();
  high_md.name = "High";
  middle_md.name = "Middle";
  low_md.name = "Low";
  vis.md_list.add(high_md);
  vis.md_list.add(middle_md);
  vis.md_list.add(low_md);
}

void draw() {
  background(0);
  if(!stop_flag) {
    fft.forward(audio.mix);
    for(int i = 0; i < fft.specSize(); i++) {
      float val = fft.getBand(i) * 10;
      if( i < fft.specSize() / 3 ) {
        high_md.push(val);
      }else if( i < fft.specSize() / 3 * 2){
        middle_md.push(val);
      }else {
        low_md.push(val);
      }
    }
    //vis.view.anch.x = min(0, -(vis.right_edge.x - (width + width / 2)));
  }
  vis.show();
}

void mouseWheel(MouseEvent e) {
  vis.view.mouseWheel(e);
}

void simple_fft_draw(){
  background(0);
  fft.forward(audio.mix);
  for(int i = 0; i < fft.specSize(); i++) {
    line(i, height, i, height - fft.getBand(i) * 10);
  }
}

void keyPressed() {
  if (key == ' ') {
    stop_flag = !stop_flag;
  }
}
