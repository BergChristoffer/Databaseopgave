import de.bezier.data.sql.*; //<>//
import java.security.*;
import controlP5.*;

ControlP5 cp5;
SQLite db;

String sql, createUsername, createPassword, loginUsername, loginPassword, messageTo, typeMessage = "";
boolean textMessage, create, messageSent;
int i;

void setup() {
  frameRate(60);
  size(800, 500);
  textSize(32);
  fill(255);
  textMessage = false;
  create = false;
  messageSent = false;
  startScreen();
}


void draw () {
  background(0);
  if (textMessage)
    textMessage();

  if (create) {
    if (i < 300) {
      fill(0, 255, 0);
      textSize(20);
      text("User created", 500, 400);
    } else if (i >= 300) {
      create = false;
      i = 0;
    }
  }

  if (messageSent) {
    if (i < 300) {
      fill(0, 255, 0);
      textSize(20);
      text("Message sent", 550, 125);
    } else if (i > 300) {
      messageSent = false;
      i = 0;
    }
  }
  
  
  ++i;
}


void createUser() {

  // Connect to database
  db = new SQLite( this, "Login.sqlite" );
  if ( db.connect() )
  {
    try {

      if (createUsername != "" && createPassword != "") {

        // Password hashing
        MessageDigest md = MessageDigest.getInstance("SHA-512"); 
        md.update(createPassword.getBytes());    
        byte[] byteList = md.digest();
        StringBuffer hashedValueBuffer = new StringBuffer();
        for (byte b : byteList)hashedValueBuffer.append(hex(b)); 

        // Insert username & hashed password into database
        sql = "INSERT INTO Login (Username,Password,MessageFrom,Message) VALUES ('" + createUsername + "', '" + hashedValueBuffer.toString() + "','" + "1" + "','" + "1" + "');";
        db.execute(sql);

        createUsername = "";
        createPassword = "";
      }
    }
    catch (Exception e) {
      System.out.println("Exception: "+e);
    }
  } else
  {

    println("Error DB");
  }
}

void login() {

  db = new SQLite( this, "Login.sqlite" );
  if ( db.connect() )
  { 
    try
    {
      if (loginUsername != "" && loginPassword != "") { 

        // Password hashing
        MessageDigest md = MessageDigest.getInstance("SHA-512"); 
        md.update(loginPassword.getBytes());    
        byte[] byteList = md.digest();
        StringBuffer hashedValueBuffer = new StringBuffer();
        for (byte b : byteList)hashedValueBuffer.append(hex(b)); 

        // Check if Username and Password matches database
        db.query( "SELECT ID, Username, Password FROM Login WHERE Username = '" + loginUsername + "' AND Password = '" + hashedValueBuffer.toString() +"'" );

        int count = 0;

        while (db.next()) {
          count++;
        }

        if (count==0) {
          println("FORKERT PASSWORD ELLER BRUGERNAVN");
        } else {
          messageScreen();
          textMessage = true;
        }

        db.close();
      }
    }
    catch (Exception e) {
      System.out.println("Exception: "+e);
    }
  } else
  {
    println("Error DB");
  }
}

void startScreen() {
  cp5 = new ControlP5(this);

  cp5.addTextfield("Username")
    .setPosition(100, 100)
    .setSize(200, 40)
    .setFont(createFont("arial", 20))
    .setAutoClear(false)
    ;

  cp5.addTextfield("Password")
    .setPosition(100, 200)
    .setSize(200, 40)
    .setFont(createFont("arial", 20))
    .setAutoClear(false)
    .setPasswordMode(true)
    ; 

  cp5.addButton("Login")
    .setPosition(100, 300)
    .setFont(createFont("arial", 15))
    .setSize(200, 50)
    ;

  cp5.addTextfield("Create Username")
    .setPosition(500, 100)
    .setSize(200, 40)
    .setFont(createFont("arial", 20))
    .setAutoClear(false)
    ;

  cp5.addTextfield("Create Password")
    .setPosition(500, 200)
    .setSize(200, 40)
    .setFont(createFont("arial", 20))
    .setAutoClear(false)
    .setPasswordMode(true)
    ;

  cp5.addButton("Create User")
    .setPosition(500, 300)
    .setFont(createFont("arial", 15))
    .setSize(200, 50)
    ;
}

void controlEvent(ControlEvent theEvent) {


  if (theEvent.isAssignableFrom(Textfield.class)) {

    if (theEvent.getName() == "Password") {  
      loginUsername= cp5.get(Textfield.class, "Username").getText();
      loginPassword = theEvent.getStringValue();
      login();
    }

    if (theEvent.getName() == "Create Password") {
      createUsername = cp5.get(Textfield.class, "Create Username").getText();
      createPassword = theEvent.getStringValue();
      create = true;
      i=0;
      createUser();
    }

    if (theEvent.getName() == "Type message") {
      messageTo = cp5.get(Textfield.class, "Message to").getText();
      typeMessage = theEvent.getStringValue();
      sendMessage();
      messageSent = true;
      i=0;
    }
  }

  if (theEvent.getName() == "Back") {
    cp5.hide();
    textMessage = false;
    startScreen();
    
  }

  if (theEvent.getName() == "Login") {
    println("2");
    println(cp5.get(Textfield.class, "Username").getText());
    loginUsername= cp5.get(Textfield.class, "Username").getText();
    loginPassword = cp5.get(Textfield.class, "Password").getText();
    login();
  }

  if (theEvent.getName() == "Create User") {
    createUsername= cp5.get(Textfield.class, "Create Username").getText();
    createPassword = cp5.get(Textfield.class, "Create Password").getText();
    create = true;
    i=0;
    createUser();
  }

  if (theEvent.getName() == "Send message") {
    messageTo = cp5.get(Textfield.class, "Message to").getText();
    typeMessage = cp5.get(Textfield.class, "Type message").getText();
    sendMessage();
    messageSent = true;
    i=0;
  }
}

void messageScreen() {

  cp5.remove("Username");
  cp5.remove("Password");
  cp5.remove("Create Username");
  cp5.remove("Create Password");
  cp5.remove("Login");
  cp5.remove("Create User");


  cp5.addTextfield("Message to")
    .setPosition(50, 50)
    .setSize(200, 40)
    .setFont(createFont("arial", 20))
    .setAutoClear(false)
    ;

  cp5.addTextfield("Type message")
    .setPosition(300, 50)
    .setSize(200, 40)
    .setFont(createFont("arial", 20))
    .setAutoClear(false)
    ;

  cp5.addButton("Back")
    .setPosition(600, 400)
    .setFont(createFont("arial", 15))
    .setSize(200, 100)
    ;

  cp5.addButton("Send message")
    .setPosition(550, 50)
    .setFont(createFont("arial", 15))
    .setSize(150, 50)
    ;
}

void sendMessage() {
  db = new SQLite( this, "Login.sqlite" );
  if ( db.connect() )
  { 

    if (messageTo != "" && typeMessage != "" ) { 

      // Check if User exists
      db.query( "SELECT Username FROM Login WHERE Username = '" + messageTo + "' ");
      int count = 0;
      while (db.next()) {
        count++;
      }

      if (count==0) {
        println("Bruger findes ikke");
      } else {
        println("Bruger findes");

        //Insert message into database
        db = new SQLite( this, "Login.sqlite" );
        if (db.connect()) {
          sql = "UPDATE Login SET MessageFrom = '"+ loginUsername + "', Message = '" + typeMessage + "' WHERE Username ='" + messageTo +"' ";
          db.execute(sql);
        }
      }

      messageTo = "";
      typeMessage = "";
    } else
    {
      println("Error DB");
    }
  }
}

void textMessage() { 
  fill(255);
  db = new SQLite( this, "Login.sqlite" );
  if ( db.connect() ) {

    db.query( "SELECT MessageFrom, Message FROM Login WHERE Username = '" + loginUsername + "' ");

    if (db.getString("MessageFrom") == "1" && db.getString("Message") == "1") {
      textSize(20);
      text("No recieved messages", 50, 200);
    } else {
      text("Latest message recieved from "  + db.getString("MessageFrom") + ":", 50, 200);
      textSize(20);
      String mes = db.getString("Message");
      if(!mes.isEmpty()){
      text(mes, 50, 225);
      
      }
    }
    db.close();
  }
}
