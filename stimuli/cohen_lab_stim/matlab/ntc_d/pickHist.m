function pickHist

global fMin nOctaves extAtten selectedHistos

INCLUDE_DEFS;

[hobj,hfig] = gcbo;

point1 = get(gca,'CurrentPoint');% button down detected
point1 = point1(1,1:2);          % extract x and y

x = point1(1);

hPk1Pk = findobj(hfig, 'tag', 'Pk1PeakRadio');
hPk1En = findobj(hfig, 'tag', 'Pk1EndRadio');
hPk2St = findobj(hfig, 'tag', 'Pk2StartRadio');
hPk2En = findobj(hfig, 'tag', 'Pk2EndRadio');

axLim = axis;

if get(hPk1Pk, 'value') == 1,
    selectedHistos(1) = x;
    newTag = 'Pk1PkLine';
    newColor = [1 0 0];
    set(hPk1Pk, 'value', 0);
    set(hPk1En, 'value', 1);
  elseif get(hPk1En, 'value') == 1, 
    selectedHistos(2) = x;
    newTag = 'Pk1EndLine';
    newColor = [0 0 1];
    set(hPk1En, 'value', 0);
    set(hPk2St, 'value', 1);
  elseif get(hPk2St, 'value') == 1,
    selectedHistos(3) = x;
    newTag = 'Pk2StLine';
    newColor = [1 0 1];
    set(hPk2St, 'value', 0);
    set(hPk2En, 'value', 1);
  elseif get(hPk2En, 'value') == 1, 
    selectedHistos(4) = x;
    newTag = 'Pk2EndLine';
    newColor = [.8 .5 0];
    set(hPk2En, 'value', 0);
    set(hPk1Pk, 'value', 1);
  else
  end % (if)
  
delete(findobj(hfig,'tag',newTag));
h = plot(x*ones(1,2), axLim(3:4), 'color', newColor);
%h = plot(x*ones(1,2), axLim(3:4), 'color', newColor, 'erasemode', 'xor');
set(h, 'tag', newTag, 'buttondownfcn','pickHist');

hMessages = findobj(hfig, 'tag', 'HistoMessage');
messString = sprintf('interesting message goes here!');
set(hMessages, 'string', messString);
set(hMessages, 'backgroundcolor', MESSAGECOLOR);

hSelButton = findobj(gcf, 'tag', 'HistoAcceptButton');
set(hSelButton, 'backgroundcolor', WARNCOLOR);
  
return
