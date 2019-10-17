function dataByColumns = readTextData(textDataFile)

% function dataByColumns = readTextData(textDataFile)
%
%   Reads ntc data from previously-saved ASCII text files.  The input file must contain one
%   column of attribute labels (discarded) and one or more columns of data.  Returns a double array.
%   N.B.:  The column delimiter between the first and second columns must be the tab character.
%
%   This might be done more elegantly using MatLab's dlmread or csvread functions, but those only
%   support numeric data, which would mean no attribute labels....

%   Written 2/99 by pj.

dataByRows = [];
fileID = fopen(textDataFile,'r');

while 1
   % read the data file, line-by-line
   currentRow = fgetl(fileID);
   if ~isstr(currentRow)  % end-of-file returns a -1 with fgetl
      break
   end  % if
   % convert the string to ASCII codes
   asciiCodes = double(currentRow);

   % find the index of the first tab character 
   I = 1;
   while 1
      currentAsciiCode = asciiCodes(I);
      if currentAsciiCode == 9  % tab character is ASCII code 9
         break
      end  % if
      I = I + 1;
   end  % while
   
   % read all characters after the first tab character into the data array
   currentRowData = str2num(currentRow(I+1:end));

   dataByRows = [dataByRows; currentRowData];
end  % while
   
dataByColumns = transpose(dataByRows);
fclose(fileID);

return


