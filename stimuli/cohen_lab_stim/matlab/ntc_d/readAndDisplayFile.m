function readAndDisplayFile;

% function readAndDisplayFile
%
%   Checks the infileText and infileDirectoryText boxes to select which data file to import.  
%   Reads in the new data file, initializes the attributes vector, and displays the new data.

%   Revised 2/99 by pj, from earlier versions by ben and kilgard.

global latencies fMin nOctaves extAtten newAttributes selectedStimRange 
global ntcPrefs selectedHistos selectedLatency selectedRateInfo NAMPS NFREQS 
global selectedSpontRange

INCLUDE_DEFS;

hAttenC = findobj('tag','AttenCEdit');
hAttenI = findobj('tag','AttenIEdit');
hdepth = findobj('tag', 'DepthEdit');
hUnit = findobj('tag','UnitEdit');
hmessagetext = findobj('tag','MessageText');
hCE = findobj('tag','TCCommentEdit');

infileDirectory = get(findobj('tag','InfileDirectoryText'),'string');
filename = get(findobj('tag','InfileText'),'string');
fullname = fullfile(infileDirectory, filename);
hAB = findobj('tag','AppendButton');

infile = fopen(fullname,'r');
if (infile) == -1,
    hmessagetext = findobj(gcf,'tag','MessageText');
    set(hmessagetext, 'backgroundcolor', ERRORCOLOR);
    set(hmessagetext, 'string', ['file not found: <' fullname '>']);
  else
    fclose(infile);
    fileExt = fullname(end-3:end);
    switch fileExt
      case {'.mat','.MAT'}, 
        if filename(1:3)=='tc_' | filename(1:3)=='TC_',
            loadBWmatfile(fullname);
          else
    	      load(fullname);
            NAMPS=15;
            NFREQS=45;
    	      if ~isempty(header),
                header1 = deblank(header(1:40));
                header2 = header(41:end-1);
	              [unitNum,depth,extAttenC,extAttenI] = decode_header(header1);
    	        else
    	        	disp('missing header in file');   %%% replace this line with better
    	        end
    	      set(hAB,'backgroundcolor',WARNCOLOR);
          end % (if)
      case {'.dtc','.DTC'},
        [latencies, header, fMin, nOctaves] = ncondtc2(fullname);
        header1 = deblank(header(1:(end-29)));
        header2 = header((end-28):(end-1));
	[unitNum, depth, extAttenC, extAttenI] = decode_header(header1);
        set(hAB,'backgroundcolor',WARNCOLOR);
      otherwise,
        hmessagetext = findobj(gcf,'tag','MessageText');
        set(hmessagetext, 'backgroundcolor', ERRORCOLOR);
        set(hmessagetext, 'string', ['unknown file type:  <' fullname '>']);      
      end % (switch)
      
    % now display stuff in the window    
    if ~any(~finite([extAttenC extAttenI depth unitNum])),
        set(hmessagetext,'backgroundcolor',MESSAGECOLOR);
        set(hmessagetext,'string', [header1 ' ' header2]);
      else
        set(hmessagetext,'string',...
          ['***WARNING*** Missing header info:  <' ...
               header1 ' ' header2 '>']); 
        set(hmessagetext,'backgroundcolor', WARNCOLOR);
      end % (if)

    if ~finite(depth),
        set(hdepth,'backgroundcolor',WARNCOLOR);
      else
        set(hdepth,'backgroundcolor',NORMCOLOR);
      end % (if)
    set(hdepth, 'string', num2str(depth));

    if ~finite(unitNum),
        set(hUnit,'backgroundcolor',WARNCOLOR);
        strUnit = num2str(unitNum);
      else
        set(hUnit,'backgroundcolor',NORMCOLOR);
        unitNumInt = floor(unitNum);
        strUnit = num2str(unitNumInt);
        if unitNumInt ~= unitNum,
            strUnit = [strUnit, ...
                       char(round((unitNum-unitNumInt)*100+double('A')-1))];  
          end % (if)  
      end % (if)
    set(hUnit,'string',strUnit);
  
    if ~finite(extAttenI),
        extAttenI = 99;
        set(hAttenI,'backgroundcolor',WARNCOLOR);
      else
        set(hAttenI,'backgroundcolor',NORMCOLOR);
      end % (if)
    extAtten = extAttenI;
    set(hAttenI, 'string', num2str(extAttenI));
    
    if ~finite(extAttenC),
        extAttenC = 99;
        set(hAttenC,'backgroundcolor',WARNCOLOR);
      else
        set(hAttenC,'backgroundcolor',NORMCOLOR);
        extAtten = extAttenC;
      end % (if)
    set(hAttenC, 'string', num2str(extAttenC));

    set(hCE, 'string', noCommentString);

    % clear attributes from previous file
    newAttributes = zeros(1,NUMATTRIBUTES);
    allAttributes = [];
    newAttributes(FILENAME) = getFileIndex(filename);
    dirInfo = dir(fullname);
    newAttributes(FILEDATE) = datenum(dirInfo.date);
    extAtten = extAttenC;
    selectedHistos = zeros(1,4);
    selectedRateInfo = zeros(1,7);
    selectedLatency = 0;
    
    [dispFreqs, dispAmps] = makeQuiverAxes(fMin, nOctaves, extAtten);
    selectedStimRange = [dispFreqs([1 end]) dispAmps([1 end])];
    selectedSpontRange = [dispFreqs([1 end]) dispAmps([1 1])];
    if strcmp(ntcPrefs(PREFVALUE).applyOnLoad, 'yes'),
        applyPrefs;
      end % (if)
      
    refreshDisplay;
    
  end % (if)
  
return

    
%%%-----------------

function [unitNum, depth, extAttenC, extAttenI] = decode_header(header)
 
global newAttributes

INCLUDE_DEFS;
 
% try to get attenuator settings from header and set correct amplitudes

header = upper(header);	  % just use first part to skip date, etc.

unitNum = NaN;
depth = NaN;
extAttenC = NaN;
extAttenI = NaN;

% first try to dig out the unit (penetration) identifier (e.g., 21 or 21B)
% assume the first token in the header is either like '21' or 'U21'

[token1, remd] = strtok(header);
if (token1(1) == 'U'),
    token1=token1(2:end);
  end
unitModChar = '';
if isletter(token1(end)),
    unitModChar = token1(end);
    token1 = token1(1:(end-1));
  end  
if all(token1-'0'>=0 & token1-'0'<=9) & ~isempty(str2num(token1)),
    unitNum = str2num(token1);
    if ~isempty(unitModChar),
        unitNum = unitNum + (unitModChar-'A' + 1)/100;
      end
  end;

% now try and dig out the penetration depth info
% assume this is recorded as a number followed by U, M, or UM (e.g., 1280UM),
% and that it's the next occurence of one of these letters that counts
% it is not an error if this info is not in the header

remd = remd(end:-1:1);
depthLocat = max([findstr(remd,'U') findstr(remd, 'M')]);
if ~isempty(depthLocat),
    token1 = strtok(remd((1+depthLocat):end));
    if ~isempty(token1),
        depth = str2num(token1(end:-1:1));
      end % (if)
    if isempty(depth),
        depth = NaN;
      end
  end

% finally, try and dig out attenuator settings from the header
% attenuator setting can be recorded as
%   nnDB
%   nn/nnDB
%   -nn/-nnDB
%   -nn/--DB
%   nnC/nnI 
%   nn/nn
%   etc...
% in general, it's quite a mess.  this should handle the above examples and 
%   variants of them
% 
slashPos = min(find(header == '/'));  % assume there's at most one '/' here
dbPos = min(findstr(header,'DB'));    % assume there's at most one 'DB' here
if ~isempty(slashPos),
    tHeader = header(~(header == 'D') & ~(header == 'B'));
    slashPos = find(tHeader == '/');
    token2 = strtok(tHeader((slashPos+1):min(end, slashPos+3)));  % first token after slash
    token1 = strtok(tHeader((slashPos-1):-1:max(1,slashPos-3)));
    token1 = token1(end:-1:1);                   % token ending 1 before slash
    token1 = strrep(token1,'--','99');
    token2 = strrep(token2,'--','99');
    token1 = strrep(token1,'-',' ');
    token2 = strrep(token2,'-',' ');
    findc1 = (token1 == 'C');  token1 = token1(~findc1);
    findc2 = (token2 == 'C');  token2 = token2(~findc2);
    findi1 = (token1 == 'I');  token1 = token1(~findi1);
    findi2 = (token2 == 'I');  token2 = token2(~findi2);
    % tokens 1 & 2 should just be numbers or empty at this point
    % default order is C/I, so look for an I in the first token or a C in the
    %   second to switch from default order
    if any(findi1) | any(findc2),
        extAttenC = str2num(token2);
        extAttenI = str2num(token1);
      else
        extAttenC = str2num(token1);
        extAttenI = str2num(token2);
      end
    if isempty(extAttenC),
        extAttenC = NaN;
      end;
    if isempty(extAttenI),
        extAttenI = NaN;
      end;
  elseif ~isempty(dbPos),
    tHeader = header(~(header == 'D') & ~(header == 'B'));
    token1 = strtok(tHeader((dbPos-1):-1:1));
    token1 = token1(end:-1:1);                   % token ending 1 before 'DB'
    token1 = strrep(token1,'-',' ');
    extAttenC = str2num(token1);
    if isempty(extAttenC),
        extAttenC = NaN;
      end;
    extAttenI = NaN;
  end;

return


%%%------------------------

function fileIndex = getFileIndex(filename)

w = findstr(filename,'.');
% convert the last five characters of filename into a reasonable number as an index
if size(filename,2) >= 9
    startConversion = w - 5;
else
    startConversion = 1;
end
fileIndex = filename(startConversion:w-1);
endConversion = size(fileIndex,2);

% if next-to-last character is 'c' as in 'channel', convert it to a decimal point
if fileIndex(endConversion - 1) == 'c' | fileIndex(endConversion-1) == 'C'
   fileIndex(endConversion - 1) = '.';
end

% if last character is a letter, convert it to the corresponding number of the alphabet	
if isempty(str2num(fileIndex(endConversion)))  % i.e. if it's a letter
   let2num = real(upper(fileIndex(endConversion))) - 64;  % converts A,a to 1 etc.
   if let2num < 10 % letter converted is a single digit, so convert it
      fileIndex(endConversion) = num2str(let2num);
   else % all other letters converted to zeros
      fileIndex(endConversion) = '0';
   end
end  % if isempty

% convert all other letters to zeros
for k = 1:(endConversion - 1)
   if isempty(str2num(fileIndex(k)))  &  (fileIndex(k) ~= '.')
      % i.e., convert letters but not decimal points
      fileIndex(k) = '0';
   end  % if
end  % for k

fileIndex = str2num(fileIndex);

return

%%%----------------------
function loadBWmatfile(fullname)
% function loadBWmatfile(fullname)

global latencies fMin nOctaves extAtten NFREQS NAMPS

INCLUDE_DEFS;

latencies = [];

hmsg=findobj('tag','MessageText');
set(hmsg,'string','Be patient -- this takes a long time');
set(hmsg,'backgroundcolor', MESSAGECOLOR);

load(fullname,'duration');
for timeVal=1:(duration-1),
  sliceName = ['t' num2str(timeVal)];
  load(fullname, sliceName);
  eval(['newSlice=' sliceName '; clear ' sliceName]);
  [ampInd, freqInd, dummy] = find(newSlice);
  numSpikes = length(ampInd);
  latencies = [latencies; [timeVal*ones(numSpikes,1) freqInd ampInd]];
  end % (for)
  
load(fullname,'frequency');
NFREQS = length(frequency);
fMin = frequency(1);
fMax = frequency(NFREQS);
nOctaves = log2(fMax/fMin);

load(fullname,'amps');
NAMPS = length(amps);
tAmps = makeAmps;
extAtten = tAmps(end) + 30 - amps(end);

set(hmsg,'string','See, I told you it takes a long time');
set(hmsg,'backgroundcolor', NORMCOLOR);

return


%%%-----------------

set(hAttenC,'string',num2str(extAttenC));
set(hAttenI,'string',num2str(extAttenI));
if (extAttenC == 99 & extAttenI == 99),
    set(hAttenC,'backgroundcolor',WARNCOLOR);
    set(hAttenI,'backgroundcolor',WARNCOLOR);   
  else
    set(hAttenC,'backgroundcolor',NORMCOLOR);
    set(hAttenI,'backgroundcolor',NORMCOLOR);   
  end
