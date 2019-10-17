function saveAttributes

% function saveAttributes
%
%   Saves to disk the 'attributes' (completed measurements, unit labels, comments, etc.) of the 
%   currently-loaded tuning curve(s).  Checks the outfileText and outfileDirectoryText boxes to
%   determine the output path and filename.  Multiple sets of attributes from multiple tuning
%   curves can be saved in one output file.  N.B.:  THE 'APPEND' BUTTON MUST BE CLICKED AT LEAST 
%   ONCE BEFORE ANY DATA WILL BE PLACED IN THE OUTPUT ARRAY.  Also, if the 'Append' button is
%   clicked more than once with the same tuning curve loaded (e.g. if a parameter is re-measured) 
%   then the output array will contain multiple sets of measurements for this tuning curve.
%
%   Output can be in MatLab (.mat) format or either of two types of ASCII text (.txt or .xls), 
%   selectable by the user at save time:
%   -- A .mat output file will contain a 1x1 cell array of user 'comments'; an Ax1 cell array of 
%    'column_labels', where A = the number of attributes in the output array (defined in INCLUDE_DEFS);
%    and an NxA array of 'data', where N = the number of times that attributes were appended to the
%    output (ideally, this will equal the number of measured data files; see above).
%   -- A .txt output file will contain two tab-separated columns of ASCII text:  Attribute labels and 
%    the corresponding values.  Only the values from the currently-loaded tuning curve are saved.
%   -- A .xls output file will contain multiple tab-separated columns of ASCII text:  One columnn of
%    attribute labels and N columns of corresponding values, with N defined as above for .mat output.
%    Note:  '.xls' is the default filetype extension for Excel for Windows.  Excel and most other
%    modern spreadsheet programs will automatically recognize and import formatted text from such files.
%
%   The .mat output format is best if all subsequent analyses and statistical comparisons will be done
%   using MatLab.  Text output formats allow the use of other programs (e.g. the UNIXstat package,
%   StatGraphics, Excel, etc) as well as MatLab for subsequent analyses.
%
%   To keep the column width reasonable, comments are not saved in .xls (multi-column text) files.  
%   Also note that the MatLab port to Windows is too incompetent to insert DOS newline characters 
%   in text (fprintf) output; however, most modern Windows programs (e.g., StatGraphics, Excel, etc.) 
%   are able to translate UNIX newline characters.

%   Revised 2/99 by pj, from earlier versions by ben & kilgard. 

global allAttributes allComments

INCLUDE_DEFS;

hMessageText = findobj('tag','MessageText');

column_labels = mkColHeaders;
rowLabels = transpose(column_labels);

outPath = get(findobj('tag','OutdirectoryText'),'string');
outFile = get(findobj('tag','OutfileText'),'string');

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
   outPath = 0;  % prevents the 'save' from taking place, see below
end

if outPath ~= 0
   saveFile = fullfile(outPath,outFile);
   saveFileExt = outFile(end-3:end);
   
   if exist(saveFile) == 2,
      switch saveFileExt
         case {'.mat','.MAT'},
            eval(['load ' saveFile]);
            if ~exist('comments')
               comments = cellstr(zeros(size(data,1),1));
            end
            data = [data; allAttributes];
	    [data, uniqInds] = unique(data,'rows');
	    if ~iscell(allComments),
	        allComments={};
	      end % (if)
            comments = [comments; allComments];
	    comments = comments(uniqInds);
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
         
      otherwise,  % user changed the filetype extension to an unsupported format
         set(hMessageText,'backgroundcolor',ERRORCOLOR);
         set(hMessageText,'string',['** ERROR **  Output filename must end in .mat, .txt, or .xls!']);
         
   end  % switch saveFileExt
   
end  % if outPath

return

