function info = build_prediction_shared_models(train_u, train_y, cfg)

U = reshape(train_u(:).', 1, []);
Y = reshape(train_y(:).', 1, []);

[Up, Uf, Yp, Yf] = build_deepc_blocks(U, Y, cfg.Tini, cfg.N);
W = [Up; Uf; Yp; Yf];

[Us, Ss, ~] = svd(W, 'econ');
sv = diag(Ss);

info = struct();
info.U = U;
info.Y = Y;
info.W = W;
info.Up = Up;
info.Uf = Uf;
info.Yp = Yp;
info.Yf = Yf;

info.svd.U = Us;
info.svd.S = Ss;
info.svd.rank = choose_energy_rank(sv, cfg.svd_energy);
info.svd.singular_values = sv;
info.svd.M = Us(:,1:info.svd.rank) * Ss(1:info.svd.rank,1:info.svd.rank);

% Identified state-space model from data
G = estimate_markov_iv_hw(U, Y, cfg);
r_id = min(cfg.max_id_order, cfg.era_s * size(Y,1));
[Ae, Be, Ce, De, hsv, hera_meta] = hera_from_markov(G, cfg.era_s, cfg.era_l, r_id, cfg);

info.era_id.A = Ae;
info.era_id.B = Be;
info.era_id.C = Ce;
info.era_id.D = De;
info.era_id.hsv = hsv;
info.era_id.meta = hera_meta;

% Data-driven BT model
[Ab, Bb, Cb, Db, hsv_bt, r_bt, bt_bound] = bt_reduce_auto(Ae, Be, Ce, De, cfg.bt_energy);
info.bt_id.A = Ab;
info.bt_id.B = Bb;
info.bt_id.C = Cb;
info.bt_id.D = Db;
info.bt_id.hsv = hsv_bt;
info.bt_id.rank = r_bt;
info.bt_id.bound = bt_bound;
info.bt_margin = cfg.bt_margin_scale * bt_bound;

% Data-driven IRKA model
if isfield(cfg,'irka_target_order') && ~isempty(cfg.irka_target_order)
    target_r = min(cfg.irka_target_order, size(Ae,1));
else
    target_r = max([8, info.bt_id.rank, round(1.5 * info.bt_id.rank)]);
    target_r = min(target_r, size(Ae,1));
end

[Ai, Bi, Ci, Di, irka_info] = irka_reduce_auto(Ae, Be, Ce, De, target_r, cfg);
info.irka_id.A = Ai;
info.irka_id.B = Bi;
info.irka_id.C = Ci;
info.irka_id.D = Di;
info.irka_id.rank = size(Ai,1);
info.irka_id.info = irka_info;

% Proposed DeePC bases
bt_model = struct('A', Ab, 'B', Bb, 'C', Cb, 'D', Db);
irka_model = struct('A', Ai, 'B', Bi, 'C', Ci, 'D', Di);

info.bt_deepc = build_model_informed_deepc_basis(W, U, bt_model, cfg, cfg.bt_deepc_energy, 'bt');
info.irka_deepc = build_model_informed_deepc_basis(W, U, irka_model, cfg, cfg.irka_deepc_energy, 'irka');

end
