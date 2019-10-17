function [Ravg,Rstd,R05,R01,R]=rastercircularxcorr3(RASTER,Fsd,NB)

T=RASTER(1).T;
[RAS,Fs]=rasterexpand(RASTER,Fsd,T);
ntrial = size(RAS,1);
nsample = size(RAS,2);

for k=1:ntrial
  RASfft(k,:) = fft(RAS(k,:));
  RASfft_r(k,:) = real(RASfft(k,:));
  RASfft_i(k,:) = imag(RASfft(k,:));
end

RASv_r = matrixh2v(RASfft_r);
RASv_i = matrixh2v(RASfft_i);

[rasifft_r,rasifft_i] = mexrasfft2corrifft(RASv_r,RASv_i,ntrial,nsample);

rasifft=complex(rasifft_r, rasifft_i);
rasiffth = matrixv2h(rasifft);

for n=1:(ntrial*(ntrial-1)/2)
 R(n,:) = ifft(rasiffth(n,:))/Fsd/T;
end

if size(R,1)>1
	Ravg=mean(R);
else
	Ravg=R;
end
if NB~=0
	[Rstd,R05,R01]=rastercorrbootstrap(R,NB);
else
	R05=-9999;
	R01=-9999;
end