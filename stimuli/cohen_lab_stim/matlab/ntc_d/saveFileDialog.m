function saveFileDialog

% function saveFileDialog
%
%   Opens a graphical 'Save' dialog box with preset defaults for the output filename and path, 
%   which the user can modify as desired before actually saving the file.  After that, the 
%   procedure is basically the same as in saveAttributes:  Saves to disk the 'attributes' 
%   (completed measurements, unit labels, comments, etc.) of the currently-loaded tuning curve(s).   
%   For more info, type 'help saveAttributes'.

%   Revised 2/99 by pj, from earlier versions of saveAttributes by ben & kilgard. 

global allAttributes allComments

INCLUDE_DEFS;

hSaveButton = findobj('tag', 'SaveButton'); 
hMessageText = findobj('tag','MessageText');

column_labels = mkColHeaders;
rowLabels = transpose(column_labels);

% Collect info from various objects 
infileName = get(findobj('tag','InfileText'),'string');
infileStem = infileName(1:end-4);
infileExt = infileName(end-3:end);
inPath = get(findobj('tag','InfileDirectoryText'),'string');
defaultOutpath = get(findobj('tag','OutdirectoryText'),'string');
outfileName = get(findobj('tag','OutfileText'),'string');
defaultOutfileExt = outfileName(end-3:end);

% Set the default prompt for the 'Save as' dialog box
switch defaultOutfileExt
   case {'.txt','.TXT'},  % output measurements from a single data file
      % set the default prompt to be the name of the data file, but with the extension .txt
      defaultPrompt = [infileStem defaultOutfileExt];
   case {'.mat','.MAT'},  % output measurements from (usually) multiple data files
      % set the default prompt to be the name of the most recent output file
      defaultPrompt = outfileName;
   case {'.xls','.XLS'},  % output measurements from multiple data files
      % set the default prompt to be the name of the most recent output file
      defaultPrompt = outfileName;
   otherwise,  % output format is unrecognized; warn the user to change it 
      set(hMessageText,'backgroundcolor',WARNCOLOR);
      set(hMessageText,'string',['** WARNING **  Output filename must end in .mat, .txt, or .xls!']);
      defaultPrompt = outfileName;
end  % switch defaultOutfileExt

% determine the minimum column width for the labels and store it in a string for later 'eval'
labelLengths = 0;
for I = 1:NUMATTRIBUTES
   labelLengths = [labelLengths length(rowLabels{1,I})];
end
labelsWidth = num2str(max(labelLengths));

data = [allAttributes];
if size(data,1) == 0  % no data in the output array
   set(hMessageText,'backgroundcolor',ERRORCOLOR);
   set(hMessageText,'string',['** ERROR **  No data in the output array!  '  .... 
         'Click the ''Append'' button after loading a tuning curve to initialize output.']);
   outPath = 0;  % prevents 'Save as' dialog box from opening, see below
end

% Save the working directory in a string and go to the default output directory
workingDir = pwd;  cd(defaultOutpath);
% Prompt the user for the actual output file name & path
if ~exist('outPath')
   [outFile, outPath] = uiputfile(defaultPrompt, 'Save measurements as');
end

if outPath ~= 0  % i.e., user did not cancel the 'Save as' dialog
   saveFile = fullfile(outPath,outFile);
   saveFileExt = outFile(end-3:end);
   set(findobj('tag','OutdirectoryText'),'string',outPath);
   
   if exist(saveFile) == 2,
      switch saveFileExt
         case {'.mat','.MAT'},
            eval(['load ' saveFile]);
            if ~exist('comments')
               comments = cellstr(zeros(size(data,1),1));
            end
            data = [data; allAttributes];
            comments = [comments; allComments];
            saveAction = 'appended';
         case {'.xls','.XLS'},
            data = readTextData(saveFile);
            data = [data; allAttributes];
            saveAction = 'appended';
         case {'.txt','.TXT'},
            % default format for single tuning curve, don't bother to read in old data
            data = [allAttributes];
            comments = [allComments];
      end  % switch saveFileExt
   else  % it's a new output file
      data = [allAttributes];
      comments = [allComments];
      saveAction = 'saved';
   end  % if exist(saveFile)
   
   switch saveFileExt
      case {'.mat','.MAT'},
         eval(['save ' saveFile ' column_labels data comments;']);
         set(hMessageText,'backgroundcolor',MESSAGECOLOR);
         set(hMessageText,'string',['Attributes ' saveAction ' to file <' saveFile '>']);
         set(findobj('tag','OutfileText'),'string',outFile);
         
      case {'.txt','.TXT'},
         fileID = fopen(saveFile,'w'); 
         latestData = size(data,1);
         for I = 1:NUMATTRIBUTES
            eval(['fprintf(fileID, ''%' labelsWidth 's\t %12.6f\n'', rowLabels{I}, data(latestData,I));']);
         end
         commentString = ['Comments:	' comments{latestData}];
         commentStringWidth = num2str(length(commentString));
         eval(['fprintf(fileID,''%' commentStringWidth 's\r'', commentString);']);
         fclose(fileID);
         set(hMessageText,'backgroundcolor',MESSAGECOLOR);
         set(hMessageText,'string',['Attributes saved to file <' saveFile '>']);
         set(findobj('tag','OutfileText'),'string',outFile);
         
      case {'.xls','.XLS'},
         fileID = fopen(saveFile,'w'); 
         for I = 1:NUMATTRIBUTES
            formatString = '%12.6f\n'; columnString = '%12.6f\t ';
            if size(data(:,I),1) > 1  % more than one column of data
               for J = 1:size(data(:,I),1)-1
                  formatString = [columnString formatString];
               end  % for J
            end  % if size
            eval(['fprintf(fileID, ''%' labelsWidth 's\t ' formatString ''', rowLabels{I}, data(:,I));']);
         end  % for I
         fclose(fileID);
         set(hMessageText,'backgroundcolor',MESSAGECOLOR);
         set(hMessageText,'string',['Attributes ' saveAction ' to file <' saveFile '>']);
         set(findobj('tag','OutfileText'),'string',outFile);
         
      otherwise,  % in the dialog box, user changed the filetype extension to an unsupported format
         set(hMessageText,'backgroundcolor',ERRORCOLOR);
         set(hMessageText,'string',['** ERROR **  Output filename must end in .mat, .txt, or .xls!']);
         
   end  % switch saveFileExt
   
end  % if outPath

cd(workingDir);
set(hSaveButton,'BackgroundColor',NORMBUTTONCOLOR);

return


