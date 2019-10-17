  %create pseudorandom array for tuning curve reconstructions


freq=[15 4  13 41 43 35 16 24 1  42 25 12  7 45 3 ...
      18 27 26 22 8  31 36 40 20 17 29 2  19 37 6 ...
      21 23 30 28 9  10 32 5  38 33 34 11 39 14 44];
	
amp= [15 13 14 8  12 9  6  4  1  10 2  3  11 5 7 ...
      15 13 14 8  12 9  6  4  1  10 2  3  11 5 7 ...
      15 13 14 8  12 9  6  4  1  10 2  3  11 5 7];

pseudorand = zeros(675,2);	%the paired freq-ampl values presented
order = zeros(675,1);		%the order of presentation, from
				%(1,1);(2,1);...;(44,15);(45,15).

for j = 0:14		
	for i = 1:45		%freq loop
	   pseudorand(j*45+i,1:2) = [freq(i),amp(i)];
	   order(j*45+i) = (amp(i)-1)*45 + freq(i);
     	end %freq

	%permute amplitude array
        amp=[amp(2:45) amp(1)];
        
end 		

save order order

clear j i
