function modNTCFonts(direction)
%function modNTCFonts(direction)

allObjs = findall(gcf);
allFonts = [];
allFonts = findall(allObjs, 'type', 'axes');
allFonts = [allFonts; findall(allObjs, 'type', 'text')];
allFonts = [allFonts; findall(allObjs, 'type', 'uicontrol')];
allFonts = unique(allFonts);

% may be missing some type of object here, but i don't know what offhand...

allSizes = get(allFonts,'fontsize');

switch direction,
  case 'Larger',
    sizeFact = 1.25;
  case 'Smaller',
    sizeFact = 0.8;
  end % (switch)

for ii=1:length(allSizes),
  set(allFonts(ii), 'fontsize', allSizes{ii}*sizeFact);
  end

return
