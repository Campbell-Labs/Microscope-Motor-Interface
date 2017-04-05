function Erik_Alignment_PhaseCorrelation_Auto(filename,directory)
% Aligns (registers) 16 Meuler Matrix images together using a phase 
% correlation method.
% Edited version of Ian's code, with some improvements.
%
% This code will read images from the same folder that it is in. You also
% need "Erik_PhaseCorrelationFunction.m" in the folder as well. The images
% should be converted to 8-bit images using "PreRegistrationConfig.m" 
% before aligning. A new folder will be created that contains the 
% registered images, and a video of the registered images.
%
% Erik Mason, winter 2017 research project student
% Email questions to: erikmason04@gmail.com

%---------------------------SET INPUTS-------------------------------------

% image file name extension ('.tif' or '.bmp')
ext = '.bmp';

% Reference Image specified using its Muelleur Matrix (MM) location. 0045 is usually used
refImage_MM_location= '0045';

% Filename
%filename = 'location4_spot4_';          % filename that the registered images will be saved as. 'Reg' will be automatically included to indicate that they have been registered. 
filenamePrefix = filename;              % everything in the image name before MM locations. Do not include MM location
filenameSuffix = '';                    % everything in the image name after the MM locations

% Include median filter to smooth images. Set to 1 to filter, 0 to not filter
smoothing = 0;

% Display the phase correlation images (with the peak marked). Set to 1 to display, 0 to not display. Useful for testing.
showImages = 0;

%---------------------------User Input Ends -------------------------------

currentDirectory = directory;

index = {'0000','0030','0045','0060','3000','3030','3045','3060',...
         '4500','4530','4545','4560','6000','6030','6045','6060'};

%Number of Images
numberOfImages = size(index,2);

%find the index number at which the reference image is in the cell
b = strfind(index,refImage_MM_location);
referenceNumber = find(~cellfun(@isempty,b));    

%Create folder for registered images
folderName = [filename,'_Registered'];
regName = [directory,'\',folderName];
mkdir(regName);

%Create Filename vector
filenames = cell(numberOfImages,1);
for i=1:numberOfImages
   filenames(i) = cellstr(strcat(filenamePrefix,index(i),filenameSuffix,ext));
end

%Create Video
outputVideo = VideoWriter(fullfile(regName,['reg_',filename,'.avi']));
outputVideo.FrameRate = 2;
open(outputVideo)

%Read in reference frame specified by user and finds the height(row) and width(column)
referenceFrame =imread([directory,'\',filenames{referenceNumber}]);
[height, width] = size(referenceFrame);

%Normalizes refImage
referenceFrameNorm = mat2gray(referenceFrame); 
[pathstr,name,ext] = fileparts(filenames{referenceNumber});
referenceFrameFilename = [currentDirectory,'/',folderName,'/','reg_',filename,index{referenceNumber},ext];

%vectors of size 16 for x and y shift values
x_shift = zeros(16,1);
y_shift = zeros(16,1);

%Loop over all the images to find the phase correlation
for k=1:numberOfImages
    
    if k ~= referenceNumber
       
        %normalizes images after reading them
        normImages = mat2gray(imread([directory,'\',filenames{k}]));        
        
        %Get the shift relative to normalized reference frame
        [Tx,Ty] = Erik_PhaseCorrelationFunction_Auto(referenceFrameNorm,normImages,k,index,smoothing,showImages);        
        
        %Change value at index from 0 to the respective shift 
        x_shift(k) = Tx; 
        y_shift(k) = Ty;
        
    end 
end

%Max shifts in x and y (minimum crop values)
max_x_shift = max(abs(x_shift));
max_y_shift = max(abs(y_shift));

%Mimimum crop width and height 
croppedWidth = width -(2 * max_x_shift);
croppedHeight = height -(2 * max_y_shift);

%Loop over all the images to translate and crop
for n=1:numberOfImages
    
    if n ~= referenceNumber
        
        %reads the images
        nextFrame = imread([directory,'\',filenames{n}]);
          
        %Translate the frame
        %Use negative of the shifted values to move the image towards the reference image        
        T = maketform('affine',[1,0,0; 0,1,0; x_shift(n),y_shift(n),1]);
        translatedImage = imtransform(nextFrame,T,'XData',[1 size(nextFrame,2)],'YData',[1 size(nextFrame,1)]);
       
        %crop the translated image using max shift in x and y
        croppedImage = imcrop(translatedImage,[(max_x_shift + 1) (max_y_shift + 1) croppedWidth croppedHeight]);
        
        %New Image Filename
        nextFrameFilename = [currentDirectory,'/',folderName,'/','reg_',filename,index{n},ext];
    
        %write the translated Image to the new folder
        imwrite(croppedImage,nextFrameFilename);
    
        %Write the image to the video
        writeVideo(outputVideo,croppedImage); 
        
    else
        %Write the reference frame to the folder after cropping it
        croppedRef = imcrop (referenceFrame,[(max_x_shift + 1) (max_y_shift + 1) croppedWidth croppedHeight]);
        imwrite(croppedRef,referenceFrameFilename);
       
        %Write the image to the video
        writeVideo(outputVideo,croppedRef); 
    end        
    
end

close(outputVideo);
disp('Done Aligning!');
end