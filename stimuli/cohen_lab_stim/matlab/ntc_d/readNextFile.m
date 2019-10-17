function readNextFile

% function readNextFile
%
%   Finds the 'next' data file (in dictionary order of filenames) within the current data directory,
%   and calls 'readAndDisplayFile' to read it.  N.B.:  For this function to work correctly, there
%   should be a data file already loaded, or at minimum a valid file extension ('.mat' or '.dtc') 
%   in the 'infileText' textbox.

%   Revised 2/99 by pj from earlier versions by ben.

INCLUDE_DEFS;

hInfileText = findobj('tag','InfileText');
inName = get(hInfileText,'string');
inExt = inName(end-3:end);  % The last 4 characters should be .mat or .dtc

% Save the name of the working directory in a string; go to the current data directory
dataDir = get(findobj('tag','InfileDirectoryText'),'string');
workingDir = pwd;  cd(dataDir);
fileStruct = dir(['*' inExt]);  % Presumably the 'next' file is of the same type as the current file
cd(workingDir);  % Return to the working directory

% Strange to relate:  The MatLab 'dir' command DISPLAYS a file listing in dictionary order of the
% filenames, but RETURNS a file listing (i.e., to a variable) in order of the file creation dates.
% Thank you, MatLab.
% Thus we perform ridiculous gymnastics to sort the returned filenames in dictionary order...
namesArray = '';
for I = 1:length(fileStruct)
   nextName = getfield(fileStruct(I),'name');
   namesArray = [namesArray; nextName];
end
nameCells = cellstr(namesArray);
sortedCells = sort(nameCells);
sortedNames = char(sortedCells);


foundit = 'F';  nosuch = 'F';  index = 1;

while foundit ~= 'T'
   if inName == sortedNames(index,:) % filenames match
      foundit = 'T';
      if index < length(fileStruct)
         nextInName = sortedNames(index + 1,:);
      else % there are no more entries in the file list
         nosuch = 'T';
      end
   else
      index = index + 1;
   end
end  % while

if nosuch == 'T'
   hmessagetext = findobj(gcf,'tag','MessageText');
   set(hmessagetext, 'backgroundcolor', ERRORCOLOR);
   set(hmessagetext, 'string', ['** ERROR **  No logical ''next'' file found.']);
else
   set(hInfileText, 'string', nextInName);
   readAndDisplayFile;
end


return
