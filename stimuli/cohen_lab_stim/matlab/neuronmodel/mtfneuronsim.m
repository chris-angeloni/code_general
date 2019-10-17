%
%function [RASTER]= mtfneuronsim(FM,Tau,Tref,Vtresh,Vrest,Fs)
%
%       FILE NAME   : MTF NUERON SIM 
%
%       DESCRIPTION : Auditory Neuron MTF simulation with integrate and
%
%   	Tau         : Integration time constant (msec)
%   	Tref        : Refractory Period (msec)
%   	Vtresh      : Threshold Membrane Potential (mVolts)
%   	Vrest       : Resting Membrane Potential - Same as the Leackage
%                     Membrane Potential (mVolts)
%   	Fs          : Sampling Rate
%
%OUTPUT SIGNAL
%
%       RASTER	: Rastergram
%
function [RASTER]= mtfneuronsim(FM,T,dt,rt,fc,Fs,Fsd,L)
%Fsd=2000;
gamma=1;

for l=1:length(FM)
    for k=1:L       
        l
        
        %XPNB=ammodnoise(inf,FM(l),gamma,T,dt,rt,Fs);
        XSAM=sammodnoise(inf,FM(l),gamma,T,Fs);
        
%        [Y,S,V,U,Vm,Im,In]=haircellspikingmodel([10000 5000 1 1 -65 -55 Fs 50E-6 1E-7 0 0],XPNB);
%[Y,S,V,U,Vm,Im,In]=iccellspikingmodel([10000 5000 10 1 -65 -55 Fs 100E-6 1E-7 5 1.5 5 50 pi/4     0 0],XSAM);
[Y,S,V,U,Vm,Im,In]=haircellspikingmodel([10000 5000 1 1 -65 -55 Fs 1E-6 1E-7      0 0],XSAM);

        [spet]=impulse2spet(S,Fs,Fsd);
        RASTER(k+L*(l-1),:).spet=spet;
        RASTER(k+L*(l-1),:).Fs=Fs; 
        RASTER(k+L*(l-1),:).T=T;
        
    end
end
