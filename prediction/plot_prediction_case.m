function fig = plot_prediction_case(R, unit_str, save_dir, cfg)
if nargin < 2 || isempty(unit_str), unit_str = ''; end
if nargin < 3 || isempty(save_dir), save_dir = ''; end
if nargin < 4 || isempty(cfg), cfg = struct(); end

npts = numel(R.segment_t);

if isfield(cfg,'prediction_plot_ranges') && isstruct(cfg.prediction_plot_ranges)
    key = matlab.lang.makeValidName(R.case);
    if isfield(cfg.prediction_plot_ranges, key)
        rr = cfg.prediction_plot_ranges.(key);
        i1 = max(1, rr(1));
        i2 = min(npts, rr(2));
        idx = i1:i2;
    else
        use_pts = local_get_cfg(cfg, 'prediction_plot_points', npts);
        use_pts = min(npts, use_pts);
        idx = 1:use_pts;
    end
else
    use_pts = local_get_cfg(cfg, 'prediction_plot_points', npts);
    use_pts = min(npts, use_pts);
    idx = 1:use_pts;
end

method_list = local_plot_methods(cfg, R);

if isfield(cfg,'section1_marker_spacing') && ~isempty(cfg.section1_marker_spacing)
    marker_step = max(1, round(cfg.section1_marker_spacing));
else
    marker_step = 35;
end
marker_idx = 1:marker_step:numel(idx);

fig = figure('Color','w','Name',R.case);
hold on;

plot(R.segment_t(idx), R.segment_actual(idx), ...
    'Color', [0 0 0], ...
    'LineStyle', '--', ...
    'LineWidth', 1.8, ...
    'DisplayName', 'measured official test output');

for im = 1:numel(method_list)
    mname = method_list{im};

    if ~isfield(R.segment_pred, mname) || isempty(R.segment_pred.(mname))
        continue;
    end

    st = get_method_plot_style(mname);

    plot(R.segment_t(idx), R.segment_pred.(mname)(idx), ...
        'Color', st.Color, ...
        'LineStyle', st.LineStyle, ...
        'LineWidth', st.LineWidth, ...
        'Marker', st.Marker, ...
        'MarkerSize', st.MarkerSize, ...
        'MarkerIndices', marker_idx, ...
        'DisplayName', local_display_name(mname, st));
end

grid on;
box on;
xlabel('Test index');

if ~isempty(unit_str)
    ylabel(['Measured / predicted output (' unit_str ')']);
else
    ylabel('Measured / predicted output');
end

title([strrep(R.case,'_',' '), ' - official measured output vs predictions'], ...
    'Interpreter', 'none');

legend('Location', 'best', 'Interpreter', 'none');

if ~isempty(save_dir)
    if ~exist(save_dir,'dir'), mkdir(save_dir); end
    saveas(fig, fullfile(save_dir, [R.case '_prediction.png']));
end
end

function method_list = local_plot_methods(cfg, R)
% Prefer explicit plotting list from cfg, then fall back to available predictions.
if isfield(cfg,'section1_methods_plot') && ~isempty(cfg.section1_methods_plot)
    candidate = cfg.section1_methods_plot;
elseif isfield(cfg,'section1_methods') && ~isempty(cfg.section1_methods)
    candidate = cfg.section1_methods;
else
    candidate = fieldnames(R.segment_pred);
end

if ischar(candidate) || isstring(candidate)
    candidate = cellstr(candidate);
end

available = fieldnames(R.segment_pred);
method_list = {};

for i = 1:numel(candidate)
    m = candidate{i};
    if ismember(m, available) && ~isempty(R.segment_pred.(m))
        method_list{end+1} = m; %#ok<AGROW>
    end
end

% Final fallback: plot everything available if filtered list is empty.
if isempty(method_list)
    method_list = available(:).';
end
end

function name = local_display_name(mname, st)
if nargin >= 2 && isstruct(st) && isfield(st,'DisplayName') && ~isempty(st.DisplayName)
    name = st.DisplayName;
else
    name = strrep(mname,'_',' ');
end
end

function v = local_get_cfg(cfg, field_name, default_value)
if isfield(cfg, field_name) && ~isempty(cfg.(field_name))
    v = cfg.(field_name);
else
    v = default_value;
end
end
