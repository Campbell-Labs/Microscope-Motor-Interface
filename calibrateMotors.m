%Date: February 23rd, 2017
%Created By: Frank Corapi (fcorapi@uwaterloo.ca)
%Calibrates the motors used for automation of the microscope.
function calibrateMotors(motorNumber)

    %Clear arduino object
    global a;
    clear a;
    
    %Declare an Arduino Object
    a = arduino('COM6', 'micro');
    %disp(a);

    %Scale factor for motor 1
    global scaleFactor;
    scaleFactor = 11.35132; %11.40068758;
    
    %Scale factor for motor 2
    global scaleFactor2;
    scaleFactor2 = 11.3406; %11.40068758;
    
    %Backlash value used to correct when changing direction from forward to
    %backward
    global backlash;
    backlash = 17;

    %Delay between steps
    global waitTime;
    waitTime = 0;
    
    pinState = 0;
    %Setting arduino pin values, and calibration distances for each motor
    if motorNumber == 1
        motorPin = 'D2';
        directionPin = 'D4';
        sensorPin = 'D6';
        distanceToHome = 174;
        writeDigitalPin(a, directionPin, 1);
        numberOfSteps = round(abs(scaleFactor*distanceToHome));
    elseif motorNumber == 2
        motorPin = 'D3';
        directionPin = 'D5';
        sensorPin = 'D7';
        distanceToHome = 69.5;
        writeDigitalPin(a, directionPin, 1);
        numberOfSteps = round(abs(scaleFactor2*abs(distanceToHome)));
%         backtrackSteps = round(abs(scaleFactor2*backlash));
    else
        error('Invalid Motor Number');
    end
    
    
    
    %Check Sensor
    lightCheck = readDigitalPin(a, sensorPin);
    
    %Rotate Motor until sensor is detected
    while lightCheck == 0
        
        %Check 
        lightCheck = readDigitalPin(a, sensorPin);
        
        if pinState == 0    
            pinState = 1;
        else
            pinState = 0;
        end
        writeDigitalPin(a, motorPin, pinState);
        pause(waitTime);
        
    end
    

        writeDigitalPin(a, directionPin, 1);
        count = 0;
            %Move Motor From Sensor to home position
        while count < numberOfSteps 

                if pinState == 0    
                    pinState = 1;
                else
                    pinState = 0;
                end
                writeDigitalPin(a, motorPin, pinState);
                count = count + 1;
                pause(waitTime);
                %Check time between steps
        %         time2 = toc;
        %         disp(time2-time1);
        %         time1 = time2;
        end

    
   


end
