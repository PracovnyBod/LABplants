#include <Arduino.h>




// ---------------------------------------------------------

const byte numChars = 32;
char receivedChars[numChars];
boolean newData = false;

int val_receivedChars = 0;
int val_receivedChars_abs = 0;


int val_A0 = 0;  // potenciometer
int val_A1 = 0;  // otacky motora




unsigned long time_curr;
unsigned long time_tick = 0;
unsigned long time_delta;

unsigned long time_curr_data;

boolean LED_on = false;

// ---------------------------------------------------------

void setup() {
    Serial.begin(115200);
    Serial.println("--- MCU starting ---");

    pinMode(13, OUTPUT); // for LED
    pinMode(10, OUTPUT); // for PWM

    pinMode(8, OUTPUT); //IN2
    pinMode(9, OUTPUT); //IN1

    // motor forward
    digitalWrite(8, HIGH);
    digitalWrite(9, LOW);    
}

// ---------------------------------------------------------



void recvWithEndMarker() {
    // Read incoming data from a serial communication channel
    // until a specified end marker is encountered. 
    static byte ndx = 0;
    char endMarker = '\n';
    char rc;
    
    // Check if there is data available to read from the serial port
    if (Serial.available() > 0) {
        // Read one character from the serial port
        rc = Serial.read();

        // Check if the read character is not the specified end marker
        if (rc != endMarker) {
            // Store the character in the receivedChars array
            receivedChars[ndx] = rc;
            // Increment the index (ndx) for the next character
            ndx++;
            // Ensure ndx does not exceed the size of the receivedChars array
            if (ndx >= numChars) {
                ndx = numChars - 1;
            }
        }
        else {
            // If the end marker is encountered, terminate the string and reset the index
            receivedChars[ndx] = '\0';
            ndx = 0;

            // Set a flag (newData) to indicate that new data is available
            newData = true;
        }
    }
}


void processNewData() {
    if (newData == true) {
        newData = false;

        time_curr_data = millis();


        val_A0 = analogRead(A0);
        val_A1 = analogRead(A1);
        
        val_receivedChars = atoi(receivedChars);

        if (val_receivedChars > 0) {
            // motor forward
            digitalWrite(8, HIGH);
            digitalWrite(9, LOW);
        }
        if (val_receivedChars < 0) {
            // motor backward
            digitalWrite(8, LOW);
            digitalWrite(9, HIGH);
        }

        val_receivedChars_abs = abs(val_receivedChars);


        analogWrite(10, val_receivedChars_abs);


        Serial.print(time_curr_data);
        Serial.print(" ");
        Serial.print(val_A0);
        Serial.print(" ");
        Serial.print(val_A1);
        Serial.print(" ");
        Serial.print(val_receivedChars);
        Serial.print(" ");
        Serial.print("\n");
 
    }
}






void buildInLedBlink() {

    unsigned long T_sample = 1000;
    unsigned long LED_onTime = 100;

    time_delta = time_curr - time_tick;

    if (LED_on == true) {
        if (time_delta >= LED_onTime) {
            digitalWrite(13, LOW);
            LED_on = false;
        }
    }

    if (time_delta >= T_sample) {
        time_tick = time_curr;

        digitalWrite(13, HIGH);
        LED_on = true;
    }
}





// ---------------------------------------------------------


void loop() {
    time_curr = millis();
    
    recvWithEndMarker();

    processNewData();

    buildInLedBlink();

    // delay(2);

}