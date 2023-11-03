
%%%%  Train LVM matrix %%%%%%%

function [vLVM,CSV,J]=Train_LVMmatrix(pathstates,IvectorSvmpath,J)
%------------------------------------------------------------------
load( [pathstates,'\Methods'] );
load( [pathstates,'\Path']);
load( [pathstates,'\Param'] );

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
train_mat_file = ['./data/stats/' 'ivector-T'];
load(train_mat_file); %loads F, N, spk_ids
m = load(['models/ubm_means'], '-ascii');
E = load(['models/ubm_variances'], '-ascii');
spk_ids=(1:k)';
%---
[MSV,CSV,W]=readALZgmm_me([IvectorSvmpath,'\Models\UBM.gmm']);
vLVM=estimate_yv_LVM(F, N,CSV,J);

%--------------------------------------------------------------------------

