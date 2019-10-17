function resizeNTCFig()

% function resizeNTCFig() 
%
%    Scales the fonts more-or-less proportionately when the foreground ntc figure is resized.
%    Scaling can be set differently for different operating systems with a call to getOSinfo.
 
%    Revised 2/99 by pj, from earlier versions by ben.

newPos = get(gcf,'position');

[OStype, OSversion] = getOSinfo;

switch OStype
   case{'unix'},
      newFontScale = min(newPos(3:4)./[.4 .5]);
   case{'mac'},
      newFontScale = min(newPos(3:4)./[.4 .5]);
   case{'windows'},
      newFontScale = 1;
   otherwise,  % getOSinfo isn't working; bail
      newFontScale = 1;
end

allObjs = findall(gcf);
allFonts = [];
allFonts = findall(allObjs, 'type', 'axes');
allFonts = [allFonts; findall(allObjs, 'type', 'text')];
allFonts = [allFonts; findall(allObjs, 'type', 'uicontrol')];
% may be missing some type of object here, but i don't know what offhand...

allSizes = get(allFonts,'fontsize');
for ii=1:length(allSizes),
  set(allFonts(ii), 'fontsize', allSizes{ii}*newFontScale);
end

return
