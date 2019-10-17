function [displayMatdiff]=tc_disparity(displayMat1,displayMat2)


%
%	FILENAME:	tc_disparity
%	DESCRIPTION:	Takes two tuning curves (assumed to be of equal
%			frequency, intensity, and duration), and outputs
%			a disparity tuning curve -- essentially, the 
%			difference betweeen the two inputs.
%
%
% 		function [tcout]=tc_disparity(tc1in,tc2in);


deadspace1 = zeros(size(displayMat1));	%create array depicting unresponsiveregions of tc's
deadspace2 = zeros(size(displayMat1));
% Use a criterion of unresponsiveness based on 20% of bin maximum,...
deadspace1(find(displayMat1<(max(max(displayMat1)/5)))) = 1;
deadspace2(find(displayMat2<(max(max(displayMat2)/5)))) = 1;
% OR just call bins = 0 unresponsive.
%deadspace1(find(displayMat1==0)) = 1;
%deadspace2(find(displayMat2==0)) = 1;


% normalize each displayMat by its maximum firing rate
displayMat1 = displayMat1/(max(max(displayMat1)));
displayMat2 = displayMat2/(max(max(displayMat2)));

displayMat1 = displayMat1 .* ~deadspace1;
displayMat2 = displayMat2 .* ~deadspace2;


product = displayMat1.*displayMat2;	%simply the product of the two tc's (always positive)

diff1_2 = deadspace1 .* displayMat2;
diff2_1 = deadspace2 .* displayMat1;


displayMatdiff = product - (diff1_2 + diff2_1)/1.5;	%division by 1.5 is purely ad hoc, so plots are best
							% for viewing salient similarities/differences
