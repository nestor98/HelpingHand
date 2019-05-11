float PROP_BRAZO = 0.021;
float SLOWMO = 1; // inicialmente el tiempo avanza normal

public class Cuerpo {
  protected float tam;
  protected float x;
  protected float masa;
  protected float v;
  protected float ultimaX; // Para colisiones, guardamos la ultima pos
  
  // tam en cm, x coordenada, masa en kg, v en m/s
  Cuerpo(float tam, float x, float masa, float v) {
    this.tam = tam/10; //en decenas de cm
    this.x = x;
    this.masa = masa;
    this.v = v*10/frameRate; 
  }
  
  void dibujar() {
    ellipse(x, 0, tam, tam); 
  }
  
  void actualizarPos() {
    ultimaX = x;
    x += SLOWMO*v; // v * proporcion de velocidad 
  }
  
  float tam() {
    return tam;
  }
    
  float pos() {
    return x;
  }
  float masa() {
    return masa;
  }
  float vel() {
    return v*frameRate/10;
    // La v real es los pixeles avanzados cada frame, por el frameRate,
    // entre 10 
  }
  
  // Devuelve la altura en cm
  float altura() {
    return tam*10;
  }  
  
  float ultimaPos() {
    return ultimaX;
  }
  
  // Devuelve cierto si uno de los bordes del objeto "otro" esta dentro de this
  boolean colision(Cuerpo otro) {
    //                                                                borde izq de otro en el objeto this                                                                                                borde derecho
    boolean otroDentro = ( ( (this.pos()-this.tam()/2.0) <= (otro.pos()-otro.tam()/2.0) ) && ( (this.pos()+this.tam()/2.0) >= (otro.pos()-otro.tam()/2) ) || ( (this.pos()-this.tam()/2.0) <= (otro.pos()+otro.tam()/2.0) ) && ( (this.pos()+this.tam()/2.0) >= (otro.pos()+otro.tam()/2) ) );
    // this esta entre la ultima posicion de otro y la actual -> otro lo acaba de atravesar
    boolean atravesado = ( this.pos() <= max(otro.pos(),otro.ultimaPos()) ) && ( this.pos() >= min(otro.pos(), otro.ultimaPos()) );
    return otroDentro || atravesado;
}
  
  
  
  
}
public class Astronauta extends Cuerpo {
  private Cuerpo brazo;
  private boolean deUnaPieza;
  
  Astronauta(float tam, float x, float masa, float v) {
    super(tam, x, masa, v);
    brazo = new Cuerpo(tam * PROP_BRAZO * 20, x, masa * PROP_BRAZO, v); // Tamaño * 20 para que se vea algo
    this.deUnaPieza = true;
  }
  
  void dibujar(){
    super.dibujar();
    if (!deUnaPieza) {
      brazo.dibujar();
    }
  }
  
  void lanzarBrazo(float vBrazo) {
    //momFin = momIni
    //momFin = vIni * mIni
    //mSinB*vSinB + mBrazo*vBrazo = vIni * mIni
    //vSinB = (vIni*mIni - mBrazo*vBrazo) / mSinB
    // la velocidad final del astronauta sera vSinB
    float masaTot = this.masa;
    this.masa -= this.brazo.masa; // Nueva masa del astronauta
    this.deUnaPieza = false;      // Yep
    this.brazo.v = vBrazo*10/frameRate;        // Nuevas posiciones y velocidades del brazo
    this.brazo.x = this.x;
    this.v = (this.v * masaTot - this.brazo.masa * this.brazo.v) / this.masa; // Velocidad final del astronauta
    
    
  }
  
  // Para cuando se pone la simulacion con el tiempo al reves. Modela un choque inelastico supongo, en el que el astronauta
  // recupera su brazo (y su masa)
  void atraparBrazo(float vBrazo) {
    //momFin = momIni
    //momFin = vIni * mIni
    //mSinB*vSinB + mBrazo*vBrazo = vIni * mIni
    //vSinB = (vIni*mIni - mBrazo*vBrazo) / mSinB
    // la velocidad final del astronauta sera vSinB
    float masaCuerpo = this.masa;
    this.masa += this.brazo.masa; // Nueva masa del astronauta
    this.deUnaPieza = true;      // Yep
    //this.brazo.v = vBrazo*10/frameRate;        // Nuevas posiciones y velocidades del brazo
    //this.brazo.x = this.x;
    this.v = (this.v * masaCuerpo + this.brazo.masa * this.brazo.v) / this.masa; // Velocidad final del astronauta con brazo??
  }
  
  boolean manca() {
    return !deUnaPieza;
  }

  void actualizarPos() {
    super.actualizarPos();
    if (!deUnaPieza) {
      brazo.actualizarPos();
    }
  }

}

void dibujarBarra() {
  pushMatrix();
  translate(0,-50);
  
  line(0,0,width,0);
  for (int i = 0; i < width/10; i+=2) {
    translate(20,0);
    line(0,-3,0,3);
    if ((i+2)%10 == 0) { // cada 10 m
      fill(255);
      text((i+2) + " m", -15, -10);
    
    }
  }
  popMatrix();
  
}

void mostrarStats(boolean mostrarTodo) {
  pushMatrix();  // Astronauta
  translate(0,8*height/9);
  text("Josefa: ",10,-14);
  text("Altura: " + josefa.altura()+ " cm",30,0);
  text("Masa: " + josefa.masa() + " kg",30,14);
  text("Velocidad: " + nf(josefa.vel(),0,2) + " m/s",30,28);
  text(nf(3.6*josefa.vel(),0,2) + " km/h", 95, 42);
  if (mostrarTodo) {   // Brazo
    pushMatrix();
    translate(width-width/5,0);
    text("Brazo: ",10,-14);
    text("Masa: " + josefa.brazo.masa() + " kg",30,0);
    text("Velocidad: " + nf(josefa.brazo.vel(),0,2) + " m/s",30,14);
    text(nf(3.6*josefa.brazo.vel(),0,2) + " km/h", 95, 28);
    popMatrix();
  }
  if (SLOWMO != 1) { // Tiempo -- slowmo
    pushMatrix(); 
    translate (3.0*width/7,0); // sale en medio
    if (SLOWMO == 0) { // Pausa
      text("PAUSA",30,14);
    }
    else { // Otros valores
      text("Slowmo: " + nf(SLOWMO,0,2),20,14);
    }
    popMatrix();
  }
  popMatrix();
}

Astronauta josefa; 
PImage fondo;
void setup() {
    size(960,480);
    fondo = loadImage("image.png");
    background(fondo);
    stroke(255);
    josefa = new Astronauta(160, 0, 60, 6);
    
}
    
void draw() {
    // Para dejar estela:
    /*fill(0, 120);
    rect(0, 0, width, height);*/
    background(fondo);
    pushMatrix();
    translate(0, height/5); // Empieza en medio
    
    dibujarBarra();
    
    
    fill(255);
    josefa.dibujar();
    josefa.actualizarPos();
    if (josefa.pos() > width/2 && !josefa.manca() && SLOWMO>0) { //lanzamiento
      josefa.lanzarBrazo(500);
    }
    else if (josefa.colision(josefa.brazo) && josefa.manca()) { //lo atrapa (tiempo va al reves)
      josefa.atraparBrazo(josefa.brazo.vel());
    }
    fill(255);
    popMatrix();
    mostrarStats(josefa.pos() > 2*width/5 || josefa.manca()); // muestra los stats (los del brazo solo una vez lanzado)
    if(josefa.pos() > width || josefa.pos() < 0) {
      //Se ha salido. reseteamos
      setup();
    }
}



void keyPressed() {
  // Captura teclas:
  if (key == CODED) { // Teclas especiales
    
    if (keyCode == RIGHT) { // Aumenta "velocidad de reproduccion" de la simulacion
      SLOWMO += 0.1;
    }
    else if (keyCode == LEFT) { // La disminuye
      SLOWMO -= 0.1;
    }
    else if (keyCode == UP) { // La aumenta poco
      SLOWMO += 0.01;
    }
     else if (keyCode == DOWN) { // La disminuye poco
      SLOWMO -= 0.01;
    }
     else if (keyCode == CONTROL) { // Reset a lo original
      SLOWMO = 1;
    }
    else if (keyCode == SHIFT) { // Para el tiempo
      SLOWMO = 0;
    }
    // Nota: al poner el tiempo hacia atrás, el astronauta no recoge su brazo, 
    // habría que cambiarlo para que fuera como un video... 
  }
}
