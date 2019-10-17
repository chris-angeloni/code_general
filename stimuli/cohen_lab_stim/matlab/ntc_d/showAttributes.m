function showAttributes(colHeaders)

global newAttributes

INCLUDE_DEFS;

[hobj, hfig] = gcbo;

newAttributes(DEPTH) = str2num(get(findobj(hfig,'tag','DepthEdit'),'string'));
newAttributes(ATTENC) = str2num(get(findobj(hfig,'tag','AttenCEdit'),'string'));
newAttributes(ATTENI) = str2num(get(findobj(hfig,'tag','AttenIEdit'),'string'));

unitString =get(findobj(hfig,'tag','UnitEdit'),'string');
if strcmp(unitString,'NaN'),
    newAttributes(UNITNUM) = NaN;
  elseif isletter(unitString(end)),
    unitChar = unitString(end);
    unitString = unitString(1:(end-1));
    newAttributes(UNITNUM) = str2num(unitString)+(unitChar-'A'+1)/100;
  else
    newAttributes(UNITNUM) = str2num(unitString);
  end

nCols = size(colHeaders,1);
hfig = figure('units', 'points','position', [355 20 250 495]);
listString = [num2str(reshape(1:nCols,nCols,1)), ...
              ' '*ones(nCols,2), str2mat(char(colHeaders{:})), ...
              ' '*ones(nCols,2), ' '*ones(nCols,10)];
for ii=1:nCols,
  if newAttributes(ii)==round(newAttributes(ii)),
      listString(ii,(end-9):end) = sprintf('%10d', newAttributes(ii));
    else
      listString(ii,(end-9):end) = sprintf('%10.3f', newAttributes(ii));
    end
  end
  
hlist = uicontrol('style','listbox',...
                  'units','points', ...
                  'fontname','fixed', ...
                  'string', listString, ...
                  'position',[8 5 230 490]);
extentList = get(hlist,'extent');
set(hlist,'position', [8 5 extentList(3)+30 485]);

return
