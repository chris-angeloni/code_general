%fuction ananoise(fun,Iin,ratio)
%      Function    effect of Gaussian noise on spike rate
%      Input       fun   the choice of function,0 or 1
%                        0 simulates the comparation between noise and no noise
%                        when fun=0,  Iin and ratio are requered.
%                        1 simulates the relationship among current, ratio and rate
%                        when fun=1,  Iin and ratio are not requered.
%
%     see also  Hodgkin.mdl, Hodgkin1, action_potential, current_rate, current_sine, refractory
%
% note: it takes long time to run this program
%
%      

function ananoise(fun,Iin,ratio)

if fun==0
  %to calculate no noise response
  mode=0;
  Noise=zeros(length(Iin),1);
  [t,Vout,Spike,Vth,Vmax,rate,Gk,Gna,m,n,h]=Hodgkin1(mode,Noise,Iin);
  hold on;
  subplot(2,1,2); 
  plot(t,Vout);
  hold on;
  if rate~=0
    plot(Vth(:,1),Vth(:,2),'ro');
    hold on;
    plot(Vmax(:,1),Vmax(:,2),'r*');
  end;
  xlabel('T  (msec)');
  ylabel('Membrane Potential (mV)');
  title('No-Noise');
%to calculate noise_response
  mode=1;
  Noise=normrnd(0,1,length(Iin),1);
  Fs=100;
  [t,Vout,Spike,Vth,Vmax,rate,Gk,Gna,m,n,h]=Hodgkin1(mode,Noise,Iin,Fs,ratio);
  hold on;
  subplot(2,1,1);
  plot(t,Vout,'r');
  hold on;
  if rate~=0
    plot(Vth(:,1),Vth(:,2),'bo');
    hold on;
     plot(Vmax(:,1),Vmax(:,2),'b*');
  end;
  xlabel('T  (msec)');
  ylabel('Membrane Potential (mV)');
  title('Gaussian Noise');
end;

%to calculate the relationship among current, ratio and rate

if fun==1
Fs=100;
  for i=1:10,
      ratio(i)=0.1+0.5*(i-1);
        for j=1:20,
            if  j==1
	      Iinput(j)=0.9e-6;
              Iin=Iinput(j)*ones(5000,1);
            else
	      Iinput(j)=5*(j-1)*1e-6;
              Iin=Iinput(j)*ones(5000,1);
            end;
            mode=0;
            Noise=zeros(5000,1);
            [t,Vout,Spike,Vth,Vmax,rate,Gk,Gna,m,n,h]=Hodgkin1(mode,Noise,Iin);
            rate0(i,j)=rate;
            clear('t','Vout','Spike','Vth','Vmax','rate','Gk','Gna','m','n','h');
            %to caculate stochastic rate
            for k=1:10,
		    mode=1;
                    Noise=normrnd(0,1,5000,1);
                    [t,Vout,Spike,Vth,Vmax,rate,Gk,Gna,m,n,h]=Hodgkin1(mode,Noise,Iin,Fs,ratio(i));
                    rate_noise(k)=rate;
                    clear('t','Vout','Spike','Vth','Vmax','rate','Gk','Gna','m','n','h');
            end;            
            rate1(i,j)=sum(rate_noise)/length(rate_noise)-rate0(i,j);
            clear('rate_noise');
         end;
   end 

			mesh(Iinput,ratio,rate1);
         xlabel('Current (mA)');
         ylabel('Ratio');
         zlabel('Spike Rate (1/msec)');

			save data/rate1.mat rate1;
         save data/rate0.mat rate0;
         save data/Iinput.mat 1000*Iinput;
         save data/ratio.mat  ratio;
  end;
          

   
  
