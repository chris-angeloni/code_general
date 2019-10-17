function modPrefs()

global ntcPrefs

INCLUDE_DEFS;
                  
prompts = struct2cell(ntcPrefs(PREFPROMPT));
values = struct2cell(ntcPrefs(PREFVALUE));
v1 = values(1:4);
p1 = prompts(1:4);
v2 = values(5:11);
p2 = prompts(5:11);
v3 = values(12:end);
p3 = prompts(12:end);
  
v1 = inputdlg(p1, 'Modify Directory/File Preferences', 1, v1);
v2 = inputdlg(p2, 'Modify Display Preferences', 1, v2);
v3 = inputdlg(p3, 'Modify Display Preferences', 1, v3);

if ~isempty(v1) | ~isempty(v2) | ~isempty(v3),
    if isempty(v1),
        v1=values(1:4);
      end
    if isempty(v2),
        v2=values(5:11);
      end
    if isempty(v3),
        v3=values(12:end);
      end
    ntcPrefs(PREFVALUE) = cell2struct([v1;v2;v3], fieldnames(ntcPrefs), 1);
    applyPrefs;

    hRB = findobj('tag','RefreshButton');
    set(hRB, 'backgroundcolor', WARNCOLOR);
    end

return
