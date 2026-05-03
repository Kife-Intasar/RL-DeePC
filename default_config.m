%%%
function cfg = default_config()
%DEFAULT_CONFIG Default settings for the SCIS DeePC package.
root = fileparts(mfilename('fullpath'));
addpath(root);
addpath(fullfile(root,'core'));
addpath(fullfile(root,'methods'));
addpath(fullfile(root,'plants'));
addpath(fullfile(root,'configs'));
addpath(fullfile(root,'prediction'));

cfg.seed = 5;
cfg.benchmark_names = available_benchmarks('all');

% Use a profile instead of tiny global caps.
cfg = set_prediction_profile(cfg,'standard');

cfg.Tsim = 160;
cfg.Tini = 16;
cfg.N = 16;
cfg.Tdata = 260;
cfg.pe_hold = 2;
cfg.data_noise_std = 0.01;
cfg.train_zero_x0 = true;
cfg.markov_len = 50;
cfg.markov_warmup = 20;
cfg.markov_reg = 1e-5;

cfg.id_method = 'iv_hera';
cfg.iv_lag = [];
cfg.iv_reg = 1e-5;
cfg.iv_use_outputs = false;
cfg.id_tail_regularization = 0.02;

cfg.hera_row_decay = 0.03;
cfg.hera_col_decay = 0.03;

cfg.deepc_future_weight_decay = 0.04;
cfg.deepc_past_weight = 1.0;
cfg.deepc_input_weight = 1.0;
cfg.deepc_output_weight = 1.0;
cfg.compute_approx_certificates = true;

cfg.lambda_g = 1e-2;
cfg.lambda_sigma = 5.0;
cfg.soft_y_penalty = 200.0;

cfg.svd_energy = 0.985;
cfg.bt_energy = 0.975;
cfg.bt_deepc_energy = 0.995;
cfg.irka_deepc_energy = 0.990;
cfg.era_s = 12;
cfg.era_l = 12;
cfg.max_id_order = 20;
cfg.arx_na = 4;
cfg.arx_nb = 4;
cfg.fir_nb = 6;
cfg.arx_reg = 1e-5;

cfg.bt_margin_scale = 1.0;
cfg.robust_lambda_sigma_scale = 4.0;
cfg.robust_lambda_g_scale = 4.0;
cfg.robust_soft_y_penalty_scale = 4.0;
cfg.robust_y_margin_scale = 1.0;

cfg.irka_max_iter = 15;
cfg.irka_tol = 1e-4;
cfg.irka_shift_min = 1.02;
cfg.irka_shift_max = 50.0;
cfg.irka_target_order = [];

% Proposed soft-subspace DeePC settings.
cfg.bt_deepc_rank_min = 30;
cfg.bt_deepc_rank_max = 140;
cfg.bt_svd_guard_rank = 10;
cfg.bt_focus_up = 0.20;
cfg.bt_focus_uf = 1.00;
cfg.bt_focus_yp = 0.40;
cfg.bt_focus_yf = 4.50;

cfg.irka_deepc_rank_min = 50;
cfg.irka_deepc_rank_max = 160;
cfg.irka_svd_guard_rank = 8;
cfg.irka_focus_up = 0.20;
cfg.irka_focus_uf = 1.00;
cfg.irka_focus_yp = 0.40;
cfg.irka_focus_yf = 3.00;

cfg.bt_soft.lambda_sub_coeff = 0.15;
cfg.bt_soft.lambda_sub_u = 0.50;
cfg.bt_soft.lambda_sub_y = 4.00;
cfg.bt_soft.lambda_perp = 0.05;
cfg.bt_soft.lambda_alpha = 1e-4;
cfg.bt_soft.lambda_perp_g = 0.05;
cfg.bt_soft.lambda_perp_u = 0.10;
cfg.bt_soft.lambda_perp_y = 1.20;

cfg.irka_soft.lambda_sub_coeff = 0.10;
cfg.irka_soft.lambda_sub_u = 0.35;
cfg.irka_soft.lambda_sub_y = 2.50;
cfg.irka_soft.lambda_perp = 0.02;
cfg.irka_soft.lambda_alpha = 1e-4;
cfg.irka_soft.lambda_perp_g = 0.03;
cfg.irka_soft.lambda_perp_u = 0.08;
cfg.irka_soft.lambda_perp_y = 0.80;

cfg.bt_reduced.lambda_alpha = cfg.lambda_g;
cfg.bt_reduced.lambda_sigma = cfg.lambda_sigma;
cfg.bt_reduced.lambda_uini = 10.0;
cfg.bt_reduced.lambda_ufut = 10.0;

cfg.irka_reduced.lambda_alpha = cfg.lambda_g;
cfg.irka_reduced.lambda_sigma = cfg.lambda_sigma;
cfg.irka_reduced.lambda_uini = 10.0;
cfg.irka_reduced.lambda_ufut = 10.0;


cfg.online_deepc.rank_tol = 1e-8;
cfg.online_deepc.sigma_thr_rel = 0.05;
cfg.online_deepc.accept_eps = 1e-9;
cfg.online_deepc.reduced.lambda_alpha = cfg.lambda_g;
cfg.online_deepc.reduced.lambda_sigma = cfg.lambda_sigma;
cfg.online_deepc.reduced.lambda_uini = 10.0;
cfg.online_deepc.reduced.lambda_ufut = 10.0;

% IV / CL-SPC-style direct predictor baseline.
cfg.iv_pred_reg = 1e-4;
cfg.iv_pred_use_outputs = false;
cfg.iv_pred_bias_correct = true;

% gamma-DDPC-style two-stage baseline.
cfg.gamma_ddpc.lambda_past_g = 1e-3;
cfg.gamma_ddpc.lambda_past_sigma = 10 * cfg.lambda_sigma;
cfg.gamma_ddpc.lambda_anchor = 5e-2;
cfg.gamma_ddpc.lambda_g_stage2 = cfg.lambda_g;
cfg.gamma_ddpc.lambda_sigma_stage2 = cfg.lambda_sigma;

% Synthetic benchmarks are for ablations only by default; official Section 1
% and Section 2 have their own plotting functions.
cfg.make_plots = false;
cfg.plot_methods = {'full_deepc','svd_deepc','iv_deepc','gamma_ddpc','replacement_deepc','adding_deepc','online_reduced_order_deepc','proposed_bt_deepc','proposed_bt_reduced_deepc','proposed_irka_deepc','proposed_irka_reduced_deepc'};
cfg.proposed_methods = {'proposed_bt_deepc','proposed_bt_reduced_deepc','proposed_irka_deepc','proposed_irka_reduced_deepc'};
cfg.plot_lambda = true;
cfg.plot_order = true;
cfg.plot_step = true;
cfg.plot_physical = false;
cfg.section1_marker_spacing = 35;
cfg.section2_marker_spacing = 20;
cfg.use_shared_plot_styles = true;

cfg.solver.max_outer = 120;
cfg.solver.max_inner = 5;
cfg.solver.rho = 10.0;
cfg.solver.tol = 1e-4;
cfg.solver.alpha_scale = 0.95;
cfg.solver.verbose = 0;

cfg.pg.max_iter = 220;
cfg.pg.alpha = 0.05;
cfg.pg.tol = 1e-5;
cfg.pg.verbose = 0;

% Section 1 official prediction benchmark settings.
cfg.section1_enabled = true;
cfg.section1_datasets = {'silverbox','emps','cascaded_tanks','ced','wiener_hammerstein'};

cfg.section1_methods = { ...
    'proposed_bt_deepc', ...
    'proposed_bt_reduced_deepc', ...
    'proposed_irka_deepc', ...
    'proposed_irka_reduced_deepc'};

cfg.section1_methods_plot = { ...
    'proposed_bt_deepc', ...
    'proposed_bt_reduced_deepc', ...
    'proposed_irka_deepc', ...
    'proposed_irka_reduced_deepc'};

cfg.prediction_regularize = true;
cfg.prediction_normalize = true;
cfg.prediction_kkt_reg = 1e-6;

cfg.section1_verbose = true;
cfg.section1_progress_every = 25;
cfg.section1_print_case_header = true;
cfg.section1_print_model_info = true;
cfg.section1_print_method_summary = true;
cfg.section1_print_window_counter = true;

cfg.method_names = { ...
    'proposed_bt_deepc', ...
    'proposed_bt_reduced_deepc', ...
    'proposed_irka_deepc', ...
    'proposed_irka_reduced_deepc'};


cfg.methods = cfg.method_names;

end
end
