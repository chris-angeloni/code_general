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
    
    
    
    
%%%-----------------

function [nbrCnt, nbhdMed] = numNeighbors2(a)

nbrCnt = sum(a([1:4 6:9])~=0);
nbhdMed = median(a(:));

return

%%%--------------
    
function [nbrCnt, nbhdMean] = numNeighbors(a)

% Gaussian pdf w/sigma=0.5 
gaussPDF = [0.6193   0.0838    0.0114];

nbrCnt = sum(a([1:4 6:9])~=0);
nbhdMean = gaussPDF([3 2 3 2 1 2 3 2 3])*a(:);
return
