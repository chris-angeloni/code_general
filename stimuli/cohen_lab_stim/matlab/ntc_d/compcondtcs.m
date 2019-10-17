function allFileDiffs = compcondtcs(dirspec, filespec)
%function allFileDiffs = compcondtcs(dirspec, filespec)
%
%compare dtc file latencies read with the old (ncondtc) and new (ncondtc2)
%  functions.
%
%dirspec           file directory (in quotes) where the dtc file(s) are found
%                    (default is current directory)
%filespec          dtc file name in that directory (default is '*.dtc')
%allFileDiffs      cell array containing the file name and latency info.
%                  to see the file names, do 'allFileDiffs{:,1}'
%                  to see the file name and data for the 1st file, 
%                     do 'allFileDiffs{1,:}'
%                  (i.e., use curly braces instead of parentheses)
%
%only latencies which do not match using both methods are returned
%
%the latency info is four columns -- 
% column 1        latency read by the old function for a spike (in msec)
%                 NaN means there was no corresponding spike read
%                 -Inf means there was an error reading the file
% column 4        latency read by the new function for that spike (in msec)
%                 NaN means there was no corresponding spike read
%                 -Inf means there was an error reading the file
% columns 2 & 3   stimulus amplitude (1-15) and frequency (1-45) for that spike
%


% determine files to compare
if nargin<2,
    filespec = '*.dtc';
    if nargin<1,
        dirspec = '.';
      end % (if)
  end % (if)

% find which files, and put them in some kind of rational order...
dtclist = dir([dirspec filesep filespec]);
numDTCs = size(dtclist,1);
fileList = {};
for ii=1:numDTCs,
  fileList = [fileList; cellstr(dtclist(ii).name)];
  end % (for)
fileList = sort(fileList);

% if verbose.m is in your path, then you can display the results as you go along
if exist('verbose')==2,
    verboseL = verbose;
    disp(' ');
  else
    verboseL = 0;
  end % (if)

allFileDiffs = cell(0);

% loop through all the files
for ii=1:numDTCs,

  % read the latencies using both methods
  if ismember('*', filespec),
      filename = fullfile(dirspec, char(fileList(ii)));
    else
      filename = char(fileList(ii));
    end % (if)
    
  try,  
      oldLatencies = ncondtc(filename);
    catch,
      warning(['error reading file <' filename '> using old method']);
      oldLatencies = [-Inf 1 1];
    end % (try)
    
  try,  
      newLatencies = ncondtc2(filename);
    catch,
      warning(['error reading file <' filename '> using new method']);
      newLatencies = [-Inf 1 1];
    end % (try)

% reorder columns so sort will be by amplitude, then frequency, then latency
  oldLatencies = oldLatencies(:,[3 2 1]);
  newLatencies = newLatencies(:,[3 2 1]);
   
  % identify which spikes are not found by both methods
  [oldNotNew, iOld] = setdiff(oldLatencies, newLatencies, 'rows');  
  [newNotOld, iNew] = setdiff(newLatencies, oldLatencies, 'rows');
  numOldNotNew = size(oldNotNew,1);
  numNewNotOld = size(newNotOld,1);
  oldUnique = unique(oldNotNew(:,[1 2]), 'rows');
  newUnique = unique(newNotOld(:,[1 2]), 'rows');
  allUnique = unique([oldUnique; newUnique], 'rows');
  numUnique = size(allUnique, 1);
  
  allOdd2 = [];
  for jj=1:numUnique,
    jjInOld = ...
      find(all(oldNotNew(:,[1 2]) == ones(numOldNotNew,1)*allUnique(jj,:),2));
    numInOld = length(jjInOld);
    jjInNew = ...
      find(all(newNotOld(:,[1 2]) == ones(numNewNotOld,1)*allUnique(jj,:),2));
    numInNew = length(jjInNew);
    
    % first deal with spikes that are in both files but have different times
    for kk=1:min(numInOld, numInNew),
      allOdd2 =  [allOdd2; [oldNotNew(jjInOld(kk),[3 1 2]), ...
          newNotOld(jjInNew(kk),3)]];
      end % (for)
    
    % now deal with spikes that are only in the old file, and then spikes
    %   that are only in the old file
    if numInOld>numInNew,
        allOdd2 = [allOdd2; [oldNotNew(jjInOld((numInNew+1):end),[3 1 2]), ...
            NaN*ones(numInOld-numInNew,1)]];
      elseif numInOld<numInNew,
        allOdd2 = [allOdd2; [NaN*ones(numInNew-numInOld,1), ...
           newNotOld(jjInNew((numInOld+1):end),:)]];
      end % (if)
    
    end % (for)
    
  allFileDiffs = [allFileDiffs; {filename, allOdd2}];
  
% if verbose is defined, then you can display the results as you go along
  if verboseL,
      disp(filename);
      dispMat = sprintf('%6.2f    %3d    %3d    %6.2f\n', allOdd2');
      disp(sprintf('  old     ampl   freq     new'));
      dispMat = strrep(dispMat, 'NaN', '   ');
      disp(dispMat);
   end % (if)
   
  end % (for)

return
