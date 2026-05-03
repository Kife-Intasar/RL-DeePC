function R = run_prediction_case(case_in, cfg)

P = prepare_prediction_case(case_in, cfg);

if local_cfg_true(cfg, 'section1_print_case_header', true)
    fprintf('\n------------------------------------------------------------\n');
    fprintf('Running case: %s\n', P.name);
    fprintf('Train length used : %d\n', numel(P.train_u_n));
    fprintf('Test length used  : %d\n', numel(P.test_u_n));
    fprintf('Tini = %d, N = %d, init_len = %g, stride = %d\n', ...
        cfg.Tini, cfg.N, P.init_len, max(1,cfg.prediction_stride));
end

t_build = tic;
info = build_prediction_shared_models(P.train_u_n, P.train_y_n, cfg);
t_build_elapsed = toc(t_build);

if local_cfg_true(cfg, 'section1_print_model_info', true)
    fprintf('Shared models built in %.3f s\n', t_build_elapsed);
    fprintf('  full DeePC columns : %d\n', size(info.W,2));
    fprintf('  svd rank           : %d\n', info.svd.rank);
    fprintf('  era order          : %d\n', size(info.era_id.A,1));
    fprintf('  bt rank            : %d (full %d -> reduced %d)\n', info.bt_deepc.rank, info.bt_deepc.num_columns, info.bt_deepc.num_reduced_columns);
    fprintf('  irka rank          : %d (full %d -> reduced %d)\n', info.irka_deepc.rank, info.irka_deepc.num_columns, info.irka_deepc.num_reduced_columns);
    fprintf('  iv regressor dim   : %d\n', info.iv_pred.regressor_dim);
    if isfield(info,'arx')
        fprintf('  arx order          : na=%d, nb=%d\n', info.arx.na, info.arx.nb);
    end
    if isfield(info,'fir')
        fprintf('  fir order          : nb=%d\n', info.fir.nb);
    end
end

method_list = local_prediction_methods(cfg);

if local_cfg_true(cfg, 'section1_verbose', true)
    fprintf('Methods to compute:\n');
    for im = 1:numel(method_list)
        fprintf('  [%02d/%02d] %s\n', im, numel(method_list), method_list{im});
    end
end

K0 = max([cfg.Tini, round(P.init_len), local_required_lag(info, method_list)]);
Ttest = numel(P.test_u_n);
Kend = Ttest - cfg.N;
stride = max(1, cfg.prediction_stride);
idx = K0:stride:Kend;

nwin = numel(idx);
if nwin <= 0
    error('run_prediction_case:NotEnoughData', ...
        'Not enough test data for case %s after Tini/init_len/N settings.', P.name);
end

if local_cfg_true(cfg, 'section1_verbose', true)
    fprintf('Rolling prediction windows: %d\n', nwin);
end

Ytrue = zeros(nwin, cfg.N);
Yhat = struct();
SolveT = struct();

for im = 1:numel(method_list)
    mname = method_list{im};
    Yhat.(mname) = zeros(nwin, cfg.N);
    SolveT.(mname) = zeros(nwin, 1);
    OrderWin.(mname) = nan(nwin, 1);
end

Hbt = [];
Hirka = [];
if any(strcmp(method_list,'proposed_bt_deepc'))
    Hbt = projector_penalty_from_basis(info.bt_deepc.V, info.W, cfg.bt_soft, cfg);
end
if any(strcmp(method_list,'proposed_irka_deepc'))
    Hirka = projector_penalty_from_basis(info.irka_deepc.V, info.W, cfg.irka_soft, cfg);
end

progress_every = local_cfg_value(cfg, 'section1_progress_every', 25);
progress_every = max(1, round(progress_every));
case_timer = tic;

for ii = 1:nwin
    k = idx(ii);

    u_ini = P.test_u_n(k-cfg.Tini+1:k);
    y_ini = P.test_y_n(k-cfg.Tini+1:k);

    u_fut = P.test_u_n(k+1:k+cfg.N);
    y_fut = P.test_y_n(k+1:k+cfg.N);

    Ytrue(ii,:) = y_fut(:).';

    online_states = local_update_online_states(online_states, P, k, cfg);

    for im = 1:numel(method_list)
        mname = method_list{im};
        t0 = tic;
        [yh, ord_now] = local_predict_method(mname, info, P, k, u_ini, y_ini, u_fut, Hbt, Hirka, cfg, online_states);
        SolveT.(mname)(ii) = toc(t0);
        Yhat.(mname)(ii,:) = yh(:).';
        OrderWin.(mname)(ii) = ord_now;
    end

    if local_cfg_true(cfg, 'section1_print_window_counter', true)
        if ii == 1 || mod(ii, progress_every) == 0 || ii == nwin
            elapsed = toc(case_timer);
            frac = ii / nwin;
            if frac > 0
                eta_sec = elapsed * (1 - frac) / frac;
            else
                eta_sec = NaN;
            end
            fprintf('[%s] window %d / %d (%.1f%%) | elapsed %.1fs | ETA %.1fs\n', ...
                P.name, ii, nwin, 100*frac, elapsed, eta_sec);
        end
    end
end

inv_y = @(Y) P.scale.mu_y + P.scale.sig_y * Y;
Ytrue_d = inv_y(Ytrue);

R = struct();
R.case = P.name;
R.info = info;
R.idx = idx;
R.actual = Ytrue_d;
R.methods = struct();

for im = 1:numel(method_list)
    mname = method_list{im};
    Yd = inv_y(Yhat.(mname));
    order_val = local_method_order(mname, info, OrderWin.(mname));

    M = compute_prediction_metrics(Ytrue_d(:,1), Yd(:,1), P.train_y, SolveT.(mname), order_val);
    Merr = Ytrue_d - Yd;
    M.multi_rmse = sqrt(mean(Merr(:).^2));
    M.multi_mae = mean(abs(Merr(:)));
    M.multi_r2 = 1 - sum(Merr(:).^2) / max(sum((Ytrue_d(:) - mean(Ytrue_d(:))).^2), eps);
    M.horizon_rmse = sqrt(mean(Merr.^2, 1));
    M.horizon_mae = mean(abs(Merr), 1);
    M.horizon_bias = mean(Merr, 1);
    M.order_mean = local_nanmean(OrderWin.(mname));
    M.order_min = local_nanmin(OrderWin.(mname));
    M.order_max = local_nanmax(OrderWin.(mname));
    M.solve_times_ms = 1000 * SolveT.(mname)(:);

    R.methods.(mname) = struct( ...
        'pred', Yd, ...
        'metrics', M, ...
        'display_name', mname, ...
        'order_history', OrderWin.(mname)(:), ...
        'solve_times_ms', 1000 * SolveT.(mname)(:));

    R.segment_pred.(mname) = Yd(:,1);
end

R.segment_t = idx(:);
R.segment_actual = Ytrue_d(:,1);

if local_cfg_true(cfg, 'section1_print_method_summary', true)
    fprintf('Finished case: %s\n', P.name);
    fprintf('%-24s %-10s %-10s %-10s %-10s\n', 'Method','RMSE','FIT(%)','Solve(ms)','Order');
    for im = 1:numel(method_list)
        mname = method_list{im};
        M = R.methods.(mname).metrics;
        fprintf('%-24s %-10.4g %-10.2f %-10.3f %-10.0f\n', ...
            mname, M.rmse, M.fit, M.mean_solve_ms, M.order);
    end
end
end

function method_list = local_prediction_methods(cfg)
supported = { ...
    'proposed_bt_deepc', ...
    'proposed_bt_reduced_deepc', ...
    'proposed_irka_deepc', ...
    'proposed_irka_reduced_deepc'};

requested = cfg.section1_methods;
if isempty(requested)
    error('run_prediction_case:EmptyMethodList', 'cfg.section1_methods is empty.');
end

bad = requested(~ismember(requested, supported));
if ~isempty(bad)
    warning('run_prediction_case:UnsupportedMethods', ...
        'Skipping unsupported Section 1 prediction methods: %s', strjoin(bad, ', '));
end

method_list = requested(ismember(requested, supported));
if isempty(method_list)
    error('run_prediction_case:NoSupportedMethods', ...
        'No supported Section 1 prediction methods were requested.');
end
end


function v = local_nanmean(x)
x = x(:);
x = x(isfinite(x));
if isempty(x), v = NaN; else, v = mean(x); end
end

function v = local_nanmin(x)
x = x(:);
x = x(isfinite(x));
if isempty(x), v = NaN; else, v = min(x); end
end

function v = local_nanmax(x)
x = x(:);
x = x(isfinite(x));
if isempty(x), v = NaN; else, v = max(x); end
end

function lag = local_required_lag(info, method_list)
lag = 0;
if any(strcmp(method_list,'arx_mpc')) && isfield(info,'arx')
    lag = max(lag, info.arx.lag);
end
if any(strcmp(method_list,'fir_mpc')) && isfield(info,'fir')
    lag = max(lag, info.fir.lag);
end
end

function [yh, ord_now] = local_predict_method(mname, info, P, k, u_ini, y_ini, u_fut, Hbt, Hirka, cfg, online_states)
switch mname
  
    case 'proposed_bt_deepc'
        yh = predict_deepc_window(info.W, u_ini, y_ini, u_fut, cfg, Hbt);

    case 'proposed_bt_reduced_deepc'
        yh = predict_deepc_reduced_window(info.bt_deepc.M, u_ini, y_ini, u_fut, cfg, cfg.bt_reduced);

    case 'proposed_irka_deepc'
        yh = predict_deepc_window(info.W, u_ini, y_ini, u_fut, cfg, Hirka);

    case 'proposed_irka_reduced_deepc'
        yh = predict_deepc_reduced_window(info.irka_deepc.M, u_ini, y_ini, u_fut, cfg, cfg.irka_reduced);

    otherwise
        error('Unknown prediction method: %s', mname);
end

yh = yh(:);
ord_now = local_method_order(mname, info, [], online_states);
end

function h = local_hist(sig, k, lag)
if lag <= 0
    h = zeros(1,0);
else
    h = reshape(sig(k-lag+1:k), 1, []);
end
end

function yh = local_predict_ss(model, u_past, y_past, u_future)
x_end = local_estimate_terminal_state(model, u_past(:).', y_past(:).');
yh = rollout_ss_model(model, reshape(u_future(:).', 1, []), x_end);
yh = yh(:);
end

function x_end = local_estimate_terminal_state(model, u_past, y_past)
A = model.A; B = model.B; C = model.C; D = model.D;
T = numel(u_past);
n = size(A,1);
p = size(C,1);
m = size(B,2);

O = zeros(p*T, n);
Tu = zeros(p*T, m*T);

for i = 1:T
    rows = (i-1)*p+1:i*p;
    O(rows,:) = C * (A^(i-1));

    for j = 1:i
        cols = (j-1)*m+1:j*m;
        if i == j
            Tu(rows,cols) = D;
        else
            Tu(rows,cols) = C * (A^(i-j-1)) * B;
        end
    end
end

rhs = y_past(:) - Tu * u_past(:);
reg = 1e-6;
x0 = (O' * O + reg * eye(n)) \ (O' * rhs);

x = x0;
for t = 1:T
    x = A * x + B * u_past(t);
end
x_end = x;
end

function ord = local_method_order(mname, info, order_hist, online_states)
if nargin < 3
    order_hist = [];
end
if nargin < 4
    online_states = struct();
end
switch mname
    case {'proposed_bt_deepc','proposed_bt_reduced_deepc'}
        ord = info.bt_deepc.rank;
    case {'proposed_irka_deepc','proposed_irka_reduced_deepc'}
        ord = info.irka_deepc.rank;
    otherwise
        ord = NaN;
end
end


function states = local_update_online_states(states, P, k, cfg)
fn = fieldnames(states);
K = cfg.Tini + cfg.N;
for i = 1:numel(fn)
    s = states.(fn{i});
    for end_idx = s.last_end+1:k
        if end_idx >= K
            Uobs = reshape(P.test_u_n(1:end_idx), 1, []);
            Yobs = reshape(P.test_y_n(1:end_idx), 1, []);
            wnew = build_latest_deepc_column(Uobs, Yobs, cfg.Tini, cfg.N);
            s = advance_online_deepc_state(s, wnew, cfg);
        end
    end
    s.last_end = k;
    states.(fn{i}) = s;
end
end

function tf = local_cfg_true(cfg, field_name, default_value)
if isfield(cfg, field_name)
    tf = logical(cfg.(field_name));
else
    tf = logical(default_value);
end
end

function v = local_cfg_value(cfg, field_name, default_value)
if isfield(cfg, field_name) && ~isempty(cfg.(field_name))
    v = cfg.(field_name);
else
    v = default_value;
end
end
