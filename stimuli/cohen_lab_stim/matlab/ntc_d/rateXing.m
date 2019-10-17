function xingStimLevel = rateXing(dataCol, xingRate);
%function xingStimLevel = rateXing(dataCol, xingRate);
%
% computes stimulus amplitude required to get response rate of xingRate
%
% dataCol: one column of data from the ntc data matrix
% xingRate: the response rate you want to find the stimulus amplitude for
%
% xingStimLevel: required stimulus level

INCLUDE_DEFS;

% compute rate threshold crossing

rateAtFade = dataCol(RATESLOPE2)*(dataCol(AMPATFADE)-dataCol(AMPATTRANS)) + ...
                 dataCol(RATEATTRANS);
                 
xingStimLevel = NaN;
                 
if xingRate > 0,
    if xingRate<=dataCol(RATEATTRANS),
        xingStimLevel = xingRate/dataCol(RATESLOPE1) + dataCol(RATETHRESH);
      elseif xingRate<=rateAtFade,
          xingStimLevel = ...
              (xingRate-dataCol(RATEATTRANS))/dataCol(RATESLOPE2) + ....
               dataCol(AMPATTRANS);
      end % (if)
  end % (if)
  
return

