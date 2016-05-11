%---------------------------------------------------------------------
% load test signal
%---------------------------------------------------------------------
b=load('testsignal_10dB.mat');
N=length(b.x); Ntime=512; 
x=b.x; Fs=b.Fs;


%---------------------------------------------------------------------
% generate TFD:
% (requires TFD code from http://otoolej.github.io/code/memeff_TFDs/)
%---------------------------------------------------------------------
tf=gen_TFD_EEG(x,Fs,Ntime,'sep');


% parameters for IF methods:
DELTA_SEARCH_FREQ=2;  % in Hz/s 
MIN_IF_LENGTH=6;      % in seconds


t_scale=(length(x)/b.Fs/Ntime);  f_scale=(1/size(tf,2))*(Fs/2);
delta_freq_samples=floor( (DELTA_SEARCH_FREQ/f_scale)*t_scale );
min_track_length=floor( MIN_IF_LENGTH/t_scale );


%---------------------------------------------------------------------
% Rankine et al. (2007) method:
%---------------------------------------------------------------------
lower_prctile_limit=98; 
it=tracks_LRmethod(tf,Fs,delta_freq_samples,min_track_length,lower_prctile_limit);

% plot:
figure(1); clf; hold all; 
for n=1:length(it)
    hlr=plot(it{n}(:,1).*t_scale,it{n}(:,2).*f_scale,'k+'); 
end


%---------------------------------------------------------------------
% McAulay and Quatieri (1986) method:
%---------------------------------------------------------------------
max_peaks=3;
it2=tracks_MCQmethod(tf,Fs,delta_freq_samples,min_track_length,max_peaks);

% plot:
for n=1:length(it2)
    hmcq=plot(it2{n}(:,1).*t_scale,it2{n}(:,2).*f_scale,'ro'); 
end
xlabel('time (seconds)'); ylabel('frequency (Hz)');
xlim([0 N/Fs]);
legend([hlr hmcq],{'LR method','MCQ method'},'location','northwest');
ylim([0.3 2.5]);
% $$$ set_gca_fonts; print2eps('pics/IF_example.eps');
