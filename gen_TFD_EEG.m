%-------------------------------------------------------------------------------
% gen_TFD_EEG: Set parameters and generate TFD, using 'fastTFD' package (see [1])
%
% Syntax: tfd=gen_TFD_EEG(x,Fs,Ntime,TYPE)
%
% Inputs: 
%     x     - input time-domain signal
%     Fs    - sampling frequency
%     Ntime - sampling frequency in time-direction of TFD
%     TYPE  - either 'sep' (separable-kernel) or 'lag-indep' 
%             (lag-independent kernel)
%
% Outputs: 
%     tfd - TFD of size Ntime x Nfreq 
%
% Example:
%    b=load('testsignal_10dB.mat');
%
%    tf=gen_TFD_EEG(b.x,b.Fs,512,'sep');
%    figure(1); clf; vtfd(tf,b.x,b.Fs);
%    xlim([0 8]);
%     
%
% [1] J.M. O' Toole and B. Boashash, "Fast and memory-efficient
% algorithms for computing quadratic time--frequency distributions", 
% Applied and Computational Harmonic Analysis, 35(3), pp. 350-358, 2013
% (doi:10.1016/j.acha.2013.01.003)
%
% [2] J.M. O' Toole and B. Boashash, “Memory Efficient Algorithms for Quadratic TFDs”,
% Chapter 6.6; in Time–Frequency Signal Analysis and Processing, Second Edition, Academic
% Press, pp. 374–385, 2016 (ISBN: 9780123984999).
%
% REQUIRES TFD toolbox: http://otoolej.github.io/code/memeff_TFDs/


  

% John M. O' Toole, University College Cork
% Started: 10-05-2013
%-------------------------------------------------------------------------------
function tfd=gen_TFD_EEG(x,Fs,Ntime,TYPE)
if(nargin<3 || isempty(Ntime)) Ntime=[]; end
if(nargin<4 || isempty(TYPE)) TYPE='sep'; end 

DB=0;
N=length(x);

%---------------------------------------------------------------------
% 0. Parameters for TFD
%---------------------------------------------------------------------
switch TYPE
  case 'sep'
    
    % set parameters:
    Nfreq=8192*4;    
    if(isempty(Ntime))
      Ntime=2048; 
    end

    win_lag={get_odd_int(10*Fs),'hamm'}; 

    f_dopp_Hz=0.5; % length of doppler window in Hertz    
    L_dopp=get_odd_int( floor(f_dopp_Hz*(N/Fs)) );
    win_dopp={L_dopp,'hann',0.01,1};


    if(DB)
        dispVars(win_lag);
        dispVars(win_dopp);
        dispVars(N,Ntime,Nfreq);
    end


    dt=full_tfd(x,'sep',{win_dopp,win_lag},Ntime,Nfreq);
    tfd=dt;

    
    
  case 'lag-indep'
    Ntime=2048*2; 

    f_dopp_Hz=1.75; % length of doppler window in Hertz
    L_dopp=make_odd( floor(f_dopp_Hz*(N/Fs)) );
    win_dopp={L_dopp,'hamm',0.01,1};


    if(DB)
        dispVars(win_dopp);
        dispVars(N,Ntime);
    end


    dt=dtfd_LI(x,win_dopp,Ntime);
    tfd=dt;
end

DBplot=0;
if(DBplot)
    figure(5); clf;
    vtfd(tf',[],Fs,0:25,0:20); 
    ylabel('frequency (Hz)'); xlabel('time (seconds)');
    ylim([0 5]); set(gca,'ytick',0:5);
% $$$     set_gca_fonts;   print2eps('pics/TFD_example.eps');
end

    
    
function x=get_odd_int(x)
if(~rem(x,2))
    x=x-1;
end
