%Initial code written by Riley Delaney - rd167956@hotmail.com
%Debug and improvements done by Riley Delaney and Michael Hamel  

function varargout = MMI(varargin)
% MMI MATLAB code for MMI.fig
%      MMI, by itself, creates a new MMI or raises the existing
%      singleton*.
%
%      H = MMI returns the handle to a new MMI or the handle to
%      the existing singleton*.
%
%      MMI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MMI.M with the given input arguments.
%
%      MMI('Property','Value',...) creates a new MMI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MMI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MMI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MMI

% Last Modified by GUIDE v2.5 29-Mar-2017 14:21:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MMI_OpeningFcn, ...
                   'gui_OutputFcn',  @MMI_OutputFcn, ...
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

% --- Executes just before MMI is made visible.
function MMI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MMI (see VARARGIN)

% Choose default command line output for MMI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MMI wait for user response (see UIRESUME)
% uiwait(handles.MuellerCapture);


% --- Outputs from this function are returned to the command line.
function varargout = MMI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in RunCapture.
function RunCapture_Callback(hObject, eventdata, handles)
robot = java.awt.Robot;

% makes a variable from the input
fileName = str2mat([get(handles.FileName,'String') '_']);
filePath = get(handles.PathEdit,'String');
clipboard('copy', fileName)

% set default folder to C:\Image dropoff
if strcmp(filePath, 'Default')
    filePath = 'C:\Image dropoff';
end 

% Switches priority to NIS Elements
tapkey('F14')
robot.waitForIdle ()
robot.delay(100);

% checks if any files exist already
fileName = str2mat(CheckExistenceMM(fileName, filePath));
robot.delay(10);

% a for loop for each polarizer 
for pFilter = 1:16
    % names each file with the polarizer and rotates motors as necessary 
   switch pFilter
       case 1
           file = strcat(fileName,'4560');
       case 2
           file = strcat(fileName,'4530');
           rotateMotors(2,-30,2)  %Motor2,-30 (4560->4530)
       case 3
           file = strcat(fileName,'4500');
           rotateMotors(2,-30,1)  %Motor2,-30 (4530->4500)
       case 4
           file = strcat(fileName,'4545');
           rotateMotors(2,-45,0)   %Motor2,-45 (4500->4545)
       case 5
           file = strcat(fileName,'0045');
           rotateMotors(1,+45,0)  %Motor1,+45 (4545->0045)
       case 6
           file = strcat(fileName,'0000');
           rotateMotors(2,+45,0)  %Motor2,+45 (0045->0000)
       case 7
           file = strcat(fileName,'0030');
           rotateMotors(2,30,1)   %Motor2,+30 (0000->0030)
       case 8
           file = strcat(fileName,'0060');
           rotateMotors(2,30,2)   %Motor2,+30 (0030->0060)
       case 9
           file = strcat(fileName,'3060');
           rotateMotors(1,30,1)   %Motor1,+30 (0060->3060)
       case 10
           file = strcat(fileName,'3030');
           rotateMotors(2,-30,2)  %Motor2,-30 (3060->3030)
       case 11
           file = strcat(fileName,'3000');
           rotateMotors(2,-30,1)  %Motor2,-30 (3030->3000)
       case 12
           file = strcat(fileName,'3045');
           rotateMotors(2,-45,0)   %Motor2,-45 (3000->3045)
       case 13
           file = strcat(fileName,'6045');
           rotateMotors(1,30,2)   %Motor1,+30 (3045->6045)
       case 14
           file = strcat(fileName,'6000');
           rotateMotors(2,+45,0)  %Motor2,+45 (6045->6000)
       case 15
           file = strcat(fileName,'6030');
           rotateMotors(2,30,1)   %Motor2,+30 (6000->6030)
       case 16
           file = strcat(fileName,'6060');
           rotateMotors(2,30,2)   %Motor2,+30 (6030->6060)
   end
   
   % adds file to the clipboard 
   clipboard('copy', file)
   
   % displays information for the user
   X = [filePath,' - Folder'];
   disp(X)
   disp(file)
   
   % sends information to a function to take the picture
   TakePicture(file, filePath, true)
end

robot.delay(1000);
tapkey('sub')
robot.delay(1000);

% sends information to Erik's alignment code
PreRegistrationConfig_Auto(filePath)
Erik_Alignment_PhaseCorrelation_Auto(fileName, filePath)

% makes this program priority
tapkey('F16')
robot.delay(100);

% Finish program sound, suggested: 0 for regular uses
% You might choice to use 1 for debugging, as the beep is the same 
% sound as the noise made when there is an error. Use 1 at ~10 volume
debugSound = 1;
if debugSound==0
    beep
elseif debugSound==1
    load gong.mat;
    sound(y);
elseif debugSound==2
    load handel.mat; 
    sound(y);
end

% calibrates the motors
waitfor(msgbox('You can now move the motors and press "OK" for the motors to calibrate.'));
calibrateMotors(1);
calibrateMotors(2);
set(handles.change60To45,'enable','on');
set(handles.change45To60, 'enable', 'off');
if debugSound==0
    beep
elseif debugSound==1
    load gong.mat;
    sound(y);
elseif debugSound==2
    load handel.mat; 
    sound(y);
end
disp('====')



% hObject    handle to RunCapture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function TakePicture(file, filePath, saveFile, florTime)
% assign variables
robot = java.awt.Robot;
debug = false;
time = 500; % ms for 30ms exposure time

% determines if worst case 
if nargin < 4
    florTime = false;
end

% sets time to worst case
if florTime
    time = 1500;
end

% moves the mouse away from anything important
robot.mouseMove(1500, 200)

% checks if the pictures are being saved in a different folder
if false==strcmp(filePath, 'Current')
    file = strcat(filePath,  '\', file);
end

% Runs the camera
tapkey('plus')
robot.waitForIdle ()
robot.delay(time);

% Preforms ctrl -, captures image
robot.keyPress    (java.awt.event.KeyEvent.VK_CONTROL);
tapkey('sub')
robot.keyRelease  (java.awt.event.KeyEvent.VK_CONTROL);
robot.waitForIdle ()
robot.delay(time);
if debug
    disp('Picture Taken');
end

% sends the information to be saved if a picture is being taken
if saveFile
    SaveFile(file, filePath)
end

function SaveFile(file, filePath)
% assign variables
robot = java.awt.Robot;
debug = false;
time = 500; % ms for 30ms exppure time

% saves both files
for fileType = 1:2
    % Preforms alt f, opens file tab
    robot.keyPress    (java.awt.event.KeyEvent.VK_ALT);
    tapkey('f')
    robot.keyRelease  (java.awt.event.KeyEvent.VK_ALT);
    if debug
       disp('File Open');
    end
    robot.delay(time);
    
    % Goes to Save As
    tapkey('a')
    robot.waitForIdle ()
    robot.delay(time/2);
    
    % adds file to clipboard
    clipboard('copy', file)
    robot.delay(100);
    
    % Preforms ctrl v, paste
    robot.keyPress    (java.awt.event.KeyEvent.VK_CONTROL);
    tapkey('v')
    robot.keyRelease  (java.awt.event.KeyEvent.VK_CONTROL);
    robot.waitForIdle ()
    if debug 
        disp ('paste in file name')
    end
    robot.delay(time/2);
    
    % goes to file type
    tapkey('tab')
    robot.delay(10);
    
    switch fileType
        % case one saves nd2 file
        case 1
            % saves nd2
            tapkey('dwn')
            robot.delay(10);
            for i = 1:8
                tapkey('up')
                robot.delay(10);
            end
            for j = 1:3
                tapkey('dwn')
                robot.delay(10);
            end
            tapkey('ent')
            robot.delay(10);
            tapkey('ent')
            robot.delay(10);
            
        % case two saves bmp file
        case 2
            % saves bmp
            tapkey('dwn')
            robot.delay(10);
            for i = 1:10
                tapkey('up')
                robot.delay(10);
            end
            for j = 1:6
                tapkey('dwn')
                robot.delay(10);
            end
            tapkey('ent')
            robot.delay(10);
            tapkey('ent')
            robot.delay(10);
                        
        robot.waitForIdle ()
    end
end

% control F4 closes the picture that was saved
robot.keyPress    (java.awt.event.KeyEvent.VK_CONTROL);
tapkey('F4')
robot.keyRelease  (java.awt.event.KeyEvent.VK_CONTROL);
robot.delay(time/4);

% puts camera back to live
tapkey('plus')
robot.delay(time/2);

% tells user if any fail and which ones failed
passed = exist(strcat(file,'.bmp'),'file')&&exist(strcat(file,'.nd2'),'file');

if passed
    disp('Passed')
elseif strcmp(filePath, 'Current')
    disp('Path unknown by matlab.')
else
    disp('Failed')
end
disp('----')

robot.delay(10)

function tapkey(key)
robot = java.awt.Robot;
% preforms a key tap(i.e. press and release) for the key that is inputted
switch key
    case 'a'
        robot.keyPress    (java.awt.event.KeyEvent.VK_A);
        robot.keyRelease  (java.awt.event.KeyEvent.VK_A);
    case 'F4'
        robot.keyPress    (java.awt.event.KeyEvent.VK_F4);
        robot.keyRelease  (java.awt.event.KeyEvent.VK_F4);
    case 'F14'
        robot.keyPress    (java.awt.event.KeyEvent.VK_F14);
        robot.keyRelease  (java.awt.event.KeyEvent.VK_F14);
    case 'F16'
        robot.keyPress    (java.awt.event.KeyEvent.VK_F16);
        robot.keyRelease  (java.awt.event.KeyEvent.VK_F16);
    case 'y'
        robot.keyPress    (java.awt.event.KeyEvent.VK_Y);
        robot.keyRelease  (java.awt.event.KeyEvent.VK_Y);
    case 'v'
        robot.keyPress    (java.awt.event.KeyEvent.VK_V);
        robot.keyRelease  (java.awt.event.KeyEvent.VK_V);
    case 'f'
        robot.keyPress    (java.awt.event.KeyEvent.VK_F);
        robot.keyRelease  (java.awt.event.KeyEvent.VK_F);
    case 'plus'
        robot.keyPress    (java.awt.event.KeyEvent.VK_ADD);
        robot.keyRelease  (java.awt.event.KeyEvent.VK_ADD);
    case 'minus'
        robot.keyPress    (java.awt.event.KeyEvent.VK_MINUS);
        robot.keyRelease  (java.awt.event.KeyEvent.VK_MINUS);
    case 'sub'
        robot.keyPress    (java.awt.event.KeyEvent.VK_SUBTRACT);
        robot.keyRelease  (java.awt.event.KeyEvent.VK_SUBTRACT);
    case 'tab'
        robot.keyPress    (java.awt.event.KeyEvent.VK_TAB);
        robot.keyRelease  (java.awt.event.KeyEvent.VK_TAB);
    case 'dwn'
        robot.keyPress    (java.awt.event.KeyEvent.VK_DOWN);
        robot.keyRelease  (java.awt.event.KeyEvent.VK_DOWN);
    case 'up'
        robot.keyPress    (java.awt.event.KeyEvent.VK_UP);
        robot.keyRelease  (java.awt.event.KeyEvent.VK_UP);
    case 'ent'
        robot.keyPress    (java.awt.event.KeyEvent.VK_ENTER);
        robot.keyRelease  (java.awt.event.KeyEvent.VK_ENTER);
end


function returnName = CheckExistenceMM(fileName, filePath)
% variable to keep track of if one of the files exists already or not. 
existence = false;

% for loop checks each polarizer
for pFilter = 1:16
   switch pFilter
       case 1
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '4560');
       case 2
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '4530');
       case 3
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '4500');
       case 4
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '4545');
       case 5
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '0045');
       case 6
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '0000');
       case 7
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '0030');
       case 8
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '0060');
       case 9
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '3060');
       case 10
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '3030');
       case 11
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '3000');
       case 12
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '3045');
       case 13
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '6045');
       case 14
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '6000');
       case 15
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '6030');
       case 16
           % checks if either the bmp or nd2 files exists
           existence = ElementExist(fileName, filePath, '6060');
   end
   
   if existence
       % pop-up that requests a new name
       newName = inputdlg('There is already a file in that folder by that name, what would you like to rename these files?');
       newName = newName{1}; % convert 'cell' type to string
       
       % naming information
       disp('repeated name:')
       disp(fileName)
       disp('location of file:')
       disp(filePath)
       disp('new name is:')
       disp(newName)
       disp('----')
       
       % checks the new name
       returnName = CheckExistenceMM(newName, filePath);
       return
   end
end
% returns the name if no file exists
returnName = fileName;

function existence = ElementExist(fileName, filePath, polDeg)
% variables for aligned and non-aligned  files
namePath = strcat(filePath, '\', fileName, polDeg);
namePathAlign = strcat(filePath, '\', fileName, '_', polDeg);

% checks the existence of both bmp and nd2 files for both aligned and non-aligned
existence = exist(strcat(namePath,'.bmp'),'file')|exist(strcat(namePath,'.nd2'),'file')|exist(strcat(namePathAlign, '.nd2'), 'file');


function FileName_Callback(hObject, eventdata, handles)
fileName = get(hObject, 'string'); 
% disables SaveImage and RunCapture if FileName is empty
 if isempty(fileName)
    set(handles.RunCapture, 'enable', 'off');
    set(handles.saveImage, 'enable', 'off');
 else 
    set(handles.RunCapture, 'enable', 'on');
    set(handles.saveImage, 'enable', 'on');
 end
% hObject    handle to FileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileName as text
%        str2double(get(hObject,'String')) returns contents of FileName as a double


% --- Executes during object creation, after setting all properties.
function FileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PathEdit_Callback(hObject, eventdata, handles)
% disables SaveImage and RunCapture if PathEdit is empty
 filePath = get(hObject, 'string'); 
 if isempty(filePath)
    set(handles.RunCapture, 'enable', 'off');
    set(handles.saveImage, 'enable', 'off');
 else 
    set(handles.RunCapture, 'enable', 'on');
    set(handles.saveImage, 'enable', 'on');
 end
% hObject    handle to PathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PathEdit as text
%        str2double(get(hObject,'String')) returns contents of PathEdit as a double


% --- Executes during object creation, after setting all properties.
function PathEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ManualAdjust.
function ManualAdjust_Callback(hObject, eventdata, handles)
%Runs Franky's manual calibration function, needs Arduino
motorInterfaceMicroscope()

% hObject    handle to ManualAdjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in autoAdjust.
function autoAdjust_Callback(hObject, eventdata, handles)
%Runs Franky's auto calibration function, needs Arduino
calibrateMotors(1);
calibrateMotors(2);


set(handles.change60To45,'enable','on');
set(handles.change45To60, 'enable', 'off');
debugSound = 1;
if debugSound==0
    beep
elseif debugSound==1
    load gong.mat;
    sound(y);
elseif debugSound==2
    load handel.mat; 
    sound(y);
end
% hObject    handle to autoAdjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over RunCapture.
function RunCapture_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to RunCapture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in takeImage.
function takeImage_Callback(hObject, eventdata, handles)
robot = java.awt.Robot;

% Switches priority to NIS Elements
tapkey('F14')
robot.waitForIdle ()

% takes image
TakePicture('null', 'null', false, true)

% Finish program sound, suggested: 0 for regular uses
% You might choice to use 1 for debugging, as the beep is the same 
% sound as the noise made when there is an error. Use 1 at ~10 volume
debugSound = 0;
if debugSound==0
    beep
elseif debugSound==1
    load gong.mat;
    sound(y);
elseif debugSound==2
    load handel.mat; 
    sound(y);
end
disp('====')
% hObject    handle to takeImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveImage.
function saveImage_Callback(hObject, eventdata, handles)
robot = java.awt.Robot;

% makes a variable from the input
fileName = str2mat(get(handles.FileName,'String'));
filePath = get(handles.PathEdit,'String');
clipboard('copy', fileName)

% set default folder to C:\Image dropoff
if strcmp(filePath, 'Default')
    filePath = 'C:\Image dropoff';
end 

% Switches priority to NIS Elements
tapkey('F14')
robot.waitForIdle ()
robot.delay(100);

% checks if any files exist already
fileName = str2mat(CheckExistenceImage(fileName, filePath));
robot.delay(10);

% displays information for the user
X = [filePath,' - Folder'];
disp(X)
disp(fileName)

pFilter = 0;
% sends information to a function to take the picture
TakePicture(fileName, filePath, true, true)
tapkey('sub')
beep
disp('====')

% makes this program priority
tapkey('F16')
% hObject    handle to saveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function returnName = CheckExistenceImage(fileName, filePath)
% determines if the file already exists, bmp or nd2
existence = exist(strcat(filePath, '\', fileName,'.bmp'),'file')|exist(strcat(filePath, '\', fileName,'.nd2'),'file');

if existence
       % pop-up that requests a new name
       newName = inputdlg('There is already a file in that folder by that name, what would you like to rename these files?');
       newName = newName{1}; % convert 'cell' type to string
       
       % naming information
       disp('repeated name:')
       disp(fileName)
       disp('location of file:')
       disp(filePath)
       disp('new name is:')
       disp(newName)
       disp('----')
       
       % checks the new name
       returnName = CheckExistenceImage(newName, filePath);
       return
 end
 
 returnName = fileName;


% --- Executes on button press in change45To60.
function change45To60_Callback(hObject, eventdata, handles)
% hObject    handle to change45To60 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotateMotors(2,45,0);
rotateMotors(2,30,1);
rotateMotors(2,30,2);
set(handles.change60To45,'enable','on');
set(handles.change45To60, 'enable', 'off');
debugSound = 1;
if debugSound==0
    beep
elseif debugSound==1
    load gong.mat;
    sound(y);
elseif debugSound==2
    load handel.mat; 
    sound(y);
end


% --- Executes on button press in change60To45.
function change60To45_Callback(hObject, eventdata, handles)
% hObject    handle to change60To45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotateMotors(2,-30,2);
rotateMotors(2,-30,1);
rotateMotors(2,-45,0);
set(handles.change45To60,'enable','on');
set(handles.change60To45, 'enable', 'off');
debugSound = 1;
if debugSound==0
    beep
elseif debugSound==1
    load gong.mat;
    sound(y);
elseif debugSound==2
    load handel.mat; 
    sound(y);
end
