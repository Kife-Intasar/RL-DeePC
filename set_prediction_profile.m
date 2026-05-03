function cfg = set_prediction_profile(cfg, profile_name)

if nargin < 2 || isempty(profile_name)
    profile_name = 'standard';
end

profile_name = lower(strrep(profile_name,' ','_'));
cfg.prediction_profile = profile_name;

% ---------------------------------------------------------
% Global fallback values
% Used only when a specific case is not explicitly configured.
% ---------------------------------------------------------
cfg.prediction_train_cap = 4000;
cfg.prediction_test_cap  = 3000;
cfg.prediction_plot_points = 3000;
cfg.prediction_stride = 1;

% ---------------------------------------------------------
% Initialize per-case containers
% ---------------------------------------------------------
cfg.prediction_train_caps = struct();
cfg.prediction_test_caps  = struct();
cfg.prediction_plot_ranges = struct();

switch profile_name

    case 'standard'
        % Good compromise for normal use
        cfg.prediction_train_cap = 5000;
        cfg.prediction_test_cap  = 4000;
        cfg.prediction_plot_points = 4000;
        cfg.prediction_stride = 1;

        cfg = local_set_case(cfg, 'silverbox_test_multisine',              8000, 8000, [1 8000]);
        cfg = local_set_case(cfg, 'silverbox_test_arrow_full',             8000, 8000, [1 8000]);
        cfg = local_set_case(cfg, 'silverbox_test_arrow_no_extrapolation', 8000, 6000, [2000 6000]);

        cfg = local_set_case(cfg, 'emps_test',                             6000, 12000, [1 12000]);
        cfg = local_set_case(cfg, 'cascaded_tanks_test',                   4000, 4000, [1 4000]);
        cfg = local_set_case(cfg, 'ced_test_low',                          5000, 4000, [1 4000]);
        cfg = local_set_case(cfg, 'ced_test_high',                         5000, 4000, [1 4000]);

        cfg = local_set_case(cfg, 'wiener_hammerstein_test',               8000, 12000, [1 12000]);

    otherwise
        error('Unknown prediction profile: %s. Usestandard.', profile_name);
end

end

function cfg = local_set_case(cfg, case_name, train_cap, test_cap, plot_range)
key = matlab.lang.makeValidName(case_name);
cfg.prediction_train_caps.(key) = train_cap;
cfg.prediction_test_caps.(key) = test_cap;
cfg.prediction_plot_ranges.(key) = plot_range;
end
