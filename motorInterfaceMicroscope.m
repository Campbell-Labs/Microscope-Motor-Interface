%Motor Interface for the Microscope
%Created By: Frank Corapi (fcorapi@uwaterloo.ca)

%This is still a beta version since the scalefactor value is different
%depending on which angle the motor is currently stationed at. Until that
%problem is fixed, use this program with care.
function varargout = motorInterfaceMicroscope(varargin)
% MOTORINTERFACEMICROSCOPE MATLAB code for motorInterfaceMicroscope.fig
%      MOTORINTERFACEMICROSCOPE, by itself, creates a new MOTORINTERFACEMICROSCOPE or raises the existing
%      singleton*.
%
%      H = MOTORINTERFACEMICROSCOPE returns the handle to a new MOTORINTERFACEMICROSCOPE or the handle to
%      the existing singleton*.
%
%      MOTORINTERFACEMICROSCOPE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOTORINTERFACEMICROSCOPE.M with the given input arguments.
%
%      MOTORINTERFACEMICROSCOPE('Property','Value',...) creates a new MOTORINTERFACEMICROSCOPE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before motorInterfaceMicroscope_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to motorInterfaceMicroscope_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help motorInterfaceMicroscope

% Last Modified by GUIDE v2.5 26-Jan-2017 12:45:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @motorInterfaceMicroscope_OpeningFcn, ...
                   'gui_OutputFcn',  @motorInterfaceMicroscope_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

%---------------This interface is for use on the Microscope---------------------

% --- Executes just before motorInterfaceMicroscope is made visible.
function motorInterfaceMicroscope_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to motorInterfaceMicroscope (see VARARGIN)

% Choose default command line output for motorInterfaceMicroscope
handles.output = hObject;

%Declare an Arduino Object
global a;
a = arduino('COM6', 'micro');
%disp(a);

%Backlash value
global backlash
backlash = 8;

%Set variables
global test;
test = 1;

%Scale factor
global scaleFactor;
scaleFactor = 11.4033; %11.40068758;
    
%Scale factor
global scaleFactor2;
scaleFactor2 = 11.2903; %11.40068758;

%Delay between steps
global waitTime;
waitTime = 0;


%Initial values for variables
handles.motorOneAngle = 0;
handles.motorTwoAngle = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes motorInterfaceMicroscope wait for user response (see UIRESUME)
uiwait(handles.motorInterface);
end

% --- Outputs from this function are returned to the command line.
function varargout = motorInterfaceMicroscope_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

%Clear Arduino object
disp('Have a nice day!');
clear all;

end

% --- Executes on button press in finishButton.
function finishButton_Callback(hObject, eventdata, handles)
% hObject    handle to finishButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Close GUI
uiresume(handles.motorInterface);
close(handles.motorInterface);
end


function motorTwoValueBox_Callback(hObject, eventdata, handles)
% hObject    handle to motorTwoValueBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of motorTwoValueBox as text
%        str2double(get(hObject,'String')) returns contents of motorTwoValueBox as a double

%Get value from input box
if isnan(str2double(get(hObject, 'String')))
    
    set(handles.motorTwoValueBox, 'String', '');
    handles.motorTwoAngle = 0;
    
    warndlg('Motor Angle must be numerical.', 'Motor Angle Error', 'modal'); 
    
else
    handles.motorTwoAngle = str2double(get(hObject, 'String'));
end

guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function motorTwoValueBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to motorTwoValueBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in motorTwoMoveButton.
function motorTwoMoveButton_Callback(hObject, eventdata, handles)
% hObject    handle to motorTwoMoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disableQ2Buttons(handles);

%Call to global variables
global a;
global test;
global waitTime;
global scaleFactor2;
global backlash;
%Set variables
test = 1;
pinState = 0;
count = 0;

%Start Timer
% tic;
% time1 = toc;

%Select Direction of rotation
if handles.motorTwoAngle < 0
    writeDigitalPin(a, 'D5', 0);
    numberOfSteps = round(abs(scaleFactor2*(abs(handles.motorTwoAngle)+backlash)));
    backtrackSteps = round(abs(scaleFactor2*backlash));
    %Rotate motor two
    while count < numberOfSteps && test == 1

            if pinState == 0    
                pinState = 1;
            else
                pinState = 0;
            end
            writeDigitalPin(a, 'D3', pinState);
            count = count + 1;
            pause(waitTime);
            set(handles.finishButton, 'Enable', 'off');
            %Check time between steps
    %         time2 = toc;
    %         disp(time2-time1);
    %         time1 = time2;
    end
    count = 0;
    writeDigitalPin(a, 'D5', 1);
    while count < backtrackSteps && test == 1

            if pinState == 0    
                pinState = 1;
            else
                pinState = 0;
            end
            writeDigitalPin(a, 'D3', pinState);
            count = count + 1;
            pause(waitTime);
            set(handles.finishButton, 'Enable', 'off');
            %Check time between steps
    %         time2 = toc;
    %         disp(time2-time1);
    %         time1 = time2;
    end
else
    writeDigitalPin(a, 'D5', 1);
    numberOfSteps = round(abs(scaleFactor2*handles.motorTwoAngle));
    while count < numberOfSteps && test == 1

            if pinState == 0    
                pinState = 1;
            else
                pinState = 0;
            end
            writeDigitalPin(a, 'D3', pinState);
            count = count + 1;
            pause(waitTime);
            set(handles.finishButton, 'Enable', 'off');
            %Check time between steps
    %         time2 = toc;
    %         disp(time2-time1);
    %         time1 = time2;
    end
end

enableQ2Buttons(handles);

end


function motorOneValueBox_Callback(hObject, eventdata, handles)
% hObject    handle to motorOneValueBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of motorOneValueBox as text
%        str2double(get(hObject,'String')) returns contents of motorOneValueBox as a double

%Get value from input box
if isnan(str2double(get(hObject, 'String')))
    
    set(handles.motorOneValueBox, 'String', '');
    handles.motorOneAngle = 0;
    
    warndlg('Motor Angle must be numerical.', 'Motor Angle Error', 'modal'); 
    
else
    handles.motorOneAngle = str2double(get(hObject, 'String'));
end

guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function motorOneValueBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to motorOneValueBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in motorOneMoveButton.
function motorOneMoveButton_Callback(hObject, eventdata, handles)
% hObject    handle to motorOneMoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disableQ1Buttons(handles);

%Call to global variables
global a;
global test;
global waitTime;
global scaleFactor;
global backlash;
%Set variables
test = 1;
pinState = 0;
count = 0;


%Start Timer
% tic;
% time1 = toc;

%Select Direction of rotation
if handles.motorOneAngle < 0
    writeDigitalPin(a, 'D4', 0);
    numberOfSteps = round(abs(scaleFactor*(abs(handles.motorOneAngle)+backlash)));
    backtrackSteps = round(abs(scaleFactor*backlash));
    %Rotate motor one
    while count < numberOfSteps && test == 1

            if pinState == 0    
                pinState = 1;
            else
                pinState = 0;
            end
            writeDigitalPin(a, 'D2', pinState);
            count = count + 1;
            pause(waitTime);
            set(handles.finishButton, 'Enable', 'off');
            %Check time between steps
    %         time2 = toc;
    %         disp(time2-time1);
    %         time1 = time2;
    end
    count = 0;
    writeDigitalPin(a, 'D4', 1);
    while count < backtrackSteps && test == 1

            if pinState == 0    
                pinState = 1;
            else
                pinState = 0;
            end
            writeDigitalPin(a, 'D2', pinState);
            count = count + 1;
            pause(waitTime);
            set(handles.finishButton, 'Enable', 'off');
            %Check time between steps
    %         time2 = toc;
    %         disp(time2-time1);
    %         time1 = time2;
    end
else
    writeDigitalPin(a, 'D4', 1);
    numberOfSteps = round(abs(scaleFactor*handles.motorOneAngle));
    while count < numberOfSteps && test == 1

            if pinState == 0    
                pinState = 1;
            else
                pinState = 0;
            end
            writeDigitalPin(a, 'D2', pinState);
            count = count + 1;
            pause(waitTime);
            set(handles.finishButton, 'Enable', 'off');
            %Check time between steps
    %         time2 = toc;
    %         disp(time2-time1);
    %         time1 = time2;
    end
end


enableQ1Buttons(handles);

end


% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Stops all rotations
global a;
global test;
test = 0;
enableQ1Buttons(handles);
enableQ2Buttons(handles);
writeDigitalPin(a, 'D2', 0);
writeDigitalPin(a, 'D3', 0);
guidata(hObject, handles);
end


% --- Executes on button press in move45Button.
function move45Button_Callback(hObject, eventdata, handles)
% hObject    handle to move45Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disableQ1Buttons(handles);

%Call to global variables
global a;
global test;
global waitTime;
global scaleFactor;

%Set variables
test = 1;
pinState = 0;
count = 0;


%Start Timer
% tic;
% time1 = toc;

%Select Direction of rotation
writeDigitalPin(a, 'D4', 1);

motorAngle = 45;

%Calculate number of steps from user inputed angle
numberOfSteps = round(abs(scaleFactor*motorAngle));


%Rotate motor one
while count < numberOfSteps && test == 1
        
        if pinState == 0    
            pinState = 1;
        else
            pinState = 0;
        end
        writeDigitalPin(a, 'D2', pinState);
        count = count + 1;
        pause(waitTime);
        set(handles.finishButton, 'Enable', 'off');
        %Check time between steps
%         time2 = toc;
%         disp(time2-time1);
%         time1 = time2;
end

enableQ1Buttons(handles);

end

% --- Executes on button press in moveNeg45Button.
function moveNeg45Button_Callback(hObject, eventdata, handles)
% hObject    handle to moveNeg45Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disableQ1Buttons(handles);

%Call to global variables
global a;
global test;
global waitTime;
global scaleFactor;
global backlash;

%Set variables
test = 1;
pinState = 0;
count = 0;

%Start Timer
% tic;
% time1 = toc;

%Select Direction of rotation
writeDigitalPin(a, 'D4', 0);

motorAngle = 45;


numberOfSteps = round(abs(scaleFactor*(motorAngle + backlash)));
backtrackSteps = round(abs(scaleFactor*backlash));


%Rotate motor one
while count < numberOfSteps && test == 1
        
        if pinState == 0    
            pinState = 1;
        else
            pinState = 0;
        end
        writeDigitalPin(a, 'D2', pinState);
        count = count + 1;
        pause(waitTime);
        set(handles.finishButton, 'Enable', 'off');
        %Check time between steps
%         time2 = toc;
%         disp(time2-time1);
%         time1 = time2;
end

%Select Direction of rotation
count = 0;
writeDigitalPin(a, 'D4', 1);

while count < backtrackSteps && test == 1

            if pinState == 0    
                pinState = 1;
            else
                pinState = 0;
            end
            writeDigitalPin(a, 'D2', pinState);
            count = count + 1;
            pause(waitTime);
            set(handles.finishButton, 'Enable', 'off');
            %Check time between steps
    %         time2 = toc;
    %         disp(time2-time1);
    %         time1 = time2;
end

enableQ1Buttons(handles);

end

% --- Executes on button press in move30Button.
function move30Button_Callback(hObject, eventdata, handles)
% hObject    handle to move30Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disableQ1Buttons(handles);

%Call to global variables
global a;
global test;
global waitTime;
global scaleFactor;

%Set variables
test = 1;
pinState = 0;
count = 0;

%Start Timer
% tic;
% time1 = toc;

%Select Direction of rotation
writeDigitalPin(a, 'D4', 1);

motorAngle = 30;


%Calculate number of steps from user inputed angle
numberOfSteps = round(abs(scaleFactor*motorAngle));


%Rotate motor one
while count < numberOfSteps && test == 1
        
        if pinState == 0    
            pinState = 1;
        else
            pinState = 0;
        end
        writeDigitalPin(a, 'D2', pinState);
        count = count + 1;
        pause(waitTime);
        set(handles.finishButton, 'Enable', 'off');
        %Check time between steps
%         time2 = toc;
%         disp(time2-time1);
%         time1 = time2;
end

enableQ1Buttons(handles);

end

% --- Executes on button press in moveNeg30Button.
function moveNeg30Button_Callback(hObject, eventdata, handles)
% hObject    handle to moveNeg30Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disableQ1Buttons(handles);

%Call to global variables
global a;
global test;
global waitTime;
global scaleFactor;
global backlash;

%Set variables
test = 1;
pinState = 0;
count = 0;

%Start Timer
% tic;
% time1 = toc;

%Select Direction of rotation
writeDigitalPin(a, 'D4', 0);

motorAngle = 30;

numberOfSteps = round(abs(scaleFactor*(motorAngle + backlash)));
backtrackSteps = round(abs(scaleFactor*backlash));

%Rotate motor one
while count < numberOfSteps && test == 1
        
        if pinState == 0    
            pinState = 1;
        else
            pinState = 0;
        end
        writeDigitalPin(a, 'D2', pinState);
        count = count + 1;
        pause(waitTime);
        set(handles.finishButton, 'Enable', 'off');
        %Check time between steps
%         time2 = toc;
%         disp(time2-time1);
%         time1 = time2;
end

%Select Direction of rotation
count = 0;
writeDigitalPin(a, 'D4', 1);

while count < backtrackSteps && test == 1

            if pinState == 0    
                pinState = 1;
            else
                pinState = 0;
            end
            writeDigitalPin(a, 'D2', pinState);
            count = count + 1;
            pause(waitTime);
            set(handles.finishButton, 'Enable', 'off');
            %Check time between steps
    %         time2 = toc;
    %         disp(time2-time1);
    %         time1 = time2;
end

enableQ1Buttons(handles);

end

% --- Executes on button press in move105Button.
function move105Button_Callback(hObject, eventdata, handles)
% hObject    handle to move105Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disableQ1Buttons(handles);

%Call to global variables
global a;
global test;
global waitTime;
global scaleFactor;

%Set variables
test = 1;
pinState = 0;
count = 0;

%Start Timer
% tic;
% time1 = toc;

%Select Direction of rotation
writeDigitalPin(a, 'D4', 1);

motorAngle = 105;

%Calculate number of steps from user inputed angle
numberOfSteps = round(abs(scaleFactor*motorAngle));


%Rotate motor one
while count < numberOfSteps && test == 1
        
        if pinState == 0    
            pinState = 1;
        else
            pinState = 0;
        end
        writeDigitalPin(a, 'D2', pinState);
        count = count + 1;
        pause(waitTime);
        set(handles.finishButton, 'Enable', 'off');
        %Check time between steps
%         time2 = toc;
%         disp(time2-time1);
%         time1 = time2;
end

enableQ1Buttons(handles);

end

% --- Executes on button press in moveNeg105Button.
function moveNeg105Button_Callback(hObject, eventdata, handles)
% hObject    handle to moveNeg105Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disableQ1Buttons(handles);

%Call to global variables
global a;
global test;
global waitTime;
global scaleFactor;
global backlash;

%Set variables
test = 1;
pinState = 0;
count = 0;

%Start Timer
% tic;
% time1 = toc;

%Select Direction of rotation
writeDigitalPin(a, 'D4', 0);

motorAngle = 105;

numberOfSteps = round(abs(scaleFactor*(motorAngle + backlash)));
backtrackSteps = round(abs(scaleFactor*backlash));


%Rotate motor one
while count < numberOfSteps && test == 1
        
        if pinState == 0    
            pinState = 1;
        else
            pinState = 0;
        end
        writeDigitalPin(a, 'D2', pinState);
        count = count + 1;
        pause(waitTime);
        set(handles.finishButton, 'Enable', 'off');
        %Check time between steps
%         time2 = toc;
%         disp(time2-time1);
%         time1 = time2;
end

%Select Direction of rotation
count = 0;
writeDigitalPin(a, 'D4', 1);

while count < backtrackSteps && test == 1

            if pinState == 0    
                pinState = 1;
            else
                pinState = 0;
            end
            writeDigitalPin(a, 'D2', pinState);
            count = count + 1;
            pause(waitTime);
            set(handles.finishButton, 'Enable', 'off');
            %Check time between steps
    %         time2 = toc;
    %         disp(time2-time1);
    %         time1 = time2;
end

enableQ1Buttons(handles);

end

% --- Executes on button press in move45ButtonTwo.
function move45ButtonTwo_Callback(hObject, eventdata, handles)
% hObject    handle to move45ButtonTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disableQ2Buttons(handles);

%Call to global variables
global a;
global test;
global waitTime;
global scaleFactor2;

%Set variables
test = 1;
pinState = 0;
count = 0;

% Start Timer
% tic;
% time1 = toc;

%Select Direction of rotation
writeDigitalPin(a, 'D5', 1);

motorAngle = 45;


%Calculate number of steps from user inputed angle
numberOfSteps = round(abs(scaleFactor2*motorAngle));


%Rotate motor two
while count < numberOfSteps && test == 1
        
        if pinState == 0    
            pinState = 1;
        else
            pinState = 0;
        end
        writeDigitalPin(a, 'D3', pinState);
        count = count + 1;
        pause(waitTime);
        set(handles.finishButton, 'Enable', 'off');
        %Check time between steps
%         time2 = toc;
%         disp(time2-time1);
%         time1 = time2;
        
end

enableQ2Buttons(handles);

end

% --- Executes on button press in moveNeg45ButtonTwo.
function moveNeg45ButtonTwo_Callback(hObject, eventdata, handles)
% hObject    handle to moveNeg45ButtonTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disableQ2Buttons(handles);

%Call to global variables
global a;
global test;
global waitTime;
global scaleFactor2;
global backlash;

%Set variables
test = 1;
pinState = 0;
count = 0;

%Start Timer
% tic;
% time1 = toc;

%Select Direction of rotation
writeDigitalPin(a, 'D5', 0);

motorAngle = 45;

numberOfSteps = round(abs(scaleFactor2*(motorAngle + backlash)));
backtrackSteps = round(abs(scaleFactor2*backlash));


%Rotate motor one
while count < numberOfSteps && test == 1
        
        if pinState == 0    
            pinState = 1;
        else
            pinState = 0;
        end
        writeDigitalPin(a, 'D3', pinState);
        count = count + 1;
        pause(waitTime);
        set(handles.finishButton, 'Enable', 'off');
        %Check time between steps
%         time2 = toc;
%         disp(time2-time1);
%         time1 = time2;
end

%Select Direction of rotation
count = 0;
writeDigitalPin(a, 'D5', 1);

while count < backtrackSteps && test == 1

            if pinState == 0    
                pinState = 1;
            else
                pinState = 0;
            end
            writeDigitalPin(a, 'D3', pinState);
            count = count + 1;
            pause(waitTime);
            set(handles.finishButton, 'Enable', 'off');
            %Check time between steps
    %         time2 = toc;
    %         disp(time2-time1);
    %         time1 = time2;
end


enableQ2Buttons(handles);

end

% --- Executes on button press in move30ButtonTwo.
function move30ButtonTwo_Callback(hObject, eventdata, handles)
% hObject    handle to move30ButtonTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disableQ2Buttons(handles);

%Call to global variables
global a;
global test;
global waitTime;
global scaleFactor2;

%Set variables
test = 1;
pinState = 0;
count = 0;

%Start Timer
% tic;
% time1 = toc;

%Select Direction of rotation
writeDigitalPin(a, 'D5', 1);

motorAngle = 30;

%Calculate number of steps from user inputed angle
numberOfSteps = round(abs(scaleFactor2*motorAngle));


%Rotate motor two
while count < numberOfSteps && test == 1
        
        if pinState == 0    
            pinState = 1;
        else
            pinState = 0;
        end
        writeDigitalPin(a, 'D3', pinState);
        count = count + 1;
        pause(waitTime);
        set(handles.finishButton, 'Enable', 'off');
        %Check time between steps
%         time2 = toc;
%         disp(time2-time1);
%         time1 = time2;
        
end

enableQ2Buttons(handles);

end

% --- Executes on button press in moveNeg30ButtonTwo.
function moveNeg30ButtonTwo_Callback(hObject, eventdata, handles)
% hObject    handle to moveNeg30ButtonTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disableQ2Buttons(handles);

%Call to global variables
global a;
global test;
global waitTime;
global scaleFactor2;
global backlash;

%Set variables
test = 1;
pinState = 0;
count = 0;

%Start Timer
% tic;
% time1 = toc;

%Select Direction of rotation
writeDigitalPin(a, 'D5', 0);

motorAngle = 30;

numberOfSteps = round(abs(scaleFactor2*(motorAngle + backlash)));
backtrackSteps = round(abs(scaleFactor2*backlash));


%Rotate motor one
while count < numberOfSteps && test == 1
        
        if pinState == 0    
            pinState = 1;
        else
            pinState = 0;
        end
        writeDigitalPin(a, 'D3', pinState);
        count = count + 1;
        pause(waitTime);
        set(handles.finishButton, 'Enable', 'off');
        %Check time between steps
%         time2 = toc;
%         disp(time2-time1);
%         time1 = time2;
end

%Select Direction of rotation
count = 0;
writeDigitalPin(a, 'D5', 1);

while count < backtrackSteps && test == 1

            if pinState == 0    
                pinState = 1;
            else
                pinState = 0;
            end
            writeDigitalPin(a, 'D3', pinState);
            count = count + 1;
            pause(waitTime);
            set(handles.finishButton, 'Enable', 'off');
            %Check time between steps
    %         time2 = toc;
    %         disp(time2-time1);
    %         time1 = time2;
end

enableQ2Buttons(handles);

end

% --- Executes on button press in move105ButtonTwo.
function move105ButtonTwo_Callback(hObject, eventdata, handles)
% hObject    handle to move105ButtonTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disableQ2Buttons(handles);

%Call to global variables
global a;
global test;
global waitTime;
global scaleFactor2;

%Set variables
test = 1;
pinState = 0;
count = 0;

%Start Timer
% tic;
% time1 = toc;

%Select Direction of rotation
writeDigitalPin(a, 'D5', 1);

motorAngle = 105;

%Calculate number of steps from user inputed angle
numberOfSteps = round(abs(scaleFactor2*motorAngle));


%Rotate motor two
while count < numberOfSteps && test == 1
        
        if pinState == 0    
            pinState = 1;
        else
            pinState = 0;
        end
        writeDigitalPin(a, 'D3', pinState);
        count = count + 1;
        pause(waitTime);
        set(handles.finishButton, 'Enable', 'off');
        %Check time between steps
%         time2 = toc;
%         disp(time2-time1);
%         time1 = time2;
        
end

enableQ2Buttons(handles);

end

% --- Executes on button press in moveNeg105ButtonTwo.
function moveNeg105ButtonTwo_Callback(hObject, eventdata, handles)
% hObject    handle to moveNeg105ButtonTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disableQ2Buttons(handles);

%Call to global variables
global a;
global test;
global waitTime;
global scaleFactor2;
global backlash;

%Set variables
test = 1;
pinState = 0;
count = 0;

%Start Timer
% tic;
% time1 = toc;

%Select Direction of rotation
writeDigitalPin(a, 'D5', 0);
motorAngle = 105;

numberOfSteps = round(abs(scaleFactor2*(motorAngle + backlash)));
backtrackSteps = round(abs(scaleFactor2*backlash));


%Rotate motor one
while count < numberOfSteps && test == 1
        
        if pinState == 0    
            pinState = 1;
        else
            pinState = 0;
        end
        writeDigitalPin(a, 'D3', pinState);
        count = count + 1;
        pause(waitTime);
        set(handles.finishButton, 'Enable', 'off');
        %Check time between steps
%         time2 = toc;
%         disp(time2-time1);
%         time1 = time2;
end

%Select Direction of rotation
count = 0;
writeDigitalPin(a, 'D5', 1);

while count < backtrackSteps && test == 1

            if pinState == 0    
                pinState = 1;
            else
                pinState = 0;
            end
            writeDigitalPin(a, 'D3', pinState);
            count = count + 1;
            pause(waitTime);
            set(handles.finishButton, 'Enable', 'off');
            %Check time between steps
    %         time2 = toc;
    %         disp(time2-time1);
    %         time1 = time2;
end

enableQ2Buttons(handles);

end

%%
function disableQ1Buttons(handles)

    set(handles.motorOneMoveButton, 'Enable', 'off');
    set(handles.move45Button, 'Enable', 'off');
    set(handles.moveNeg45Button, 'Enable', 'off');
    set(handles.move30Button, 'Enable', 'off');
    set(handles.moveNeg30Button, 'Enable', 'off');
    set(handles.move105Button, 'Enable', 'off');
    set(handles.moveNeg105Button, 'Enable', 'off');
    set(handles.finishButton, 'Enable', 'off');
   

end

function disableQ2Buttons(handles)

    set(handles.motorTwoMoveButton, 'Enable', 'off');
    set(handles.move45ButtonTwo, 'Enable', 'off');
    set(handles.moveNeg45ButtonTwo, 'Enable', 'off');
    set(handles.move30ButtonTwo, 'Enable', 'off');
    set(handles.moveNeg30ButtonTwo, 'Enable', 'off');
    set(handles.move105ButtonTwo, 'Enable', 'off');
    set(handles.moveNeg105ButtonTwo, 'Enable', 'off');
    set(handles.finishButton, 'Enable', 'off');
  
end

 
function enableQ1Buttons(handles)

    set(handles.motorOneMoveButton, 'Enable', 'on');
    set(handles.move45Button, 'Enable', 'on');
    set(handles.moveNeg45Button, 'Enable', 'on');
    set(handles.move30Button, 'Enable', 'on');
    set(handles.moveNeg30Button, 'Enable', 'on');
    set(handles.move105Button, 'Enable', 'on');
    set(handles.moveNeg105Button, 'Enable', 'on');
    set(handles.finishButton, 'Enable', 'on');
   

end

function enableQ2Buttons(handles)

    set(handles.motorTwoMoveButton, 'Enable', 'on');
    set(handles.move45ButtonTwo, 'Enable', 'on');
    set(handles.moveNeg45ButtonTwo, 'Enable', 'on');
    set(handles.move30ButtonTwo, 'Enable', 'on');
    set(handles.moveNeg30ButtonTwo, 'Enable', 'on');
    set(handles.move105ButtonTwo, 'Enable', 'on');
    set(handles.moveNeg105ButtonTwo, 'Enable', 'on');
    set(handles.finishButton, 'Enable', 'on');
   

end
