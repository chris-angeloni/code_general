function pk = tiff(A);
%TIFF	Packbits compress a matrix of bytes.
%	P = TIFF(A) compresses the matrix A and returns the packed
%	result in P.
%
%	TIFF is used by TIFFWRITE.
%
%	See also: UNTIFF, TIFFWRITE.

%	Copyright (c) 1993 by The MathWorks, Inc.
%	$Revision: 1.5 $  $Date: 1993/09/09 21:35:30 $

[length,width] = size(A);
n = 1;
count = 1;

h = waitbar(0,'Writing TIFF file...');
for i = 1:length
  waitbar(i/length)
  for j = 1:width
    run(n) = A(i,j);
    if (n == 2)
      if (run(2) == run(1))
        repeat = 1;
      else 
        repeat = 0;
      end
    elseif (n > 2)
      if ((repeat == 0) & (j < width))
        if ((run(n) == run(n-1)) | (n == 128))
          if (A(i,j+1) == run(n))
            pk(count) = n-3;
            pk(count+1:count+n-2) = run(1:n-2);
            count = count+n-1;
            repeat = 1; 
            run(1:2) = run(n-1:n);
            n = 2;
          elseif (n == 128)
            pk(count) = 127;
            pk(count+1:count+128) = run(1:128);
            n = 0;
            count = count + 129;
            repeat = 0;   
          end
        end
      elseif (repeat == 1)
        if ((run(n) ~= run(n-1)) | (n == 129))
          pk(count) = 2 - n;
          pk(count+1) = run(n-1);
          run(1) = run(n);    
          n = 1;
          count = count + 2;
        end
      end
    end
    n = n + 1;
  end
  % at end of row;
  if (repeat == 1)
    pk(count) = 2 - n;
    pk(count+1) = run(n-1);
    n = 1;
    count = count + 2;
  else
    pk(count) = n-2;
    pk(count+1:count+n-1) = run(1:n-1);
    count = count+n;
    n = 1;
  end
end
close(h)

