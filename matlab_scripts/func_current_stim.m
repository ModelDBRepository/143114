%========   Come the discharge pattern of chopper LSO cells with the same current input=====================
%** NEURON mode: LSO_current_input.hoc   ******
% 10/2004

% This script loads NEURON output files and plots a subset of results shown in Figures 3-5 in Zhou and Colburn 2010. 

%*****************     model specs    **************************
%** cell_G=0.03us  
%** refrac_abs_g=10us  refrac_abs= 2ms

%** cell a (AHPg=0.02 us  AHPtau= 20ms )
%** cell b (AHPg=0.05 us  AHPtau= 20ms )
%** cell c (AHPg=0.02 us  AHPtau= 5ms )
%** cell d (AHPg=0.08 us  AHPtau= 5ms )


%*****************     Neuron model inputs    **************************
%** mean_current=1.4 nA
%** mean_std=0.4 nA

%** N_run=50 
%** tstop=200ms
%** start_ss=0

% data filename: variable_abs()_AHPg()_AHPtau()_mean()_std()

%*****************     Neuron model outputs    **************************
%** dir=./test_output/current
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

% order of stimuli: a (g=0.02uS;tau=20ms) b (g=0.05uS;tau=20ms) c (g=0.02uS;tau=5ms) d (g=0.028uS;tau=5ms) 


%------------------------------------------------------------------------
clear all
close all

outputDir='test_output\current';
inputDir=pwd;


cd(outputDir);  



%**   define parameters  
%% absolute refractory period
abs=2;

%% input parameters 
mean_I=1.4;
std_I=0.4;

%% model parameters
AHPg=[0.02 0.05 0.02 0.08];
AHPtau=[20 20 5 5];

%** define varibles

interval=4;   % ms    
bin_ISI=0.2;   % ms
bin_psth=0.5;  % ms
tstop=200;   % [ms]

ISIstop=interval*5;   % 10 for fast;  20 for slow [ms]

time=0:bin_psth:tstop-bin_psth;
t_ISI=0:bin_ISI:ISIstop;

hist_ISI=zeros(4,size(t_ISI,2));
hist_ISI_ss=zeros(4,size(t_ISI,2));
serialISI=zeros(4,size(t_ISI,2));
serialAHP=zeros(4,size(t_ISI,2));
psth=zeros(4,size(time,2));

rate_infor=zeros(4,13);

% for PSTH with finer resolution 
bin_psth2=0.25; 
time_PSTH=0:bin_psth2:tstop-bin_psth2;
PSTH=zeros(length(AHPg),size(time_PSTH,2));


%---------------------------------------------------------------


a=num2str(abs,'%2.1f'); 
d=num2str(mean_I,'%2.1f');
e=num2str(std_I,'%2.1f');

% the spiketime analysis 
% 
% data filename: variable_abs()_AHPg()_AHPtau()_mean()_std()


%----   Read files -------

for i=1:4,
   b=num2str(AHPg(i),'%2.2f'); c=num2str(AHPtau(i),'%2.1f');  
   stimulus=strcat('abs(',a,')_AHPg(',b,')_AHPtau(',c,')_mean(',d,')_std(',e,')');

%--------------------
  File='rate';
    
    filename=strcat(File,'_',stimulus); 
    f1=fopen(filename,'r');
    temp=fread(f1,'double');
    rate_infor(i,:)=temp(2:size(temp,1))'; 
    fclose(f1);
   
    



%--------------------
  File='hist';

    filename=strcat(File,'_',stimulus); 
    f1=fopen(filename,'r');
    temp=fread(f1,'double');  
    hist_ISI(i,:)=temp(2:size(temp,1))';	
    fclose(f1);


%--------------------
  File='histss';

    filename=strcat(File,'_',stimulus);  
    f1=fopen(filename,'r');
    temp=fread(f1,'double');  
    hist_ISI_ss(i,:)=temp(2:size(temp,1))';
    fclose(f1);

%--------------------
  File='recover';
    
    filename=strcat(File,'_',stimulus);  
    f1=fopen(filename,'r');
    temp=fread(f1,'double');
    end_serial(i)=size(temp,1)-1;	  % pass the index of the end to serialISI/serialAHP
    fclose(f1);
  
 
    if (AHPg(i)==0.02) & (AHPtau(i)==20) 
			recover_A=temp(2:size(temp,1))'; 
			ISIA=0:bin_ISI:(size(recover_A,2)-1)*bin_ISI;
    end

    if (AHPg(i)==0.05) & (AHPtau(i)==20) 
			recover_B=temp(2:size(temp,1))'; 
			ISIB=0:bin_ISI:(size(recover_B,2)-1)*bin_ISI;
    end


    if (AHPg(i)==0.02) & (AHPtau(i)==5) 
			recover_C=temp(2:size(temp,1))'; 
			ISIC=0:bin_ISI:(size(recover_C,2)-1)*bin_ISI;
    end


    if (AHPg(i)==0.08) & (AHPtau(i)==5) 
			recover_D=temp(2:size(temp,1))'; 
			ISID=0:bin_ISI:(size(recover_D,2)-1)*bin_ISI;
    end




%--------------------
  File='serial';

    filename=strcat(File,'_',stimulus); 
    f1=fopen(filename,'r');
    temp=fread(f1,'double');  
    serialISI(i,:)=temp(2:size(temp,1))';
    fclose(f1);

      %====   the coefficients (k,b) of the linear fit  y=kx+b

    
    % fit the non-zeron elements
    x=(find(serialISI(i,1:end_serial(i)))); 
    start_serial(i)=min(x);

    serialtime_ISI=t_ISI(x);
    [p_ISI(i,:),S(i,:)]=polyfit(serialtime_ISI,serialISI(i,x),1);
    meanfit_ISI(i,:)=p_ISI(i,1).*t_ISI+p_ISI(i,2); 
    
    %[h, p, slope(i,:)]=ttest(serialISI(i,x));
   

%--------------------
  File='serialAHP';

    filename=strcat(File,'_',stimulus); 
    f1=fopen(filename,'r');
    temp=fread(f1,'double');  
    serialAHP(i,:)=temp(2:size(temp,1))';
    fclose(f1);

      %====   the coefficients (k,b) of the linear fit  y=kx+b

    % fit the non-zeron elements
    x=(find(serialAHP(i,1:end_serial)));
    serialtime_AHP=t_ISI(x);
    [p_AHP(i,:),S_AHP(i,:)]=polyfit(serialtime_AHP,serialAHP(i,x),1);
    meanfit_AHP(i,:)=p_AHP(i,1).*t_ISI+p_AHP(i,2); 

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

rate=5*rate_infor(:,1);
rate_std=sqrt(5)*rate_infor(:,2);

T=rate_infor(:,5);
T_std=rate_infor(:,6);
T_CV=rate_infor(:,7);

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
        l=text(-2, -2000,'I=1.4nA; SD=0.4nA'); set(l, 'fontsize', 12);
    end
    xlabel('ms');
    title(txt{i})
	axis([-2 45 0 2100]);
	set(gca,'XTick',0:20:200,'YTick', 0:1000:2000);
	set(gca,'YTickLabel',{'0','1000','2000'});
    set(gca, 'color', 'none','TickDir', 'out', 'TickLength',  [0.02 0.04], 'box', 'off');
end
set(h, 'position', [20 80 950 600]);


%% ISI and Hazard fucntion
A='r';
B='m';
C='b';
D='k';

AA='ro';
BB='ms';
CC='b^';
DD='kd';



subplot(3,3,7);

l=plot(t_ISI, hist_ISI_ss(1,:),A,t_ISI,hist_ISI_ss(2,:),B,t_ISI,hist_ISI_ss(3,:)./2,C,t_ISI,hist_ISI_ss(4,:),D);
set(l,'linewidth',2); 
title('ISIH');
ylabel('Frequency (1/Sec)');
xlabel('T (ms)');

axis([0 ISIstop 0 1000]);
set(gca,'XTick',0:ISIstop/5:ISIstop,'YTick', 0:250:1000)
txt= legend('g=0.02uS; tau=20ms','g=0.05uS; tau=20ms','g=0.02uS; tau=5ms','g=0.08uS; tau=5ms');  
set(txt,'fontsize',10, 'position', [0.15 0.4 0.2 0.1]); legend boxoff;
set(gca, 'color', 'none','TickDir', 'out', 'TickLength',  [0.02 0.04], 'box', 'off'); 



subplot(3,3,8); 
l=plot(ISIA,recover_A,A,ISIB,recover_B,B,ISIC,recover_C./2,C,ISID,recover_D,D);
set(l,'linewidth',2); 
title('Recovery Function');
ylabel('Frequency (1/Sec)'); 
xlabel('T(ms)');

axis([0 ISIstop 0 4000]);
set(gca,'XTick',0:ISIstop/5:ISIstop,'YTick', 0:1000:4000)
set(gca, 'color', 'none','TickDir', 'out', 'TickLength',  [0.02 0.04], 'box', 'off'); 




subplot(3,3,9);  
serialISI(:,1)=0;  % eliminate simulation errors
l=plot(t_ISI,serialISI(1,:),AA,t_ISI,serialISI(2,:),BB,t_ISI,serialISI(3,:),CC,t_ISI,serialISI(4,:),DD); hold 
set(l,'linewidth',1, 'markersize', 5); 

title('Conditional  Mean');
xlabel('Tn (ms)');
ylabel('Tn+1 (ms)');
axis([0 ISIstop 0.5 ISIstop]);
set(gca,'XTick',0:ISIstop/5:ISIstop,'YTick', 0:ISIstop/5:ISIstop)
set(gca,'XTickLabel',{'0','4','8','12','16','20'});
set(gca, 'color', 'none','TickDir', 'out', 'TickLength',  [0.02 0.04], 'box', 'off'); 


cd(inputDir);  

