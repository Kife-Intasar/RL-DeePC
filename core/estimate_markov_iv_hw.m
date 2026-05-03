function G = estimate_markov_iv_hw(U, Y, cfg)

if ~isfield(cfg,'markov_len') || isempty(cfg.markov_len), cfg.markov_len = 50; end
if ~isfield(cfg,'markov_reg') || isempty(cfg.markov_reg), cfg.markov_reg = 1e-5; end
if ~isfield(cfg,'markov_warmup') || isempty(cfg.markov_warmup), cfg.markov_warmup = 20; end
if ~isfield(cfg,'iv_reg') || isempty(cfg.iv_reg), cfg.iv_reg = 1e-5; end
if ~isfield(cfg,'iv_lag'), cfg.iv_lag = []; end
if ~isfield(cfg,'iv_use_outputs'), cfg.iv_use_outputs = false; end
if ~isfield(cfg,'id_tail_regularization') || isempty(cfg.id_tail_regularization), cfg.id_tail_regularization = 0.02; end

L = cfg.markov_len;
reg = cfg.iv_reg;
warmup = max(cfg.markov_warmup, 2*L + 1);
if isempty(cfg.iv_lag)
    Liv = L;
else
    Liv = max(1, cfg.iv_lag);
end

[p, T] = size(Y);
m = size(U,1);
Liv = min(Liv, L);
k0 = max([L + 1, 2*Liv + 2, warmup + 1]);
ns = T - k0 + 1;
if ns < max(30, 3*L)
    G = estimate_markov_from_data(U, Y, L, cfg.markov_reg, cfg.markov_warmup);
    return;
end

Phi = zeros(m*L, ns);
Z = zeros(m*L, ns);
Tgt = zeros(p, ns);
col = 1;
for k = k0:T
    phi = zeros(m*L,1);
    z = zeros(m*L,1);
    for ell = 1:L
        rows = (ell-1)*m + (1:m);
        phi(rows) = U(:, k-ell);
        idx = k - Liv - ell;
        if idx >= 1
            z(rows) = U(:, idx);
        end
    end
    Phi(:,col) = phi;
    Z(:,col) = z;
    Tgt(:,col) = Y(:,k);
    col = col + 1;
end

lag_scale = 1 + cfg.id_tail_regularization * (0:L-1);
LagReg = diag(repelem(lag_scale(:), m));
Cross = Phi * Z';
Theta = (Tgt * Z') / (Cross + reg * LagReg);

if any(~isfinite(Theta(:)))
    G = estimate_markov_from_data(U, Y, L, cfg.markov_reg, cfg.markov_warmup);
    return;
end

G = cell(L,1);
for ell = 1:L
    cols = (ell-1)*m + (1:m);
    G{ell} = Theta(:, cols);
    if any(~isfinite(G{ell}(:)))
        G = estimate_markov_from_data(U, Y, L, cfg.markov_reg, cfg.markov_warmup);
        return;
    end
end
end
