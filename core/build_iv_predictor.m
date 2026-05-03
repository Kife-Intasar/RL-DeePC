function pred = build_iv_predictor(U, Y, cfg)

m = size(U,1);
p = size(Y,1);
T = size(U,2);
Tini = cfg.Tini;
N = cfg.N;
reg = cfg.iv_pred_reg;

if ~isfield(cfg,'iv_pred_use_outputs') || isempty(cfg.iv_pred_use_outputs)
    cfg.iv_pred_use_outputs = false;
end

k0 = 2*Tini;
k1 = T - N;
ns = k1 - k0 + 1;
if ns < 40
    error('build_iv_predictor:NotEnoughData', ...
        'Not enough samples for IV predictor. Need more training data.');
end

nuini = m*Tini;
nyini = p*Tini;
nuf = m*N;
nx = nuini + nyini + nuf;
nyf = p*N;

Phi = zeros(nx, ns);
Z = zeros(nx, ns);
Yf = zeros(nyf, ns);

for kk = k0:k1
    c = kk - k0 + 1;

    uini = reshape(U(:, kk-Tini+1:kk), [], 1);
    yini = reshape(Y(:, kk-Tini+1:kk), [], 1);
    ufut = reshape(U(:, kk+1:kk+N), [], 1);
    yfut = reshape(Y(:, kk+1:kk+N), [], 1);

    uiv = reshape(U(:, kk-2*Tini+1:kk-Tini), [], 1);
    if cfg.iv_pred_use_outputs
        yiv = reshape(Y(:, kk-2*Tini+1:kk-Tini), [], 1);
    else
        yiv = zeros(nyini,1);
    end

    Phi(:,c) = [uini; yini; ufut];
    Z(:,c)   = [uiv; yiv; ufut];
    Yf(:,c)  = yfut;
end

Theta = (Yf * Z') / (Phi * Z' + reg * eye(nx));

pred = struct();
pred.Pu = Theta(:, 1:nuini);
pred.Py = Theta(:, nuini + (1:nyini));
pred.G  = Theta(:, nuini + nyini + (1:nuf));
pred.Theta = Theta;
pred.regressor_dim = nx;
pred.output_dim = nyf;
pred.kind = 'iv_predictor';
end
