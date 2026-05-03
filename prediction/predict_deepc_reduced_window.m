function [yhat, alpha, aux] = predict_deepc_reduced_window(M, u_ini, y_ini, u_fut, cfg, redcfg)


if nargin < 6 || isempty(redcfg)
    redcfg = struct();
end
redcfg = local_fill_reducedcfg(redcfg, cfg);

m = 1; p = 1;
[Up, Uf, Yp, Yf] = split_deepc_matrix(M, m, p, cfg.Tini, cfg.N);
r = size(M,2);
nuini = m * cfg.Tini;
nufut = m * cfg.N;

ia = 1:r;
iui = r + (1:nuini);
iuf = r + nuini + (1:nufut);

H = zeros(r + nuini + nufut);
H(ia, ia) = 2 * (redcfg.lambda_alpha * eye(r) + redcfg.lambda_sigma * (Yp' * Yp));
H(iui, iui) = 2 * redcfg.lambda_uini * eye(nuini);
H(iuf, iuf) = 2 * redcfg.lambda_ufut * eye(nufut);

f = zeros(r + nuini + nufut, 1);
f(ia) = -2 * redcfg.lambda_sigma * (Yp' * y_ini(:));

Aeq = [Up, -eye(nuini), zeros(nuini, nufut); ...
       Uf, zeros(nufut, nuini), -eye(nufut)];
beq = [u_ini(:); u_fut(:)];

if ~all(isfinite(H(:))) || ~all(isfinite(f(:))) || ~all(isfinite(Aeq(:))) || ~all(isfinite(beq(:)))
    error('predict_deepc_reduced_window:nonfinite', 'Non-finite data in reduced prediction QP.');
end
reg = max(cfg.prediction_kkt_reg, 1e-6);
z = solve_eq_qp_kkt(H, f, Aeq, beq, reg);
alpha = z(ia);
yhat = Yf * alpha;

aux = struct();
aux.eta_uini = z(iui);
aux.eta_ufut = z(iuf);
aux.uini_mismatch = norm(aux.eta_uini, 2);
aux.ufut_mismatch = norm(aux.eta_ufut, 2);
end

function redcfg = local_fill_reducedcfg(redcfg, cfg)
if ~isfield(redcfg, 'lambda_alpha') || isempty(redcfg.lambda_alpha)
    redcfg.lambda_alpha = cfg.lambda_g;
end
if ~isfield(redcfg, 'lambda_sigma') || isempty(redcfg.lambda_sigma)
    redcfg.lambda_sigma = cfg.lambda_sigma;
end
if ~isfield(redcfg, 'lambda_uini') || isempty(redcfg.lambda_uini)
    redcfg.lambda_uini = 10.0;
end
if ~isfield(redcfg, 'lambda_ufut') || isempty(redcfg.lambda_ufut)
    redcfg.lambda_ufut = 10.0;
end
end
