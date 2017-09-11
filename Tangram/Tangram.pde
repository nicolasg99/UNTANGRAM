import java.io.*;
import java.util.ArrayList;
import java.lang.Math;


 private ArrayList<Nivel> niveles;
 private int nivelActual;
 private int has;
 private boolean start = false;
 private boolean ini = true;
 private boolean win = false;
 

void setup(){
  size(800,800);
  noStroke();
}

void reinicio(){
  String path = "C:\\Users\\usuario\\Projects\\UNTANGRAM\\Niveles"; 
  File folder = new File(path);
  File[] listOfFiles = folder.listFiles(); 
  niveles = new ArrayList();
  for(int i = 0; i < listOfFiles.length; i++){   
    if (listOfFiles[i].isFile()){
        niveles.add(new Archivo(listOfFiles[i]).generarNivel());
        System.out.print("Creado nivel "+i);
    }
  }
  this.nivelActual = 0;
  has = -1;
}

void draw(){
  loadPixels();
  background(0);
  if(start){
    niveles.get(nivelActual).dibujarNivel();
    if( mousePressed && (has != -1) ){
      niveles.get(nivelActual).moverFigura(has, mouseX-pmouseX, mouseY-pmouseY);
      if(niveles.get(nivelActual).validarNivel()){
         start = false;
         win = true;
         nivelActual= (nivelActual== (niveles.size()-1)? 0: nivelActual+1);
      }
    }
  }
  else if(ini){
    text("Bienvenido, oprime p para iniciar", width/2, height/2);
  }
  else if(win){
    text("Haz ganado, oprime p para continuar", width/2, height/2);
  }
  else{
    text("Pausa, oprime p para iniciar", width/2, height/2);
  }
}

void mousePressed(){
  if( start && mouseButton == LEFT ){
     color mouseC = get(mouseX,mouseY);
     for(int j=0;j<niveles.get(nivelActual).getSize();j++){
        if( niveles.get(nivelActual).obtenerFigura(j).getColor() == mouseC ){
          has = j;
        }
     }   
  }
}

void mouseReleased(){
  if(start){
    has = -1;
    for(int i=0;i<niveles.get(nivelActual).getSize();i++){
      int px = niveles.get(nivelActual).obtenerFigura(i).getX();
      int py = niveles.get(nivelActual).obtenerFigura(i).getY();
      if( px < 0 || px > width || py < 0 || py > height ){
        niveles.get(nivelActual).obtenerFigura(i).reubicar();
      }
    }
  }
}

void mouseClicked(){
  if(start && mouseButton == RIGHT ){
    color mouseC = get(mouseX,mouseY);
    
    for(int j=0;j<7;j++){
      if( niveles.get(nivelActual).obtenerFigura(j).getColor() == mouseC ){
        niveles.get(nivelActual).obtenerFigura(j).rotar();
      }
    }   
  }  
}

void keyReleased(){
  if( start && key == '1'){
    reinicio();
  }
  else if(key == 'p'){
    if(ini)
      reinicio();
    if(win)
      win = false;
    start = !start;
    ini = false;
  }
}
public class Nivel{
  private ArrayList<Silueta> silueta;
  private ArrayList<Silueta> figuras;
  private String nombre;
  public Nivel(ArrayList<Silueta> silueta, String nombre){
    this.silueta = silueta;
    this.nombre = nombre;
    figuras = new ArrayList();
    for(int i = 0; i<this.silueta.size(); i++){
       figuras.add(this.silueta.get(i).GenerarReplica());
    }
  }
  public void dibujarNivel(){
    text(nombre, width/2, height/2);
    for(int i = 0; i< silueta.size(); i++){
      silueta.get(i).Dibujar();
    }
    for(int i = 0; i< silueta.size(); i++){
      figuras.get(i).Dibujar();
    }
  }
  public boolean validarNivel(){
    boolean valido;
     for(int i =0; i< this.silueta.size(); i++){
       valido = false;
       for(int j = 0; j< this.silueta.size();j++)
       {
         if(this.silueta.get(i).validar(figuras.get(j))){
           valido = true;
           break;
         }
       }
       if(!valido){
         return false;
       }
     }
     return true;
  }
  public void moverFigura(int index, int vx, int vy){
    figuras.get(index).moveX(vx);
    figuras.get(index).moveY(vy);
  }
  public Silueta obtenerFigura(int index){
    return figuras.get(index);
  }
  public int getSize(){
    return figuras.size();
  }
  
}
public class Archivo{
  //private FileOutputStream salida;
  private FileInputStream entrada;
  private File archivo;
  public Archivo(File archivo){
    this.archivo = archivo;
  }
  public Nivel generarNivel(){
     ArrayList<Silueta> siluetas = new ArrayList();
     String nombre = "";
     try{
       entrada = new FileInputStream(archivo);
       int ascci;
       AccionLectura accion = AccionLectura.INICIO;
       Figura figura = Figura.INDEFINIDA;
       ArrayList<Vertice> vertices = new ArrayList();
       String x = "", y = "";
       
       while((ascci = entrada.read())!= -1){
         char lectura = (char)ascci;
           switch(accion){
             case INICIO:
               if(lectura=='\n'){
                 accion= AccionLectura.NUEVO;
               }
               else
                 nombre += lectura;
               break;
             case NUEVO:
               if(lectura=='('){
                 accion = AccionLectura.X;
               }
               else
                 figura = obtenerFigura(lectura);
               break;
             case X:
               if(lectura==','){
                 accion = AccionLectura.Y;
               }
               else
                 x += lectura;
               break;
             case Y:
               if(lectura==')'){
                 accion = AccionLectura.FIN_VERTICE;
                 try{
                   vertices.add(new Vertice(Integer.parseInt(x), Integer.parseInt(y)));
                 }catch(Exception ex){}
                 x = "";
                 y = "";
               }
               else{
                 y += lectura;
               }
               break;
             case FIN_VERTICE:
               if(lectura=='('){
                 accion = AccionLectura.X;
               }
               else if(lectura==']'){
                 siluetas.add(new Silueta(figura, vertices));
                 vertices = new ArrayList();
                 accion = AccionLectura.NUEVO;
               }
               break;
           }
         
       }
     }
     catch(Exception ex){
     }
     return new Nivel(siluetas, nombre);
  }
  private Figura obtenerFigura(char f){
    Figura retorno = Figura.INDEFINIDA;
    switch(f){
      case 'r':
        retorno = Figura.RECTANGULO;
      case 't':
        retorno = Figura.TRIANGULO;
        break;
    }
    return retorno;
  }
  
}
public class Silueta{
  private ArrayList<Vertice> vertices;
  private Figura figura;
  private color colorSilueta;
  private int rotacion;
  private boolean movible;
  private int x;
  private int y;
  private int CX;
  private int CY;
  
  
  public Silueta(Figura figura, ArrayList<Vertice> vertices){
    this.figura = figura;
    this.vertices = vertices;
    this.colorSilueta = color(255, 255, 255);
    this.movible = false;
    localizar();
  }
  public Silueta(Figura figura, ArrayList<Vertice> vertices,color colorSilueta, int rotacion, int CX, int CY){
    this.figura = figura;
    this.vertices = vertices;
    this.colorSilueta = colorSilueta;
    this.rotacion = rotacion;
    this.movible = true;
    this.x = (int)random(50,150);
    this.y = (int)random(50,150);
    this.CY = CY;
    this.CX = CX;
  }
  
  public ArrayList<Vertice> getVertices(){
    return this.vertices;
  }
  public Figura getFigura(){
    return this.figura;
  }
  public color getColor(){
    return this.colorSilueta;
  }
  public boolean getMovible(){
    return this.movible;
  }
  public int getRotacion(){
    return this.rotacion;
  }
  public int getX(){
    return this.x;
  }
  public int getY(){
    return this.y;
  }
  public void rotar(){
    if(movible)
      this.rotacion = (this.rotacion+1)%8;
  }
  public void moveX(int value){
    if(movible){
      this.x += value;
    }
  }
  public void moveY(int value){
    if(movible){
      this.y += value;
    }
  }
  public void reubicar(){
    this.x = (int)random(50,150);
    this.y = (int)random(50,150);
  }
  public Silueta GenerarReplica(){
    
    ArrayList<Vertice> verticesRetorno = new ArrayList();
    for(int i = 0; i< this.vertices.size(); i++){
      verticesRetorno.add(new Vertice(this.vertices.get(i).x, this.vertices.get(i).y));
    }
    int rotacionRetorno = int(random(0,8));
    color colorSiluetaRetorno = color( random(128,204),random(128,204),random(128,204));
    Figura figuraRetorno = this.figura;
    
    return new Silueta(figuraRetorno, verticesRetorno, colorSiluetaRetorno, rotacionRetorno, this.CX, this.CY);
  
  }
  public void Dibujar(){
    pushMatrix();
    fill(colorSilueta);
      translate(this.x,this.y);
    if(movible){
      rotate(this.rotacion*radians(45));
    }  
    
    switch(figura){
      case RECTANGULO: // Big ones.
        beginShape(QUADS);
        vertex(vertices.get(0).getX(), vertices.get(0).getY());
        vertex(vertices.get(1).getX(), vertices.get(1).getY());
        vertex(vertices.get(2).getX(), vertices.get(2).getY());
        vertex(vertices.get(3).getX(), vertices.get(3).getY());
        endShape();
        break;
      case TRIANGULO: // Small ones.
        beginShape(TRIANGLES);
        vertex(vertices.get(0).getX(), vertices.get(0).getY());
        vertex(vertices.get(1).getX(), vertices.get(1).getY());
        vertex(vertices.get(2).getX(), vertices.get(2).getY());
        endShape();
        break;
      } 
    popMatrix();
  }
  public void localizar(){
     switch(figura){
       case RECTANGULO:
       break;
       case TRIANGULO:
         float xa = this.vertices.get(0).x, xb= this.vertices.get(1).x, xc= this.vertices.get(2).x, 
         ya= this.vertices.get(0).y, yb= this.vertices.get(1).y, yc= this.vertices.get(2).y, A, B, C, D;
         A = (ya+yb-2*yc)/(xa+xb-2*xc);
         B = (yc*(xa+xb)-xc*(ya+yb))/(xa+xb-2*xc);
         C = (yb+yc-2*ya)/(xb+xc-2*xa);
         D = (ya*(xb+xc)-xa*(yb+yc))/(xb+xc-2*xa);
         CX = round(((D-B)/(A-C)));
         CY = round(A*CX+B);
         for(int i = 0; i<3; i++){
           this.vertices.get(i).x -= CX;
           this.vertices.get(i).y -= CY;
         }
         x = CX;
         y  = CY;
         System.out.println(CX+","+CY);
       break;
     }
  }
  public boolean validar(Silueta s){
     boolean retorno = false;
     //System.out.print("("+this.x+","+this.y+")"+"("+s.x+","+s.y+")"+"\n");
     if(figura == s.figura && s.x+10 > CX && s.x-10 < CX && s.y+10 > CY && s.y-10 < CY/*((this.x > s.x-5 && this.x < s.x+5)&&( this.y > s.y-5 && this.y < s.y-5)) && s.rotacion == 0*/){
       System.out.println("("+this.x+","+this.y+")");
       /*double lon;
       double lon2;
       boolean pertenece;
       int inicial= 0;
       boolean inicio = true;
       for(int i = 0; i< this.vertices.size(); i++){
         lon = sqrt( pow((this.vertices.get(i).x - this.vertices.get( (i+1)== this.vertices.size()? 0: i+1 ).x),2)+pow((this.vertices.get(i).y - this.vertices.get( (i+1)== this.vertices.size()? 0: i+1 ).y),2 ));
         pertenece = false;
         for(int j = inicial; j< (inicio?this.vertices.size(): inicial+1); j++){
           lon2 = sqrt( pow((s.vertices.get(i).x - s.vertices.get( (i+1)== s.vertices.size()? 0: i+1 ).x),2)+pow((this.vertices.get(i).y - this.vertices.get( (i+1)== this.vertices.size()? 0: i+1 ).y),2 ));
           if(inicio && lon == lon2){
             pertenece = true;
             inicio = false;
             inicial = j+1;
             break;
           }
         }
         if(!pertenece){
           return false;
         }
       }*/
       return true;
     }
     return retorno;
  }
}
public class Vertice{
  private int x;
  private int y;
  public Vertice(int x, int y){
    this.x = x;
    this.y = y;
  }
  public int getX(){
    return this.x;
  }
  public int getY(){
    return this.y;
  }
}

public enum Figura{
  RECTANGULO, TRIANGULO, INDEFINIDA
};
public enum AccionLectura{
  INICIO,
  NUEVO,
  X,
  Y,
  FIN_VERTICE
};