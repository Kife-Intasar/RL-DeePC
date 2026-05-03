function [yhat, g] = predict_deepc_window(M, u_ini, y_ini, u_fut, cfg, projector)
if nargin < 6
    projector = [];
end
m = 1; p = 1; % Section 1 datasets are SISO.
[Up, Uf, Yp, Yf] = split_deepc_matrix(M, m, p, cfg.Tini, cfg.N);
ng = size(M,2);

Aeq = [Up; Uf];
beq = [u_ini(:); u_fut(:)];
H = 2*(cfg.lambda_g * eye(ng) + cfg.lambda_sigma * (Yp' * Yp));
f = -2*cfg.lambda_sigma * (Yp' * y_ini(:));
if ~isempty(projector)
    H = H + 2*projector;
end

if ~all(isfinite(H(:))) || ~all(isfinite(f(:))) || ~all(isfinite(Aeq(:))) || ~all(isfinite(beq(:)))
    error('predict_deepc_window:nonfinite', 'Non-finite data in prediction QP.');
end
reg = max(cfg.prediction_kkt_reg, 1e-6);
g = solve_eq_qp_kkt(H, f, Aeq, beq, reg);
yhat = Yf * g;
end
