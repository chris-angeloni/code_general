%function [t,Vout,rate]=HHmodel(Iin,Fs,G,E)
%
%		File name:     		Hodgkin_noise
%     Function :				This model is Hodgkin and Huxley's model
%													that can be used to describe the changes
%													of conductance of potassium and sodium
%													during the action potetial and the generation
%													of action potetial.
%		Input		:
%							Iin  		the current array that is injected to cell
%                		Fs			sampling frequency unit 1/ms
%							G        the array of the maximun of ionic conductances
%										the order is GNa,Gk, Gl
%							E        the array of the resting potetial of Ions.
%										the order is ENa,Ek,El,Er
%
%							Iin, Fs and ratio are required. G and E are optional.
%							Default G=[120e-3,36e-3,0.3e-3], E=[55,-72,-49.4,-60]
%		Output	:
%							t 			the time
%							Vout     the membrane potetial, its unit is mv (array)
%                    rate     the rate of spikes, unit is /ms   (value)
%                
%  See also Hodgkin.mdl, action_potential, current_rate, current_sine,refractory,ananoise


function [t,Vout,rate]=HHmodel(Iin,Fs,G,E)
%to initialize parameters
if (nargin<1)
    Iin=(13.6e-6)*ones(10000,1);
    Fs=16000 ;
    G=[120e-3,36e-3,0.3e-3];
    E=[55,-72,-49.4,-60];
elseif (nargin<2)
    Fs=16000;
    G=[120e-3,36e-3,0.3e-3];
    E=[55,-72,-49.4,-60];
elseif (nargin<3)
    G=[120e-3,36e-3,0.3e-3];
    E=[55,-72,-49.4,-60];
else
    E=[55,-72,-49.4,-60];    
end;
Fs=Fs/1000;
Vout=zeros(length(Iin),1);
Spike=zeros(length(Iin),1);
n0=0.3177;
m0=0.0529;
h0=0.5963;
dt=1/Fs;
C=1e-6;
Tau=round(1/G(3)*C*1000*Fs);
j=1;
Vth=10;

for i=1:(length(Iin)-1),
   %to calculate conductance of potassium gk=max(gk)*n^4
   
   alphan=0.01*(-Vout(i)+10)/(exp((-Vout(i)+10)/10)-1);
   betan=0.125*exp(-Vout(i)/80);
   n=n0+dt*alphan*(1-n0)-dt*betan*n0;
   Gk=G(2)*n*n*n*n;
   n0=n;
   %to calculate the conductance of sodium gna=max(gna)*m^3*h
   alpham=0.1*(-Vout(i)+25)/(exp((-Vout(i)+25)/10)-1);
   betam=4*exp(-Vout(i)/18);
   m=m0+dt*alpham*(1-m0)-dt*betam*m0;
   m0=m;
     
   alphah=0.07*exp(-Vout(i)/20);
   betah=1/(exp((-Vout(i)+30)/10)+1);
   h=h0+dt*alphah*(1-h0)-dt*betah*h0;   
   h0=h;
   Gna=G(1)*m*m*m*h;
   
   
   %to calculate the membrane potetial
   
   Ik=Gk*(Vout(i)-(E(2)-E(4)));   %mA
   Ina=Gna*(Vout(i)-(E(1)-E(4)));
   Il=G(3)*(Vout(i)-(E(3)-E(4)));
   Vout(i+1)=Vout(i)+dt*(Iin(i)-(Ik+Ina+Il)*0.001)/C;
   %to calculate number of splikes
   if (abs(Ina)>abs((Ik+Il))) & (i>=j) & (Vout(i)>Vth)
         Spike(i)=1;
         j=i+Tau;
   end      

end

Vout=Vout+E(4)*ones(length(Iin),1);
t=(1:length(Iin))/Fs/1000;
rate=sum(Spike)/(length(Iin)/Fs*0.001);



