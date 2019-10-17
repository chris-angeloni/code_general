function loadPrefs()
%function loadPrefs()

global ntcPrefs

[prefFile, prefPath] = ...
    uigetfile('*.mat', 'Load preferences');
    
prefFull = fullfile(prefPath, prefFile);

prefContents = who('-file', prefFull, 'ntcPrefs');
if isempty(prefContents),
    errordlg(['ntcPrefs not found in file <' prefFull '>']);
  else
    load(prefFull,'ntcPrefs');
    applyPrefs;
  end;

return
