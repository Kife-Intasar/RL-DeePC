function Hproj = projector_penalty_from_basis(Vr, M, cfgp, cfg)

if ~isfield(cfgp, 'lambda_perp_g') || isempty(cfgp.lambda_perp_g)
    if isfield(cfgp,'lambda_sub_coeff'), cfgp.lambda_perp_g = cfgp.lambda_sub_coeff; else, cfgp.lambda_perp_g = 0.05; end
end
if ~isfield(cfgp, 'lambda_perp_u') || isempty(cfgp.lambda_perp_u)
    if isfield(cfgp,'lambda_sub_u'), cfgp.lambda_perp_u = cfgp.lambda_sub_u; else, cfgp.lambda_perp_u = 0.10; end
end
if ~isfield(cfgp, 'lambda_perp_y') || isempty(cfgp.lambda_perp_y)
    if isfield(cfgp,'lambda_sub_y'), cfgp.lambda_perp_y = cfgp.lambda_sub_y; else, cfgp.lambda_perp_y = 1.00; end
end
m = 1; p = 1;
[~, Uf, ~, Yf] = split_deepc_matrix(M, m, p, cfg.Tini, cfg.N);
ng = size(M,2);
Vr = orth(Vr);
Pperp = eye(ng) - Vr * Vr.';
Hproj = cfgp.lambda_perp_g * Pperp ...
      + cfgp.lambda_perp_u * (Pperp' * (Uf' * Uf) * Pperp) ...
      + cfgp.lambda_perp_y * (Pperp' * (Yf' * Yf) * Pperp);
end
