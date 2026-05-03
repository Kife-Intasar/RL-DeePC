function out = run_section1_prediction_suite(cfg)

rootdir = fileparts(fileparts(mfilename('fullpath')));
datasets = cfg.section1_datasets;
out = struct();
out.datasets = struct();
results_dir = fullfile(rootdir, 'results', 'section1_prediction');
if ~exist(results_dir,'dir'), mkdir(results_dir); end

fprintf('\n============================================================\n');
fprintf('Starting Section 1 prediction benchmark suite\n');
fprintf('Datasets to run: %s\n', strjoin(datasets, ', '));
fprintf('Methods to compute: %s\n', strjoin(cfg.section1_methods, ', '));
if isfield(cfg,'section1_methods_plot') && ~isempty(cfg.section1_methods_plot)
    fprintf('Methods to plot   : %s\n', strjoin(cfg.section1_methods_plot, ', '));
end
fprintf('============================================================\n');

suite_timer = tic;

for i = 1:numel(datasets)
    ds = load_prediction_dataset(datasets{i}, rootdir);
    cases = ds.cases;
    res = [];

    fprintf('\n############################################################\n');
    fprintf('Dataset %d / %d : %s\n', i, numel(datasets), ds.title);
    fprintf('Number of cases : %d\n', numel(cases));
    fprintf('############################################################\n');

    dataset_timer = tic;

    for k = 1:numel(cases)
        fprintf('\n============================================================\n');
        fprintf('Section 1 prediction benchmark: %s / %s  (%d of %d cases)\n', ...
            ds.title, cases(k).name, k, numel(cases));

        Ri = run_prediction_case(cases(k), cfg);

        if isempty(res)
            res = Ri;
        else
            res(end+1) = Ri;
        end

        plot_prediction_case(Ri, ds.unit, fullfile(results_dir, ds.name), cfg);
        fprintf('Saved plot for case: %s\n', cases(k).name);
    end

    out.datasets.(ds.name) = res;

    fprintf('Finished dataset %s in %.2f s\n', ds.title, toc(dataset_timer));
end

fprintf('\nAll Section 1 datasets finished in %.2f s\n', toc(suite_timer));
end
