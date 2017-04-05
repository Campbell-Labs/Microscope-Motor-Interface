%Date: March 29th, 2017
%Created By: Frank Corapi (fcorapi@uwaterloo.ca)
%Controls the motors used for automation of the microscope.
function rotateMotors(motorNumber, motorAngle, thirtyCheck)
    
    %Clear arduino object
    global a;
    clear a;
    
    %Declare an Arduino Object
    a = arduino('COM6', 'micro');
    %disp(a);

    %Backlash value
    global backlash
    backlash = 8;
    
    %Test variable
    global test;
    test = 1;
    
    %***Uncomment the code below, and determine correct scaleFactors if
    %scaleFactor problem is fixed.
     global scaleFactor
     global scaleFactor2
%     scaleFactor = 11.4033;
%      scaleFactor2 = 11.2903;
    
    %Since scale factor is different at different mount angles, this piece
    %of code must be implemented. If that problem can be fixed comment out
    %this code.
     
     if thirtyCheck == 0 %From -45 to 0
        scaleFactor = 11.50728;
        scaleFactor2 = 11.24029;
     elseif thirtyCheck == 1 %From 0 to 30
         scaleFactor = 11.45293;
         scaleFactor2 = 11.5642;
     elseif thirtyCheck == 2 %From 30 to 60
         scaleFactor = 11.19395;
         scaleFactor2 = 11.20489;
     else
         error('thirtyCheck must be 0, 1 or 2');
     end
    

    %Delay between steps
    global waitTime;
    waitTime = 0;
    
    if motorNumber == 1 %motorNumber = 1 refers to a rotation of Q1
        pinNumber = 'D2';
        directionPin = 'D4';
        %Calculate number of steps from user inputed angle
        numberOfSteps = round(abs(scaleFactor*abs(motorAngle)));
    elseif motorNumber == 2 %motorNumber = 2 refers to a rotation of Q2
        pinNumber = 'D3';
        directionPin = 'D5';
        %Calculate number of steps from user inputed angle
        numberOfSteps = round(abs(scaleFactor2*abs(motorAngle)));
    else
        error('Not a valid motor number');
    end
    
    
    if motorAngle > 0
        
        %Set variables
        count = 0;
        pinState = 0;
        %Select Direction of rotation (1=forward, 0=backward)
        writeDigitalPin(a, directionPin, 1);
        %Set number of steps and backlash correction
        %The number of steps are how many times a signal is sent to the
        %arduino motor pin to change it from 1 to 0 or 0 to 1. This is
        %linearly scaled to this value by a scaleFactor that converts the
        %amount of degrees you wish to rotate the motors to the
        %numberOfSteps.
        while count < numberOfSteps && test == 1

            if pinState == 0    
                pinState = 1;
            else
                pinState = 0;
            end
            writeDigitalPin(a, pinNumber, pinState);
            count = count + 1;
            pause(waitTime);
            %Check time between steps
    %         time2 = toc;
    %         disp(time2-time1);
    %         time1 = time2;
        end
    else
        %Set variables
        count = 0;
        pinState = 0;
        %Set number of steps and backlash correction
        %The number of steps are how many times a signal is sent to the
        %arduino motor pin to change it from 1 to 0 or 0 to 1. This is
        %linearly scaled to this value by a scaleFactor that converts the
        %amount of degrees you wish to rotate the motors to the
        %numberOfSteps. This case is for moving backwards so it over shoots
        %and then corrects in order to correct for backlash.
        if motorNumber == 1
            backlash = 8;
            numberOfSteps = round(abs(scaleFactor*(abs(motorAngle)+backlash)));
            backtrackSteps = round(abs(scaleFactor*backlash));
        elseif motorNumber == 2
            backlash = 8;
            numberOfSteps = round(abs(scaleFactor2*(abs(motorAngle)+backlash)));
            backtrackSteps = round(abs(scaleFactor2*backlash));
        end
        
        %Select Direction of rotation (1=forward, 0=backward)
        writeDigitalPin(a, directionPin, 0);
        %Rotate motor
        while count < numberOfSteps && test == 1

                if pinState == 0    
                    pinState = 1;
                else
                    pinState = 0;
                end
                writeDigitalPin(a, pinNumber, pinState);
                count = count + 1;
                pause(waitTime);
                %Check time between steps
        %         time2 = toc;
        %         disp(time2-time1);
        %         time1 = time2;
        end
        count = 0;
        %Select Direction of rotation (1=forward, 0=backward)
        writeDigitalPin(a, directionPin, 1);
        %Correct for backlash by rotating back to correct location
        while count < backtrackSteps && test == 1

                if pinState == 0    
                    pinState = 1;
                else
                    pinState = 0;
                end
                writeDigitalPin(a, pinNumber, pinState);
                count = count + 1;
                pause(waitTime);
                %Check time between steps
        %         time2 = toc;
        %         disp(time2-time1);
        %         time1 = time2;
        end
    end
end