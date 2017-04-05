function PreRegistrationConfig_Auto(directory)

% This function reads a directory which contains images with a bit-depth of
% 24 and converts them to 8-bit. The original 24-bit images are renamed to
% have 24-BIT at the end. The 8-bit are reverted to the original names
% along with a dash. The images are also renamed so that the 4 digit Muelleur
% Matrix angle locations are at the end of the names.

files = dir(directory); %returns array of structs

%First take care of bitmaps

for i = 1:size(files)
    if files(i).isdir == 0
        filename = files(i).name;
        
        sizes = size(filename);
        length = sizes(2);
        
        
        if strcmp('.bmp', filename(length-3:length))
            movefile(strcat(directory,'\',filename),strcat(directory,'\',filename(1:length-4), '-24BIT.bmp'));
            img = imread(strcat(directory,'\',filename(1:length-4), '-24BIT.bmp'));
            imgGray = rgb2gray(img);
            imwrite(imgGray, strcat(directory,'\',filename));
            delete([directory,'\',filename(1:length-4), '-24BIT.bmp']); %added delete March 28 2017 since 3 & 24 bit images are different
        end
    end
end

files = dir(directory);

configs = cell(16,1);

configs = {'0000','0030','0045','0060','3000','3030','3045','3060','4500','4530','4545','4560','6000','6030','6045','6060'};

%take care of naming conventions

for i = 1:size(files)
    if files(i).isdir == 0
        filename = files(i).name;
        
        sizes = size(filename);
        length = sizes(2);
               
        dotMatches = strfind(filename,'.');
        lastDotIndex = dotMatches(size(dotMatches));
        extension = filename(lastDotIndex:length);
        filenameMinusExt = filename(1:lastDotIndex-1);
        
        for j = 1:16
            matches = strfind(filename,configs{j});
            
            if size(matches) ~= 0 %match!
                replacedFilename = strrep(filenameMinusExt,configs{j},'');
                newFilename = strcat(replacedFilename, '_', configs{j}, extension);
                newFilename = strrep(newFilename,'--','-');
                newFilename = strrep(newFilename,'__','_');
                
                if strcmp(filename,newFilename) == 0
                    movefile(strcat(directory,'\',filename),strcat(directory,'\',newFilename));
                end
            end
        end
    end
    
end