
function make_suf_stat_enroll(ProgPath,JFA_s_features,JFA_f_lists)
% process train dataset


m=load('models/ubm_means')';
v=load('models/ubm_variances')';
w=load('models/ubm_weights')';

n_mixtures  = size(w, 1);
dim         = size(m, 1) / n_mixtures;

% we load the model as superverctors, so we reshape it to have each gaussian in
% one column

m = reshape(m, dim, n_mixtures);
v = reshape(v, dim, n_mixtures);

% these are the sets that we want to extract the stats for

data_sets{1,1} = JFA_f_lists;

% process test dataset
for set_i = 1:size(data_sets,1)

    set_list_file = [ 'lists/' data_sets{set_i,1} '.lst' ];
    disp(['Processing list ' set_list_file]);

    % process the file list (logical=physical)

    [spk_logical spk_physical] = parse_list(set_list_file);
    n_sessions = size(spk_logical, 1);

    % initialize the matrices for the stats
    % one row per session

    N = zeros(n_sessions, n_mixtures);
    F = zeros(n_sessions, n_mixtures * dim);
    TimeOfEstimation(set_i)=0;
    MaxDataLength =12000;

    % process each session

    Ind=0;
    sec_seg=[];

    for session_i = 1:n_sessions

        session_name = [ spk_physical{session_i,1} '.ascii' ];
        disp(['Reading feature file ' session_name]);
        data = load(session_name, '-ascii')';
        s = data';
        size(s)
        disp('Processing...');
        tic
        %[max(max((m)))         max(max((v)))         max(max((w)))         max(max((s)))]
        % process the feature file       
        [Ni Fi] = collect_suf_stats(s, m, v, w);
        %[min(Ni) min(min(Fi))]
        toc
        N(session_i,:) = Ni;
        F(session_i,:) = Fi;
    end
    
    out_stats_file = [ 'data/stats/' data_sets{set_i,1} '.mat' ];
    disp(['Saving stats to ' out_stats_file]);
    save(out_stats_file, 'N', 'F', 'spk_logical');
end
