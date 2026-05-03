clear; clc; close all;

setup_paths();

cfg = default_config();
cfg = set_prediction_profile(cfg,'standard');   
% Official datasets
cfg.section1_datasets = {'silverbox','emps','cascaded_tanks','ced','wiener_hammerstein'};

cfg.section1_methods = { ...
    'proposed_bt_deepc','proposed_bt_reduced_deepc', ...
    'proposed_irka_deepc','proposed_irka_reduced_deepc'};

% Methods to plot
cfg.section1_methods_plot = cfg.section1_methods;

% Progress printing
cfg.section1_verbose = true;
cfg.section1_progress_every = 50;
cfg.section1_print_case_header = true;
cfg.section1_print_model_info = true;
cfg.section1_print_method_summary = true;
cfg.section1_print_window_counter = true;

out = run_section1_prediction_suite(cfg);
disp('Section 1 finished.');
