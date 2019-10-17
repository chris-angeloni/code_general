function savePrefs()
% function savePrefs()

global ntcPrefs

[prefFile, prefPath] = uiputfile('ntcprefs.mat', 'Save preferences as');
prefFull = fullfile(prefPath,prefFile);
save(prefFull, 'ntcPrefs');

return
