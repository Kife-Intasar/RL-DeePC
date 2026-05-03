function P = prepare_prediction_case(case_in, cfg)

P = case_in;

train_cap = local_get_case_value(cfg, 'prediction_train_caps', P.name, []);
test_cap  = local_get_case_value(cfg, 'prediction_test_caps',  P.name, []);

if isempty(train_cap) && isfield(cfg,'prediction_train_cap')
    train_cap = cfg.prediction_train_cap;
end
if isempty(test_cap) && isfield(cfg,'prediction_test_cap')
    test_cap = cfg.prediction_test_cap;
end

if ~isempty(train_cap)
    Ltr = min(numel(P.train_u), train_cap);
    P.train_u = P.train_u(1:Ltr);
    P.train_y = P.train_y(1:Ltr);
end

if ~isempty(test_cap)
    Lte = min(numel(P.test_u), test_cap);
    P.test_u = P.test_u(1:Lte);
    P.test_y = P.test_y(1:Lte);
end

P.scale = struct();
if isfield(cfg,'prediction_normalize') && cfg.prediction_normalize
    P.scale.mu_u = mean(P.train_u);
    P.scale.mu_y = mean(P.train_y);
    P.scale.sig_u = std(P.train_u); if P.scale.sig_u < eps, P.scale.sig_u = 1; end
    P.scale.sig_y = std(P.train_y); if P.scale.sig_y < eps, P.scale.sig_y = 1; end
else
    P.scale.mu_u = 0; P.scale.mu_y = 0; P.scale.sig_u = 1; P.scale.sig_y = 1;
end

P.train_u_n = (P.train_u - P.scale.mu_u) / P.scale.sig_u;
P.train_y_n = (P.train_y - P.scale.mu_y) / P.scale.sig_y;
P.test_u_n  = (P.test_u  - P.scale.mu_u) / P.scale.sig_u;
P.test_y_n  = (P.test_y  - P.scale.mu_y) / P.scale.sig_y;
end

function v = local_get_case_value(cfg, field_name, case_name, default_value)
v = default_value;
if isfield(cfg, field_name) && isstruct(cfg.(field_name))
    key = matlab.lang.makeValidName(case_name);
    if isfield(cfg.(field_name), key)
        vv = cfg.(field_name).(key);
        if ~isempty(vv)
            v = vv;
        end
    end
end
end
