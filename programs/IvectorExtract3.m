
function [y,class]=IvectorExtract3(pathstates,IvectorSvmpath,TrainMethod)
%------------------------------------------------------------------
load(pathstates);
load([pathstates,'\train']);
LDAmodel=[];P_NAP=[];B_WCCN=[];
mkdir([Path.Prog,'\models']);
mkdir([Path.Prog,'\data']);
mkdir([Path.Prog,'\data\Features']);
JFA_s_exp         =[Path.Prog,'\exp\'];            mkdir(JFA_s_exp);
JFA_s_lists       =[Path.Prog,'\lists\'];          mkdir(JFA_s_lists);
JFA_s_output      =[Path.Prog,'\optimum_output\']; mkdir(JFA_s_output);
JFA_s_stats       =[Path.Prog,'\data\stats\'];     mkdir(JFA_s_stats);
[MSV,CSV,W]=readALZgmm_FA([IvectorSvmpath,'\Models\UBM.gmm']);
save ([Path.Prog,'\models\ubm_means'],'MSV','-ASCII');
save ([Path.Prog,'\models\ubm_variances'],'CSV','-ASCII');
save ([Path.Prog,'\models\ubm_weights'],'W','-ASCII');
%--------------------------------------------------------------------------
fid_List = fopen([JFA_s_lists  'FA-ivector'  ,'.lst'],'w');
Label1 ='MIX04_';
Label2 ='_f=';
Label3 ='data/Features/';
NumLan=Train.NumSpeaker;
k=0;
dirtrainpath=dir(Path.TargetSpeakers_Train);
class=[];
for i=1:NumLan      
    wavpath=dir([Path.TargetSpeakers_Train,'\',dirtrainpath(i+2).name,'\*.wav']);
    for j=1:size(wavpath)        
        Ftname=wavpath(j).name; Ftname(end-3:end)=[];
        k=k+1;
        class(k)=i;
        VV = readHTK([IvectorSvmpath,'\Features\', Ftname,'.ftr'],0);
        save ([Path.Prog,'\data\Features\', Ftname,'.ascii'],'VV','-ASCII');
        Label4=dirtrainpath(i+2).name;
        fprintf(fid_List,'%s\n' ,[Label1 Label4  Label2 Label3 Ftname]);
    end
end
fclose all;

%Baum Weltch:
if (TrainMethod==1)
    make_suf_stat_enroll(Path.Prog,[Path.Prog,'\data\Features\'],'FA-ivector');
elseif (TrainMethod==2)
    make_suf_stat_enroll_ivector('FA-ivector');
end
%--------------------------------------------------------------------------
if (TrainMethod==1)
    train_mat_file = ['./data/stats/' 'FA-ivector'];
    load(train_mat_file); %loads F, N, spk_ids
elseif (TrainMethod==2)
    S1=load('data/stats/1.mat');
    F=S1.Fi';
    N=S1.Ni';    
end
m = load(['models/ubm_means'], '-ascii');
E = load(['models/ubm_variances'], '-ascii');
spk_ids=(1:k)';
n_speakers=max(spk_ids);
n_sessions=size(spk_ids,1);
S = [];

%---
load(['optimum_output/' ['v_opt_' num2str(10) ]], 'v');
%---
if (TrainMethod==1)
    [y]=estimate_y_and_v(F, N, S, m, E, 0, v, 0, zeros(n_speakers,1), 0, zeros(n_sessions,1), spk_ids);
elseif (TrainMethod==2)
    [y]=estimate_y_and_v_ivector(S, m, E, 0, v, 0, zeros(n_speakers,1), 0, zeros(n_sessions,1), spk_ids);
end
%---