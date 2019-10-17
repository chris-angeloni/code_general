function [RAS2]=cuttrials(RAS1,FMAxis,N2)

N1 = length(RAS1)/length(FMAxis)
for FMi = 1:length(FMAxis)
RAS2(N2*(FMi-1)+1 : N2*(FMi-1)+N2) = RAS1(N1*(FMi-1)+21 : N1*(FMi-1)+20+N2)
end