function [Tx,Ty] = Erik_PhaseCorrelationFunction(img1,img2,k,ImageNames,smoothing,showImages)
%--------------------------------------------------------------------------
%This function takes in two images and finds the shift between them using
%phase correlation. Refer to http://en.wikipedia.org/wiki/Phase_correlation
%for a brief description. 
%Note: The coordinates in matlab of a picture are (0,0) at the top left of
%an image.
%
% Edited by Erik Mason (erikmason04@gmail.com) to simplify the code, and
% include an option for image smoothing.
%--------------------------------------------------------------------------

m = 15;         % size of median filter (normally 15)
if smoothing, img1 = medfilt2(img1,[m m]); end   % median filter the first (reference) image
if smoothing, img2 = medfilt2(img2,[m m]); end   % median filter the second (shifting) image

%% Crop images and apply Hamming window
[rows, columns, ~] = size(img1);

%If the image is an RGB we just take the first channel
img1 = im2double(img1(:,:,1));
img2 = im2double(img2(:,:,1));

%If we want to crop the image we can do so here
cropWidth = columns;
cropHeight = rows;
x1 = columns/2 - cropWidth/2;
y1 = rows/2 - cropHeight/2;

if(cropWidth ~= columns && cropHeight ~= rows)
    img1 = imcrop(img1,[x1 y1 cropWidth cropHeight]);
    img2 = imcrop(img2,[x1 y1 cropWidth cropHeight]);
end

%Apply hamming window to pad edges on vertical
for i=1:rows
    img1(i,:) = transpose(img1(i,:)).*sqrt(hamming(columns));
    img2(i,:) = transpose(img2(i,:)).*sqrt(hamming(columns));
end

%Apply hamming window to pad edges on horizontal
for i=1:columns
    img1(:,i) = img1(:,i).*sqrt(hamming(rows));
    img2(:,i) = img2(:,i).*sqrt(hamming(rows));
end

%% Take Fourier Transforms and calculate phase correlation image
%Fourier Transform of image 1
FFT1 = fft2(im2double(img1));

%Fourier Transform of image 2
FFT2 = conj(fft2(im2double(img2)));

%The convolution of the fourier images
FFTR = FFT1.*FFT2;

%Find the magnitude the image
magFFTR = abs(FFTR);

%Normalize the image by the magnitude
FFTRN = FFTR./magFFTR;

%The resulting phase correlation image
result = ifft2(im2double(FFTRN));

%% ERIK EDIT - find the peak location in the phase correlation image to find the required shift
% (replaced Ian's code from here down)

% get rid of intensity pixel at the center of the phase correlation image
result(1,1) = 0;            

% shift quadrants so zero-frequency components are in the center (avoids peak being chopped up around the edges)
result = fftshift(result);

% smooth the phase correlation image, if smoothing is selected (normal median filter size is 5x5)
if smoothing, result = medfilt2(result, [5 5]); end

% find peak (brightest pixel) location
[~,index] = max(result(:));

% convert peak location index to [row, column] coordinates
[yPeakLoc,xPeakLoc] = ind2sub(size(result),index);

% find shift in pixels from center of the image
Tx = xPeakLoc - ( columns/2 + 1);
Ty = yPeakLoc - ( rows/2 + 1);

% subpixel registration by finding center of mass (COM) of the peak in the result image
COMsize = 3;                 % window size to find COM - pixels out from center
[x,y] = meshgrid(-COMsize:COMsize, -COMsize:COMsize);   % return x and  y pixel coordinates of pixels in cropped window
COMcrop = result(yPeakLoc-COMsize:yPeakLoc+COMsize, xPeakLoc-COMsize:xPeakLoc+COMsize); % crop out the window from the result image, with the center of the window at the peak location
M = sum(COMcrop(:));            % find the sum of the pixel values in the cropped window
COMx = sum(sum(COMcrop.*x))/M;  % calculate the x component of the COM
COMy = sum(sum(COMcrop.*y))/M;  % calculate the y component of the COM
Tx = Tx + COMx;                 % add the subpixel shift in x and y
Ty = Ty + COMy;

% display the phase correlation image with the peak marked
if showImages
    figure, imshow(result, []), title(num2str(ImageNames{k})) %(360:660,490:790),(460:560,590:690)
    hold on, plot(xPeakLoc,yPeakLoc,'r*'), drawnow(), hold off
end

% display the MM locations and required shift in x and y
% disp(ImageNames{k})
% disp([Tx,Ty])

end