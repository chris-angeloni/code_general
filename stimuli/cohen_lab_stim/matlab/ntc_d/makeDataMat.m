function dataMat = makeDataMat(latencies,minLatency,maxLatency);

% function dataMat = makeDataMat(latencies,minLatency,maxLatency);

global NFREQS NAMPS fMin nOctaves extAtten

%--------------------------



inRange = find(latencies(:,1)<=maxLatency);
inRange = find(minLatency<=latencies(inRange,1));

numInRange = length(inRange);
dataMat = zeros(NFREQS,NAMPS);

for ii=1:numInRange,
  dataMat(latencies(inRange(ii),2),latencies(inRange(ii),3)) = ...
     dataMat(latencies(inRange(ii),2),latencies(inRange(ii),3)) + 1;
  end

hmenu = findobj('tag','SmoothMenu');

hoptions = get(hmenu,'children');
smoothType = get(hoptions(strcmp('on',get(hoptions,'Checked'))),'Tag');

switch smoothType
  case 'Smooth1Option',
    dataMat = smoothDisplay(dataMat);
  case 'Smooth2Option',
    dataMat = smooth2(dataMat);
  case 'SmoothMOption',
    dataMat = smoothM(dataMat);
  otherwise,
  end
  
  spontRate = compSpontRate;
  
if (get(findobj('tag','SpontBox'), 'value') == 1),
  dataMat = rmbkgnd(dataMat, spontRate);
  end

return




function dataMat = rmbkgnd(dataMat, spontRate)
%  function dataMat= rmbkgnd(dataMat, spontRate)
%
%      A utility to remove the background activity
%        in an organized way from a 2d tuning curve.
%        spont is the number of background spikes
%        to remove per row of frequencies.

%  this removes as many 'whole' spikes as it can, and then removes partial
%    spikes until it takes exactly spont spikes from every row

INCLUDE_DEFS;

global NAMPS NFREQS

spontPercent = str2num(get(findobj('tag', 'PercentEdit'), 'string'));
dispDuration = get(findobj('tag','DurationSlider'),'value');

spont = spontRate/1000.0 * dispDuration * spontPercent/100.0;

zeroInds = find(dataMat==0);
dataMat(zeroInds) = Inf;

for ampl = 1:NAMPS,
   s = spont*NFREQS;
   while s > 0,
     minVal = min(dataMat(:,ampl));
     minInds = find(dataMat(:,ampl) == minVal);
     if minVal*length(minInds) <= s
         % if possible, kill integral minVal's
         dataMat(minInds,ampl) = Inf;
         s = s - minVal*length(minInds);
       else
         % finally, distribute the pain of the remaining s among the minVal's
         dataMat(minInds,ampl) = (minVal - s/length(minInds));
        s = 0;
      end % (if)
    end % (while)
  end % (for)

zeroInds = find(dataMat==Inf);
dataMat(zeroInds) = 0;

return

%%%--------------------

function smoothed_data = smoothDisplay(data)
% function smoothed_data = smoothDisplay(data)
% smooths the 2D array display by performing a local
% weighted average of each bin with the adjacent bins

l_shift = [data(:,    1    )      data(:,        1:(end-1))];
r_shift = [data(:,    2:end)      data(:,        end      )];
u_shift = [data(1,    :    )    ; data(1:(end-1),:        )];
d_shift = [data(2:end,:    )    ; data(end,      :        )];

ul_shift = [l_shift(1,    :); l_shift(1:(end-1),:)];
ur_shift = [r_shift(1,    :); r_shift(1:(end-1),:)];
dl_shift = [l_shift(2:end,:); l_shift(end,      :)];
dr_shift = [r_shift(2:end,:); r_shift(end,      :)];

smoothed_data = 4 * data + ...
                (l_shift + r_shift + u_shift + d_shift) + ...
                sqrt(2)/2 * (ul_shift + ur_shift + dl_shift + dr_shift);
               
smoothed_data = smoothed_data / (8 + 2*sqrt(2));

return


%%%----------------

function modMat = smooth2(dataMat)

nRows = size(dataMat,1);
nCols = size(dataMat,2);

dataMat = [[dataMat(1,1)   dataMat(1,:)   dataMat(1,end)];...
           [dataMat(:,1)   dataMat        dataMat(:,end)];...
           [dataMat(end,1) dataMat(end,:) dataMat(end,end)]];
           
modMat = dataMat;

for ii=2:(nRows+1),
  for jj=2:(nCols+1),
    matBlk = dataMat(ii+(-1:1), jj+(-1:1));
    [nbrCnt,nbhdMean] = numNeighbors(matBlk);
    if nbrCnt>=3,
        modMat(ii,jj) = nbhdMean;
      elseif nbrCnt<2,
        modMat(ii,jj) = 0;
      end % (if)
    end % (for)
  end % (for)

modMat = modMat(2:(end-1),2:(end-1));

return
    
%%%--------------
    
function [nbrCnt, nbhdMean] = numNeighbors(a)

% Gaussian pdf w/sigma=0.5 
gaussPDF = [0.6193   0.0838    0.0114];

nbrCnt = sum(a([1:4 6:9])~=0);
nbhdMean = gaussPDF([3 2 3 2 1 2 3 2 3])*a(:);
return

%%%-----------------

function modMat = smoothM(dataMat)

nRows = size(dataMat,1);
nCols = size(dataMat,2);

dataMat = [[dataMat(1,1)   dataMat(1,:)   dataMat(1,end)];...
           [dataMat(:,1)   dataMat        dataMat(:,end)];...
           [dataMat(end,1) dataMat(end,:) dataMat(end,end)]];
           
modMat = dataMat;

for ii=2:(nRows+1),
  for jj=2:(nCols+1),
    matBlk = dataMat(ii+(-1:1), jj+(-1:1));
    [nbrCnt,nbhdMean] = numNeighborsM(matBlk);
    if nbrCnt>=3,
        modMat(ii,jj) = nbhdMean;
      elseif nbrCnt<2,
        modMat(ii,jj) = 0;
      end % (if)
    end % (for)
  end % (for)

modMat = modMat(2:(end-1),2:(end-1));

return
    
%%%-----------------

function [nbrCnt, nbhdMed] = numNeighborsM(a)

nbrCnt = sum(a([1:4 6:9])~=0);
nbhdMed = median(a(:));

return

