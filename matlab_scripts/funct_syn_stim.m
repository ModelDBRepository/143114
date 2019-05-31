%========   Effect of ILD level on the discharge pattern of chopper LSO cells =====================
%** model : LSO_synaptic_input.hoc   ******
% 10/2004

% This script loads NEURON output files and plot PSTHs and spike interval statistics in response to binaural stimulation. 


%*****************     model specs    **************************
%** cell_G=0.03us  
%** refrac_abs_g=10us  refrac_abs= 2ms
%** syn_e_g=1.2ns/50, tau2=1ms, start=5ms
%** syn_i_g=3ns/50, tau2=1ms, start=5ms
%** start_ss=45

%** cell a (AHPg=0.02 us  AHPtau= 20ms )
%** cell b (AHPg=0.05 us  AHPtau= 20ms )
%** cell c (AHPg=0.02 us  AHPtau= 5ms )
%** cell d (AHPg=0.08 us  AHPtau= 5ms )

%*****************     Neuron model inputs    **************************
%** ipsi_E and contra_I Levels

%        A    B    C   D   E   F   G   H
% SPL    0    10   20  30 40  50  60  70 



%** N_run=200 
%** tstop=200ms

%data filename: variable_abs()_AHPg()_AHPtau()_E()_I()

%*****************     Neuron model outputs    **************************
%** dir=./output/binaural
%**  VARIBLES
%**  hist; 
%**  hist_SS; 
%**  psth; 
%**  serialISI; 
%**  serialAHP; 
%**  recover; 

%**  rate; 
%**     rate_infor.x[1]=R
%**     rate_infor.x[2]=R_std
%**     rate_infor.x[3]=R40
%**     rate_infor.x[4]=R40_std
%**     rate_infor.x[5]=mean_ISI_total
%**     rate_infor.x[6]=std_ISI
%**     rate_infor.x[7]=CV_ISI
%**     rate_infor.x[8]=OVF
%**     rate_infor.x[9]=mean_AHP_total
%**     rate_infor.x[10]=std_AHP
%**     rate_infor.x[11]=bin_ISI
%**     rate_infor.x[12]=bin_psth
%**     rate_infor.x[13]=interval




%------------------------------------------------------------------------
clear 
close all

outputDir='test_output\synaptic';
inputDir=pwd;


%**   define parameters  
%% input
% ** use A-H to signal 0:10:70dB and 'W' for 'NAN' 

E='F';  % 50dB; 
I='C';  % 10dB;   

%% model parameters
abs=2;
AHPg=[0.02 0.05 0.02 0.08];
AHPtau=[20 20 5 5];


%***************************************************************************
%** define varibles

interval=4   % ms    for cell 2 interval=6ms
bin_ISI=0.2;   % [ms]   
bin_psth=0.5;  % [ms]

tstop=205;   % [ms]
ISIstop=interval*5;   

time=0:bin_psth:tstop-bin_psth;
t_ISI=0:bin_ISI:ISIstop;

hist_ISI_ss=zeros(length(AHPg),length(t_ISI));
serialISI=zeros(length(AHPg),length(t_ISI));
psth=zeros(length(AHPg),length(time));
rate_infor=zeros(length(AHPg),13);
sptime=zeros(length(AHPg),50*200);  % more than enough

% for PSTH with finer resolution 
bin_psth2=0.25; 
time_PSTH=0:bin_psth2:tstop-bin_psth2;
PSTH=zeros(size(AHPg,2),size(time_PSTH,2));


%---------------------------------------------------------------

% the spiketime analysis 
% 
% data filename: variable_abs()_AHPg()_AHPtau()_E()_I()


cd(outputDir);  



%**         Read files **************
for i=1:4,

   a=num2str(abs,'%2.1f'); b=num2str(AHPg(i),'%2.2f'); c=num2str(AHPtau(i),'%2.1f');  
   if I=='W'
   	stimulus=strcat('abs(',a,')_AHPg(',b,')_AHPtau(',c,')_E(',E,')_I(NAN)');;
   else
   	stimulus=strcat('abs(',a,')_AHPg(',b,')_AHPtau(',c,')_E(',E,')_I(',I,')');
   end

%--------------------
  File='rate';
    
    filename=strcat(File,'_',stimulus); 
    f1=fopen(filename,'r');
    temp=fread(f1,'double');
    rate_infor(i,:)=temp(2:size(temp,1))'; 
    fclose(f1);
   
    

%--------------------
  File='histss';

    filename=strcat(File,'_',stimulus);  
    f1=fopen(filename,'r');
    temp=fread(f1,'double');  
    hist_ISI_ss(i,:)=temp(2:min(length(temp), 102))';
    fclose(f1);


%--------------------
  File='serial';

    filename=strcat(File,'_',stimulus); 
    f1=fopen(filename,'r');
    temp=fread(f1,'double');  
    serialISI(i,:)=temp(2:min(length(temp), 102))'
    fclose(f1);

      
   
%--------------------
  File='psth';

    filename=strcat(File,'_',stimulus); 
    f1=fopen(filename,'r');
    temp=fread(f1,'double'); 
    psth(i,:)=temp(2:size(temp,1))'; 
    fclose(f1);

%--------------------
  File='sptime';
    
    filename=strcat(File,'_',stimulus); 
    f1=fopen(filename,'r');
    temp=fread(f1,'double');
    sptime(i,1:size(temp,1)-1)=temp(2:size(temp,1))'; 
    fclose(f1);
	

end   % end for

%------------------------------------------------------
%**    firing rate 

rate=5*rate_infor(:,1)   % 200msec duration 
rate_std=sqrt(5)*rate_infor(:,2);

T=rate_infor(:,5);
T_std=rate_infor(:,6);
T_CV=rate_infor(:,7)

gAHP_mean=rate_infor(:,9);
gAHP_std=rate_infor(:,10);



%--------------------------------------------------------
%** the onset PSTH in finer resolution'
start_ss=40+5;

time_onset2=0:bin_psth2:start_ss-bin_psth2;

for i=1:length(AHPg),
	spindex=find(diff(sign(diff(sptime(i,:))))>0)+1;  % find the local min downward
	N_run=200;
	PSTH(i,:)=histc(sptime(i,:),time_PSTH)*1000./(bin_psth2*N_run);
	PSTH(i,1)=0;  % sptime padding many zeros; has to eliminate them in psth
	
end


%-----------------------------------------------------

h=figure;
txt={'g=0.02uS; tau=20ms';'g=0.05uS; tau=20ms';'g=0.02uS; tau=5ms';'g=0.08uS; tau=5ms'};  
for i=1:4,
	sub=subplot(4,4,i); set(sub,'fontsize',10);
	bar(time,psth(i,:)); 
	if i==1
        ylabel('Rate (spikes/sec)');
        l=text(-2, -2000, 'E=50dB; I=10dB'); set(l, 'fontsize', 12); 
    end
    xlabel('ms');
    title(txt{i})
	axis([-2 45 0 2100]);
	set(gca,'XTick',0:20:200,'YTick', 0:1000:2000);
	set(gca,'YTickLabel',{'0','1000','2000'});
    set(gca, 'color', 'none','TickDir', 'out', 'TickLength',  [0.02 0.04], 'box', 'off');
end
set(h, 'position', [20 80 950 600]);




%==========================================
A='r';
B='m';
C='b';
D='k';

AA='ro';
BB='ms';
CC='b^';
DD='kd';


subplot(3,3,7);
l=plot(t_ISI, hist_ISI_ss(1,:),A,t_ISI,hist_ISI_ss(2,:),B,t_ISI,hist_ISI_ss(3,:),C,t_ISI,hist_ISI_ss(4,:),D);
set(l,'linewidth',2); 
title('ISIH');
ylabel('Frequency (1/Sec)');
xlabel('T (ms)');

axis([0 ISIstop 0 300]);
set(gca,'XTick',0:ISIstop/5:ISIstop,'YTick', 0:100:300)
set(gca, 'color', 'none','TickDir', 'out', 'TickLength',  [0.02 0.04], 'box', 'off');

txt= legend('g=0.02uS; tau=20ms','g=0.05uS; tau=20ms','g=0.02uS; tau=5ms','g=0.08uS; tau=5ms');  
set(txt,'fontsize',10, 'position', [0.15 0.4 0.2 0.1]); legend boxoff;


subplot(3,3,8); 
l=plot(t_ISI,serialISI(1,:),AA,t_ISI,serialISI(2,:),BB,t_ISI,serialISI(3,:),CC,t_ISI,serialISI(4,:),DD); 

set(l,'linewidth',1, 'markersize', 5); 
title('Conditional  Mean');
xlabel('Tn (ms)');
ylabel('Tn+1 (ms)');
axis([0 ISIstop 0.5 ISIstop]);
set(gca,'XTick',0:ISIstop/5:ISIstop,'YTick', 0:ISIstop/5:ISIstop);
set(gca, 'color', 'none','TickDir', 'out', 'TickLength',  [0.02 0.04], 'box', 'off');








cd(inputDir);  


%cd(colorepsDir); print -depsc2 binaural_ISIH
