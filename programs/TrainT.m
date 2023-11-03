
%%%%  Train T %%%%%%%

function y=TrainT(pathstates,IvectorSvmpath,ny,TrainMethod)
%------------------------------------------------------------------
load(pathstates);
load([pathstates,'\train']);
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
fid_List = fopen([JFA_s_lists  'ivector-T'  ,'.lst'],'w');
Label1 ='MIX04_';
Label2 ='_f=';
Label3 ='data/Features/';
k=0;
dirUBM=dir([Path.UBM,'\*.wav']);
for i=1:length(dirUBM)
    k=k+1;
    FtName=dirUBM(i).name;  FtName(end-3:end)=[];
    VV = readHTK([IvectorSvmpath,'\Features\',FtName,'.ftr'],0);
    save ([Path.Prog,'\data\Features\', FtName,'.ascii'],'VV','-ASCII');
    Label4='UBM';
    fprintf(fid_List,'%s\n' ,[Label1 Label4  Label2 Label3 FtName]);
end
fclose all;

%Baum Weltch:
if (TrainMethod==1)
    make_suf_stat_enroll(Path.Prog,[Path.Prog,'\data\Features\'],'ivector-T');
elseif (TrainMethod==2)
    make_suf_stat_enroll_ivector('ivector-T');
end
%--------------------------------------------------------------------------
if (TrainMethod==1)
    train_mat_file = ['./data/stats/' 'ivector-T'];
    load(train_mat_file); %loads F, N, spk_ids
elseif (TrainMethod==2)
    S1=load('data/stats/1.mat');
    F=S1.Fi';
    N=S1.Ni';    
end
m = load(['models/ubm_means'], '-ascii');
E = load(['models/ubm_variances'], '-ascii');
spk_ids=(1:k)';
%---
v = randn(ny, size(F, 2)) * sum(E,2) * 0.001;
S = [];
n_speakers=max(spk_ids);
n_sessions=size(spk_ids,1);
for ii=1:10
    if (TrainMethod==1)
        [y v]=estimate_y_and_v(F, N, S, m, E, 0, v, 0, zeros(n_speakers,1), 0, zeros(n_sessions,1), spk_ids);
    elseif (TrainMethod==2)
        [y v]=estimate_y_and_v_ivector(S, m, E, 0, v, 0, zeros(n_speakers,1), 0, zeros(n_sessions,1), spk_ids);
    end
    out_mat_file = ['optimum_output/v_it' num2str(ii, '%03d')];
    disp(['Saving v to ' out_mat_file])
    save(out_mat_file, 'v');
end
save(['optimum_output/' ['v_opt_' num2str(10) ]], 'v');
%--------------------------------------------------------------------------

